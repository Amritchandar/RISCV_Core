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
    output [63:0] OUT_DE_CAUSE,
    output OUT_DE_CS,
    output [4:0] WB_DR
);

wire WB_ECALL;

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
assign OUT_DE_Data = WB_RES;

assign OUT_DE_CAUSE = cause_temp;
assign OUT_DE_CS = cs_temp;
assign WB_ECALL = (WB_V && (WB_IR[27:0] == 28'h0000073)) ? 1'd1 : 1'd0;
trap_handler Thandler(
    .CLK(CLK),
    .ECALL(WB_ECALL),
    .F_IAM(0),
    .F_IAF(0),
    .F_II(0),
    .MEM_LAM(0),
    .MEM_LAF(0),
    .MEM_SAM(0),
    .MEM_SAF(0),
    .TIMER(0),
    .EXTERNAL(0),
    .PRIVILEGE(PRIVILEGE),
    .CAUSE(OUT_DE_CAUSE),
    .CS(OUT_DE_CS)
);


assign OUT_DE_Data = (`WB_Cst_W) ? {32'b0, WB_RES[31:0]} : WB_RES;
endmodule