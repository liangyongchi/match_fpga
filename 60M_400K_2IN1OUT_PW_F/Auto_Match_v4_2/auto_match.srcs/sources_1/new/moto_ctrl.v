module moto_ctrl(
    input            clk             ,
    input            rst_n           , 
    input   [31:0]   pwm_param1      ,  
    input   [31:0]   pwm_param2      ,  
    input   [7:0]    moto_en_ctrl    ,  
    output  reg      O_PWM           ,
    output           MOTO_DIR        ,      
    input            MOTO_ALM        , 
    output           MOTO_EN         ,
    output     [1:0] moto_work_state // �������״̬   
);

    reg [31:0] pwm_counter;      // PWM���ڼ�����
    reg [31:0] cycle_counter;    // ���������ڼ�����
    reg pwm_start_prev;         // ʹ���ź��ӳټĴ���
    wire pwm_start; 
    wire [31:0] cycle_num;       //������
    wire [31:0] pwm_period;
    wire pwm_start_posedge;
    reg pwm_on_off_ctrl; // PWMʹ�ܿ����ź�
    reg MOTO_ALM_STATE;  // �������״̬

    assign cycle_num = pwm_param1;
    assign pwm_period = pwm_param2;
    assign pwm_start_posedge = ~pwm_start_prev & pwm_start;    // Edge detection
    assign MOTO_EN = moto_en_ctrl[2];                          // Enable motor control
    assign MOTO_DIR = moto_en_ctrl[1];                         // Motor direction
    assign pwm_start = moto_en_ctrl[0];                        
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // ��λ���мĴ��������
            pwm_counter <= 0;
            cycle_counter <= 0;
            O_PWM <= 0;
            pwm_start_prev <= 0;
            pwm_on_off_ctrl <= 1'b0; // ��ֹPWM���
        end else begin
            pwm_start_prev <= pwm_start;  // ����ʹ���ź�״̬

            // ���ʹ���ź�������
            if (pwm_start_posedge) begin
                pwm_counter <= 0;
                cycle_counter <= 0;
                pwm_on_off_ctrl <= 1'b1; // ʹ��PWM���
            end

            if (pwm_on_off_ctrl) begin
                if (cycle_counter < cycle_num) begin
                    // PWM���ڼ���
                    if (pwm_counter < pwm_period - 1)
					begin
                        pwm_counter <= pwm_counter + 1;
                    end 
					else 
					begin
                        pwm_counter <= 0;
                        cycle_counter <= cycle_counter + 1;
                    end
                    // ����50%ռ�ձȵ�PWM�ź�
                    O_PWM <= (pwm_counter < (pwm_period >> 1)) ? 1'b1 : 1'b0;
                end else begin
                    O_PWM <= 1'b0;  // ���ָ����������ֹͣ
                    pwm_on_off_ctrl <= 1'b0; // ��ֹPWM���
                end
            end 
			else 
			begin
                // ʹ�ܹر�ʱǿ������͵�ƽ
                O_PWM <= 1'b0;
                pwm_counter <= 0;
                cycle_counter <= 0;
            end
        end
    end

    // wire alm_down_edge;
    // edge_detector edge_detector_inst(
        // .clk      (clk              ),
        // .rst_n    (rst_n            ),
        // .din      (MOTO_ALM         ),
        // .up_edge  (                 ),
        // .down_edge(alm_down_edge    ),  
        // .both_edge(                 )
    // );

    // always @(posedge clk or negedge rst_n) begin
        // if (!rst_n) begin
            // MOTO_ALM_STATE <= 1'b0;
        // end else begin
            // if (alm_down_edge) begin
                // MOTO_ALM_STATE <= 1'b1; 
            // end
        // end
    // end
	
	
wire alm_down_edge;
wire alm_both_edge;
edge_detector edge_detector_inst(
    .clk      (clk      ),
    .rst_n (rst_n ),
    .din (MOTO_ALM ),
    .up_edge (  ),
    .down_edge(alm_down_edge ), 
    .both_edge(alm_both_edge )
);

always @(posedge clk or negedge rst_n) begin
 if (!rst_n) begin
         MOTO_ALM_STATE <= 1'b0;
 end 
 else if (alm_both_edge) begin
         MOTO_ALM_STATE <= 1'b1; 
  end
 else if (!MOTO_EN) begin
         MOTO_ALM_STATE <= 1'b0; 
 end
end	
	
	assign moto_work_state = {MOTO_ALM_STATE, pwm_on_off_ctrl};
endmodule
