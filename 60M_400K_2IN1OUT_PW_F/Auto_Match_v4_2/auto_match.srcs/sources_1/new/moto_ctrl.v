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
    output     [1:0] moto_work_state // 电机工作状态   
);

    reg [31:0] pwm_counter;      // PWM周期计数器
    reg [31:0] cycle_counter;    // 已生成周期计数器
    reg pwm_start_prev;         // 使能信号延迟寄存器
    wire pwm_start; 
    wire [31:0] cycle_num;       //脉冲数
    wire [31:0] pwm_period;
    wire pwm_start_posedge;
    reg pwm_on_off_ctrl; // PWM使能控制信号
    reg MOTO_ALM_STATE;  // 电机报警状态

    assign cycle_num = pwm_param1;
    assign pwm_period = pwm_param2;
    assign pwm_start_posedge = ~pwm_start_prev & pwm_start;    // Edge detection
    assign MOTO_EN = moto_en_ctrl[2];                          // Enable motor control
    assign MOTO_DIR = moto_en_ctrl[1];                         // Motor direction
    assign pwm_start = moto_en_ctrl[0];                        
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位所有寄存器和输出
            pwm_counter <= 0;
            cycle_counter <= 0;
            O_PWM <= 0;
            pwm_start_prev <= 0;
            pwm_on_off_ctrl <= 1'b0; // 禁止PWM输出
        end else begin
            pwm_start_prev <= pwm_start;  // 保存使能信号状态

            // 检测使能信号上升沿
            if (pwm_start_posedge) begin
                pwm_counter <= 0;
                cycle_counter <= 0;
                pwm_on_off_ctrl <= 1'b1; // 使能PWM输出
            end

            if (pwm_on_off_ctrl) begin
                if (cycle_counter < cycle_num) begin
                    // PWM周期计数
                    if (pwm_counter < pwm_period - 1)
					begin
                        pwm_counter <= pwm_counter + 1;
                    end 
					else 
					begin
                        pwm_counter <= 0;
                        cycle_counter <= cycle_counter + 1;
                    end
                    // 生成50%占空比的PWM信号
                    O_PWM <= (pwm_counter < (pwm_period >> 1)) ? 1'b1 : 1'b0;
                end else begin
                    O_PWM <= 1'b0;  // 完成指定周期数后停止
                    pwm_on_off_ctrl <= 1'b0; // 禁止PWM输出
                end
            end 
			else 
			begin
                // 使能关闭时强制输出低电平
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
