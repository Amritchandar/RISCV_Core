`timescale 1ns / 1ps

module fetch (
    input OUT_FE_PC_MUX,
    input [63:0] OUT_FE_Target_Address,
    input V_DE_FE_BR_STALL,
    input V_EXE_FE_BR_STALL,
    input V_MEM_FE_BR_STALL,
    input V_OUT_FE_BR_STALL,
    input V_DEP_STALL,

    input V_DE_FE_TRAP_STALL,
    input V_EXE_FE_TRAP_STALL,
    input V_MEM_FE_TRAP_STALL,
    input V_WB_FE_TRAP_STALL,
    input [63:0] DE_FE_MT_VEC,
    input DE_Context_Switch,
    input OUT_DE_CS,

    input CLK,
    input RESET,
    output reg [63:0] DE_NPC,
    output reg [63:0] DE_PC,
    output reg [31:0] DE_IR,
    output reg DE_V,

    output FE_IAM
);

`define fe_opcode DE_IR[6:0]
`define fe_func3 DE_IR[14:12]
reg [63:0] FE_PC;
wire [31:0] FE_instruction;

assign FE_IAM = ((FE_PC & 64'd3) == 0) ? 1'b0 : 1'b1; //instruction address misaligned

always @(posedge CLK) begin
    //Initial PC below
    if (RESET) begin
        FE_PC <= 64'd512; 
    end else if (DE_Context_Switch) begin
        FE_PC <= DE_FE_MT_VEC;
    end else if (!(V_DEP_STALL || V_DE_FE_BR_STALL || V_EXE_FE_BR_STALL ||V_MEM_FE_BR_STALL || V_DE_FE_TRAP_STALL || V_EXE_FE_TRAP_STALL ||V_MEM_FE_TRAP_STALL || V_WB_FE_TRAP_STALL)) begin
        if (OUT_FE_PC_MUX) begin
            FE_PC <= OUT_FE_Target_Address;
        end else begin
            FE_PC <= FE_PC + 64'd4;
        end
    end

    if (RESET) begin
        DE_V <= 1'b0;
    end else if (!V_DEP_STALL && !V_DE_FE_TRAP_STALL && !V_EXE_FE_TRAP_STALL && !V_MEM_FE_TRAP_STALL && !V_WB_FE_TRAP_STALL && !DE_Context_Switch && !OUT_DE_CS) begin
        DE_NPC <= FE_PC + 64'd4;
        DE_PC <= FE_PC;
        DE_IR <= FE_instruction;
        DE_V <= !V_DE_FE_BR_STALL && !V_EXE_FE_BR_STALL && !V_MEM_FE_BR_STALL && !V_OUT_FE_BR_STALL;  
    end else if(V_DE_FE_TRAP_STALL || OUT_DE_CS || FE_IAM)begin
        DE_V <= 1'b0;
    end else if(V_DE_FE_TRAP_STALL || OUT_DE_CS || FE_IAM)begin
        DE_V <= 1'b0;
    end
end

instruction_cache a0 (.PC(FE_PC), .instruction(FE_instruction), .CLK(CLK), .RESET(RESET));

endmodule