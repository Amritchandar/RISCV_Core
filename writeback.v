module writeback(
    input WB_V,
    input [18:0] WB_Cst,
    input [63:0] WB_RES,
    input WB_PC_MUX,
    input [63:0] WB_NPC,
    input [31:0] WB_IR,
    input [63:0] WB_Target_Address,
    output [63:0] OUT_FE_Target_Address,
    output OUT_FE_PC_MUX,
    output OUT_DE_REG_WEN,
    output [4:0] OUT_DE_DR,
    output [63:0] OUT_DE_Data,
    output [4:0] WB_DR,
    output V_OUT_FE_BR_STALL
);
`define DR WB_IR[11:7]
`define WB_Cst_Reg_Wen WB_Cst[0]
`define WB_Cst_W WB_Cst[17]

assign WB_DR = WB_IR[11:7];

//Chooses the correct next PC
assign OUT_FE_Target_Address = WB_Target_Address;
assign OUT_FE_PC_MUX = WB_V && WB_PC_MUX;

//Stores to the register file
assign OUT_DE_REG_WEN = (`WB_Cst_Reg_Wen) && WB_V;
assign OUT_DE_DR = `DR;
assign OUT_DE_Data = (`WB_Cst_W) ? {32'b0, WB_RES[31:0]} : WB_RES;
assign V_OUT_FE_BR_STALL = WB_V && ((WB_IR[6:2] ==5'b11000) || (WB_IR[6:2] ==5'b11001) || (WB_IR[6:2] ==5'b11011));
endmodule