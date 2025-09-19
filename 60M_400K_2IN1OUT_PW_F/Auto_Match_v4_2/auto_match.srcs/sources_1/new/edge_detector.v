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

// 两级同步器处理异步输入
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        din_sync <= 1'b0;
        din_r    <= 1'b0;
    end
    else begin
        din_sync <= din;        // 第一级同步
        din_r    <= din_sync;   // 第二级同步
    end
end

// 边沿检测基于同步后的信号
assign up_edge   = ~din_r & din_sync;  // 上升沿
assign down_edge = din_r & ~din_sync;  // 下降沿
assign both_edge = din_r ^ din_sync;   // 双边沿

endmodule