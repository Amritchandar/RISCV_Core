module top(
    input CLK,
    input RESET,
    input INTERRUPT
//    input [31:0] MEM_Data_Out_i,
//    output MEM_V,
//    output MEM_Cst_R_W,
//    output [2:0] MEM_Cst_Size,
//    output [31:0] MEM_RES_o,
//    output [31:0] MEM_Address_o
);





wire flush;

//Fetch Stage
wire [63:0] DE_NPC;
wire [63:0] DE_PC;
wire [31:0] DE_IR;
wire DE_V,FE_IAM,FE_II;

//Decode Stage
wire [63:0] EXE_ALU1, EXE_ALU2, EXE_Target_Address, EXE_Address, EXE_NPC, EXE_CSRFD, EXE_RFD, DE_FE_MT_VEC;
wire [31:0] EXE_IR;
wire [18:0] EXE_Cst;
wire [1:0] DE_WB_PRIVILEGE;
wire EXE_V, V_DEP_STALL, V_DE_FE_BR_STALL, V_DE_FE_TRAP_STALL, DE_Context_Switch, IE;

//Execute Stage
wire [63:0] MEM_Target_Address, MEM_RES, MEM_NPC, MEM_Address, MEM_CSRFD, MEM_RFD;
wire [31:0] MEM_IR;
wire [18:0] MEM_Cst;
wire [4:0] EXE_DR;
wire MEM_PC_MUX, V_EXE_FE_BR_STALL, V_EXE_FE_TRAP_STALL;

//Memory Stage
wire [63:0] WB_RES, WB_NPC, WB_Target_Address;
wire [31:0] WB_IR;
wire [18:0] WB_Cst;
wire [4:0] MEM_DR;
wire V_MEM_FE_BR_STALL, WB_V, WB_PC_MUX, V_MEM_FE_TRAP_STALL, MEM_LAM, MEM_SAM;

//Writeback Stage
wire [63:0] OUT_FE_Target_Address, OUT_DE_Data, OUT_DE_CSR_DATA, OUT_DE_CAUSE, OUT_DE_WB_PC, WB_CSRFD, WB_RFD;
wire [4:0] OUT_DE_DR, WB_DR;
wire [31:0] OUT_DE_IR;
wire OUT_FE_PC_MUX, OUT_DE_REG_WEN, V_OUT_FE_BR_STALL, OUT_DE_ST_CSR, OUT_DE_CS;

assign flush = (DE_Context_Switch || FE_IAM || FE_II || MEM_SAM || MEM_LAM);

//assign MEM_Data_Out = {32'b0, MEM_Data_Out_i[31:0]};
assign MEM_RES_o = MEM_RES[31:0];
assign MEM_Address_o = MEM_Address[31:0];


fetch fetch_stage (
    .CLK(CLK), 
    .RESET(RESET),
    .DE_NPC(DE_NPC),
    .DE_IR(DE_IR),
    .DE_V(DE_V),
    .DE_PC(DE_PC),
    .OUT_FE_PC_MUX(OUT_FE_PC_MUX),
    .OUT_FE_Target_Address(OUT_FE_Target_Address),
    .V_DE_FE_BR_STALL(V_DE_FE_BR_STALL),
    .V_EXE_FE_BR_STALL(V_EXE_FE_BR_STALL),
    .V_MEM_FE_BR_STALL(V_MEM_FE_BR_STALL),
    .V_DEP_STALL(V_DEP_STALL),
    .V_OUT_FE_BR_STALL(V_OUT_FE_BR_STALL),
    .V_DE_FE_TRAP_STALL(V_DE_FE_TRAP_STALL),
    .V_EXE_FE_TRAP_STALL(V_EXE_FE_TRAP_STALL),
    .V_MEM_FE_TRAP_STALL(V_MEM_FE_TRAP_STALL),
    .V_WB_FE_TRAP_STALL(V_WB_FE_TRAP_STALL),
    .FE_IAM(FE_IAM),
    .FE_II(FE_II),
    .DE_Context_Switch(flush),
    .OUT_DE_CS(OUT_DE_CS),
    .DE_FE_MT_VEC(DE_FE_MT_VEC)
);

decode_stage decode_stage(
    .CLK(CLK),
    .RESET(RESET),
    .DE_NPC(DE_NPC),
    .DE_PC(DE_PC),
    .DE_IR(DE_IR),
    .DE_V(DE_V),
    .MEM_DR(MEM_DR),
    .EXE_DR(EXE_DR),
    .WB_DR(WB_DR),
    .MEM_V(MEM_V),
    .WB_V(WB_V),
    .ALU1(EXE_ALU1),
    .ALU2(EXE_ALU2),
    .V_DE_FE_BR_STALL(V_DE_FE_BR_STALL),
    .TARGET_ADDRESS(EXE_Target_Address),
    .MEM_ADDRESS(EXE_Address),
    .EXE_Vout(EXE_V),
    .EXE_IR(EXE_IR),
    .EXE_NPC(EXE_NPC),
    .EXE_Cst(EXE_Cst),
    .stall(V_DEP_STALL),
    .OUT_DE_DR(OUT_DE_DR),
    .OUT_DE_Data(OUT_DE_Data),
    .OUT_DE_REG_WEN(OUT_DE_REG_WEN),
    .DE_Context_Switch(DE_Context_Switch),
    .OUT_DE_IR(OUT_DE_IR),
    .DE_FE_MT_VEC(DE_FE_MT_VEC),
    .DE_WB_PRIVILEGE(DE_WB_PRIVILEGE),
    .OUT_DE_CAUSE(OUT_DE_CAUSE),
    .EXE_CSRFD(EXE_CSRFD),
    .EXE_RFD(EXE_RFD),
    .OUT_DE_CSR_DATA(OUT_DE_CSR_DATA),
    .V_DE_FE_TRAP_STALL(V_DE_FE_TRAP_STALL),
    .OUT_DE_ST_CSR(OUT_DE_ST_CSR),
    .OUT_DE_CS(OUT_DE_CS),
    .IE(IE),
    .OUT_DE_WB_PC(OUT_DE_WB_PC)
);

