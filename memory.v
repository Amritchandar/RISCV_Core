`timescale 1ns / 1ps
module memory(
    input CLK,
    input RESET,
    input MEM_V,
    input [63:0] MEM_Target_Address,
    input [18:0] MEM_Cst,
    input [63:0] MEM_RES,
    input MEM_PC_MUX,
    input [63:0] MEM_NPC,
    input [63:0] MEM_Address,
    input [31:0] MEM_IR,
    input [63:0] MEM_Data_Out,

    input [63:0] MEM_RFD,
    input [63:0] MEM_CSRFD,
    input DE_Context_Switch,
    input IE,

    output V_MEM_FE_BR_STALL,
    output reg WB_V,
    output reg [18:0] WB_Cst,
    output reg [63:0] WB_RES,
    output reg WB_PC_MUX,
    output reg [63:0] WB_NPC,
    output reg [31:0] WB_IR,
    output reg [63:0] WB_Target_Address,
    output [4:0] MEM_DR,
    output MEM_Cst_R_W,
    output [2:0] MEM_Cst_Size,

    output V_MEM_FE_TRAP_STALL,
    output reg [63:0] WB_RFD,
    output reg [63:0] WB_CSRFD,
    output LAM,
    output SAM
);

`define MEM_Cst_R_W MEM_Cst[5]
`define MEM_Cst_Size MEM_Cst[4:2]
`define MEM_Cst_RES_Mux MEM_Cst[1]

assign MEM_DR = MEM_IR[11:7];

//wire [63:0] MEM_Data_Out;
//Stalls pipeline to allow accurate branches
assign V_MEM_FE_BR_STALL = MEM_V && ((MEM_IR[6:2] ==5'b11000) || (MEM_IR[6:2] ==5'b11001) || (MEM_IR[6:2] ==5'b11011));
assign V_MEM_FE_TRAP_STALL = (MEM_V && MEM_IR[19:0] == 20'h00073 && !DE_Context_Switch && IE) ? 1'd1 : 1'd0;
assign LAM = MEM_Cst_R_W ? 1'b0:((MEM_Address & 64'd3) == 0) ? 1'b0 : 1'b1; 
assign SAM = MEM_Cst_R_W ? ((MEM_Address & 64'd3) == 0) ? 1'b0 : 1'b1:1'b0;

//Memory File comment bellow line if connecting to external BRAM
 //memoryFile x_mem_file (.MEM_V(MEM_V), .CLK(CLK), .RESET(RESET), .r_w(`MEM_Cst_R_W), .size(`MEM_Cst_Size), .data_in(MEM_RES), .address(MEM_Address), .data_out(MEM_Data_Out));

always @(posedge CLK) begin
    if (RESET) begin
        WB_V <= 1'b0;
    end else begin
        WB_V <= DE_Context_Switch ? 1'b0:MEM_V;
        WB_Cst <= MEM_Cst;
        if (`MEM_Cst_RES_Mux) begin
            WB_RES <= MEM_Data_Out;
        end else begin
            WB_RES <= MEM_RES;
        end
        WB_PC_MUX <= MEM_PC_MUX;
        WB_NPC <= MEM_NPC;
        WB_IR <= MEM_IR;
        WB_Target_Address <= MEM_Target_Address;
        WB_RFD <= MEM_RFD;
        WB_CSRFD <= MEM_CSRFD;
    end
end
endmodule