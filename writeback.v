module writeback(
    input WB_V,
    input [18:0] WB_Cst,
    input [63:0] WB_RES,
    input WB_PC_MUX,
    input [63:0] WB_NPC,
    input [31:0] WB_IR,
    input [63:0] WB_Target_Address,
    input CLK,

    input [63:0] WB_CSRFD,
    input [63:0] WB_RFD,
    input [1:0] DE_WB_PRIVILEGE,
    input UART,
    input FE_IAM,
    input FE_II,

    output [63:0] OUT_FE_Target_Address,
    output OUT_FE_PC_MUX,
    output OUT_DE_REG_WEN,
    output [4:0] OUT_DE_DR,
    output [63:0] OUT_DE_Data,
    output [4:0] WB_DR,
    output V_OUT_FE_BR_STALL,

    output [31:0] OUT_DE_IR,
    output [63:0] OUT_DE_CSR_DATA,
    output [63:0] OUT_DE_CAUSE,
    output OUT_DE_ST_CSR,
    output OUT_DE_CS,
    output V_WB_FE_TRAP_STALL,
    output [63:0] OUT_DE_WB_PC
);
`define DR WB_IR[11:7]
`define WB_Cst_Reg_Wen WB_Cst[0]
`define WB_Cst_W WB_Cst[17]

wire WB_ECALL, RET_INST;

assign WB_DR = WB_IR[11:7];
assign OUT_DE_IR = WB_IR;
//Chooses the correct next PC
assign OUT_FE_Target_Address = WB_Target_Address;
assign OUT_FE_PC_MUX = WB_V && WB_PC_MUX;
assign OUT_DE_WB_PC = WB_NPC;

//Stores to the register file
assign OUT_DE_REG_WEN = (`WB_Cst_Reg_Wen) && WB_V;
assign OUT_DE_DR = `DR;
assign OUT_DE_Data = (WB_IR[6:0] == 7'b1110011)? WB_RFD:(`WB_Cst_W) ? {32'b0, WB_RES[31:0]} : WB_RES;
assign OUT_DE_ST_CSR = (WB_IR[6:0] == 7'b1110011) ? 1'b1 : 1'b0;
assign OUT_DE_CSR_DATA = WB_CSRFD;
assign V_OUT_FE_BR_STALL = WB_V && ((WB_IR[6:2] ==5'b11000) || (WB_IR[6:2] ==5'b11001) || (WB_IR[6:2] ==5'b11011));
assign WB_ECALL = (WB_V && (WB_IR[27:0] == 28'h0000073)) ? 1'd1 : 1'd0;
assign RET_INST =  (WB_V && (WB_IR == 32'h30200073 || WB_IR == 32'h10200073)) ? 1'b1: 1'b0;
assign V_WB_FE_TRAP_STALL = (WB_V && WB_IR[19:0] == 20'h00073) ? 1'd1 : 1'd0;

trap_handler Thandler(
    .CLK(CLK),
    .ECALL(WB_ECALL),
    .F_IAM(FE_IAM),
    .F_IAF(1'd0),
    .F_II(FE_II),
    .MEM_LAM(1'd0),
    .MEM_LAF(1'd0),
    .MEM_SAM(1'd0),
    .MEM_SAF(1'd0),
    .TIMER(1'd0),
    .EXTERNAL(UART),
    .PRIVILEGE(DE_WB_PRIVILEGE),
    .CAUSE(OUT_DE_CAUSE),
    .CS(OUT_DE_CS),
    .RET_INST(RET_INST)
);
endmodule