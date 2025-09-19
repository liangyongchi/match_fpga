`timescale 1ns / 1ps
module edge_detector(
    input   clk,
    input   rst_n,
    input   din,
    output  up_edge,
    output  down_edge,
    output  both_edge
);

reg din_r, din_sync;

// ����ͬ���������첽����
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        din_sync <= 1'b0;
        din_r    <= 1'b0;
    end
    else begin
        din_sync <= din;        // ��һ��ͬ��
        din_r    <= din_sync;   // �ڶ���ͬ��
    end
end

// ���ؼ�����ͬ������ź�
assign up_edge   = ~din_r & din_sync;  // ������
assign down_edge = din_r & ~din_sync;  // �½���
assign both_edge = din_r ^ din_sync;   // ˫����

endmodule