execute execute_stage (
    .CLK(CLK),
    .RESET(RESET),
    .EXE_Address(EXE_Address),
    .EXE_ALU1(EXE_ALU1),
    .EXE_ALU2(EXE_ALU2),
    .EXE_IR(EXE_IR),
    .EXE_Cst(EXE_Cst),
    .EXE_NPC(EXE_NPC),
    .EXE_Target_Address(EXE_Target_Address),
    .EXE_V(EXE_V),
    .MEM_V(MEM_V),
    .MEM_Target_Address(MEM_Target_Address),
    .MEM_Cst(MEM_Cst),
    .MEM_RES(MEM_RES),
    .MEM_PC_MUX(MEM_PC_MUX),
    .MEM_IR(MEM_IR),
    .MEM_NPC(MEM_NPC),
    .V_EXE_FE_BR_STALL(V_EXE_FE_BR_STALL),
    .MEM_Address(MEM_Address),
    .EXE_DR(EXE_DR),
    .EXE_CSRFD(EXE_CSRFD),
    .EXE_RFD(EXE_RFD),
    .MEM_CSRFD(MEM_CSRFD),
    .MEM_RFD(MEM_RFD),
    .DE_Context_Switch(flush),
    .V_EXE_FE_TRAP_STALL(V_EXE_FE_TRAP_STALL),
    .IE(IE)
);

memory memory_stage (
    .CLK(CLK),
    .RESET(RESET),
    .MEM_V(MEM_V),
    .MEM_Target_Address(MEM_Target_Address),
    .MEM_Cst(MEM_Cst),
    .MEM_RES(MEM_RES),
    .MEM_PC_MUX(MEM_PC_MUX),
    .MEM_NPC(MEM_NPC),
    .MEM_Address(MEM_Address),
    .MEM_IR(MEM_IR),
    .V_MEM_FE_BR_STALL(V_MEM_FE_BR_STALL),
    .V_MEM_FE_TRAP_STALL(V_MEM_FE_TRAP_STALL),
    .WB_V(WB_V),
    .WB_Cst(WB_Cst),
    .WB_RES(WB_RES),
    .WB_PC_MUX(WB_PC_MUX),
    .WB_NPC(WB_NPC),
    .WB_IR(WB_IR),
    .WB_Target_Address(WB_Target_Address),
    .DE_Context_Switch(flush),
    .MEM_DR(MEM_DR),
    .MEM_RFD(MEM_RFD),
    .MEM_CSRFD(MEM_CSRFD),
    .WB_RFD(WB_RFD),
    .WB_CSRFD(WB_CSRFD),
    .IE(IE),
    .MEM_Data_Out(MEM_Data_Out),
    .MEM_Cst_R_W(MEM_Cst_R_W),
    .MEM_Cst_Size(MEM_Cst_Size),
    .MEM_SAM(MEM_SAM),
    .MEM_LAM(MEM_LAM)
);

writeback writeback_stage (
    .CLK(CLK),
    .WB_V(WB_V),
    .WB_Cst(WB_Cst),
    .WB_RES(WB_RES),
    .WB_PC_MUX(WB_PC_MUX),
    .WB_NPC(WB_NPC),
    .WB_IR(WB_IR),
    .WB_Target_Address(WB_Target_Address),
    .OUT_FE_Target_Address(OUT_FE_Target_Address),
    .V_WB_FE_TRAP_STALL(V_WB_FE_TRAP_STALL),
    .OUT_FE_PC_MUX(OUT_FE_PC_MUX),
    .OUT_DE_REG_WEN(OUT_DE_REG_WEN),
    .OUT_DE_DR(OUT_DE_DR),
    .OUT_DE_Data(OUT_DE_Data),
    .WB_DR(WB_DR),
    .V_OUT_FE_BR_STALL(V_OUT_FE_BR_STALL),
    .OUT_DE_CS(OUT_DE_CS),
    .OUT_DE_CAUSE(OUT_DE_CAUSE),
    .FE_IAM(FE_IAM),
    .FE_II(FE_II),
    .MEM_SAM(MEM_SAM),
    .MEM_LAM(MEM_LAM),
    .UART(INTERRUPT),
    .OUT_DE_WB_PC(OUT_DE_WB_PC),
    .OUT_DE_IR(OUT_DE_IR),
    .DE_WB_PRIVILEGE(DE_WB_PRIVILEGE),
    .OUT_DE_CSR_DATA(OUT_DE_CSR_DATA),
    .WB_RFD(WB_RFD),
    .WB_CSRFD(WB_CSRFD),
    .OUT_DE_ST_CSR(OUT_DE_ST_CSR)
);
endmodule