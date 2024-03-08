`timescale 1ns / 1ps
module memory(
    input CLK,
    input RESET,
    input MEM_V,
    input [63:0] MEM_Target_Address,
    input [3:0] MEM_Cst,
    input [63:0] MEM_RES,
    input MEM_PC_MUX,
    input [63:0] MEM_NPC,
    input [63:0] MEM_Address,
    input [31:0] MEM_IR,
    output V_MEM_FE_BR_STALL,
    output reg WB_V,
    output reg [3:0] WB_Cst,
    output reg [63:0] WB_RES,
    output reg WB_PC_MUX,
    output reg [63:0] WB_NPC,
    output reg [31:0] WB_IR,
    output reg [63:0] WB_Target_Address,
    output [4:0] MEM_DR
);

`define MEM_Cst_R_W MEM_Cst[0]
`define MEM_Cst_Size MEM_Cst[1:0]
`define MEM_Cst_RES_Mux MEM_Cst[0]

assign MEM_DR = MEM_IR[11:7];

wire [63:0] MEM_Data_Out;
//Stalls pipeline to allow accurate branches
assign V_MEM_FE_BR_STALL = MEM_V && ((MEM_IR[6:2] ==5'b11000) || (MEM_IR[6:2] ==5'b11001) || (MEM_IR[6:2] ==5'b11011));

//Memory File
memoryFile x_mem_file (.MEM_V(MEM_V), .CLK(CLK), .RESET(RESET), .r_w(`MEM_Cst_R_W), .size(`MEM_Cst_Size), .data_in(MEM_RES), .address(MEM_Address), .data_out(MEM_Data_Out));

always @(posedge CLK) begin
    if (RESET) begin
        WB_V <= 1'b0;
    end else begin
        WB_V <= MEM_V;
        WB_Cst <= MEM_Cst;
        if (`MEM_Cst_RES_Mux) begin
            WB_RES <= MEM_RES;
        end else begin
            WB_RES <= MEM_Data_Out;
        end
        WB_PC_MUX <= MEM_PC_MUX;
        WB_NPC <= MEM_NPC;
        WB_IR <= MEM_IR;
        WB_Target_Address <= MEM_Target_Address;
    end
end
endmodule