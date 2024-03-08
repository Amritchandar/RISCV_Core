module writeback(
    input WB_V,
    input [3:0] WB_Cst,
    input [63:0] WB_RES,
    input WB_PC_MUX,
    input [63:0] WB_NPC,
    input [31:0] WB_IR,
    input [63:0] WB_Target_Address,
    output [63:0] OUT_FE_Target_Address,
    output OUT_FE_PC_MUX,
    output OUT_FE_REG_WEN,
    output [4:0] OUT_DE_DR,
    output [63:0] OUT_DE_Data,
    output [4:0] WB_DR
);
`define DR WB_IR[11:7]
`define WB_Cst_Reg_Wen WB_Cst[0]

assign WB_DR = WB_IR[11:7];

//Chooses the correct next PC
assign OUT_FE_Target_Address = WB_Target_Address;
assign OUT_FE_PC_MUX = WB_V && WB_PC_MUX;

//Stores to the register file
assign OUT_FE_REG_WEN = (`WB_Cst_Reg_Wen) && WB_V;
assign OUT_DE_DR = `DR;
assign OUT_DE_Data = WB_RES;
endmodule