module top(
    input CLK,
    input RESET
);

//Fetch Stage
wire [63:0] DE_NPC;
wire [63:0] DE_PC;
wire [31:0] DE_IR;
wire DE_V;

//Decode Stage
wire [63:0] EXE_ALU1, EXE_ALU2, EXE_Target_Address, EXE_Address, EXE_NPC;
wire [31:0] EXE_IR;
wire [18:0] EXE_Cst;
wire EXE_V, V_DEP_STALL, V_DE_FE_BR_STALL;

//Execute Stage
wire [63:0] MEM_Target_Address, MEM_RES, MEM_NPC, MEM_Address;
wire [31:0] MEM_IR;
wire [18:0] MEM_Cst;
wire [4:0] EXE_DR;
wire MEM_V, MEM_PC_MUX, V_EXE_FE_BR_STALL;

//Memory Stage
wire [63:0] WB_RES, WB_NPC, WB_Target_Address;
wire [31:0] WB_IR;
wire [18:0] WB_Cst;
wire [4:0] MEM_DR;
wire V_MEM_FE_BR_STALL, WB_V, WB_PC_MUX;

//Writeback Stage
wire [63:0] OUT_FE_Target_Address, OUT_DE_Data;
wire [4:0] OUT_DE_DR, WB_DR;
wire OUT_FE_PC_MUX, OUT_DE_REG_WEN;

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
    .V_DEP_STALL(V_DEP_STALL)
);

decode_stage decode_stage(
    .CLK(CLK),
    .RESET(RESET),
    .DE_NPC(DE_NPC),
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
    .OUT_DE_REG_WEN(OUT_DE_REG_WEN)
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
    .EXE_DR(EXE_DR)
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
    .WB_V(WB_V),
    .WB_Cst(WB_Cst),
    .WB_RES(WB_RES),
    .WB_PC_MUX(WB_PC_MUX),
    .WB_NPC(WB_NPC),
    .WB_IR(WB_IR),
    .WB_Target_Address(WB_Target_Address),
    .MEM_DR(MEM_DR)
);

writeback writeback_stage (
    .WB_V(WB_V),
    .WB_Cst(WB_Cst),
    .WB_RES(WB_RES),
    .WB_PC_MUX(WB_PC_MUX),
    .WB_NPC(WB_NPC),
    .WB_IR(WB_IR),
    .WB_Target_Address(WB_Target_Address),
    .OUT_FE_Target_Address(OUT_FE_Target_Address),
    .OUT_FE_PC_MUX(OUT_FE_PC_MUX),
    .OUT_DE_REG_WEN(OUT_DE_REG_WEN),
    .OUT_DE_DR(OUT_DE_DR),
    .OUT_DE_Data(OUT_DE_Data),
    .WB_DR(WB_DR)
);
endmodule