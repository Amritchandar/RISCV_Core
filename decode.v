module decode_stage(
    input CLK,
    input RESET,
    input [63:0] DE_NPC, // Program Counter
    input [63:0] DE_PC,
    input [31:0] DE_IR, // Instruction 
    input [4:0] EXE_DR, // Destination register in EXE
    input [4:0] MEM_DR,
    input [4:0] WB_DR,
    input [4:0] OUT_DE_DR,
    input [63:0] OUT_DE_Data,
    input OUT_DE_REG_WEN,
    input DE_V, 
    input MEM_V,
    input WB_V,

    input [31:0] OUT_DE_IR,
    input [63:0] OUT_DE_CSR_DATA,
    input [63:0] OUT_DE_CAUSE,
    input        OUT_DE_CS,
    input        OUT_DE_ST_CSR,
    input [63:0] OUT_DE_WB_PC,

    output reg [63:0] ALU1, // First ALU operand
    output reg [63:0] ALU2, // Second ALU operand
    output reg [63:0] TARGET_ADDRESS, // Offset for branch target
    output reg [63:0] MEM_ADDRESS, // Memory address for load/store
    output EXE_Vout, // Output to indicate if the decode stage has a valid instruction
    output reg [31:0] EXE_IR, // Output the instruction to the execute stage
    output reg stall,
    output reg [63:0] EXE_NPC,
    output V_DE_FE_BR_STALL,
    output reg [18:0] EXE_Cst,

    output [1:0] DE_WB_PRIVILEGE,
    output reg [63:0] EXE_RFD,
    output reg [63:0] EXE_CSRFD,
    output V_DE_FE_TRAP_STALL,
    output [63:0] DE_FE_MT_VEC,
    output DE_Context_Switch,
    output IE
);
`define DE_Cst_Unsigned control_signals[18]
wire [18:0] control_signals;
control_store control_store (.address({DE_IR[6:0], DE_IR[14:12], DE_IR[30], DE_IR[25]}), .control_signals(control_signals));

reg EXE_V;
reg cut_trap;
assign EXE_Vout = EXE_V;
assign V_DE_FE_BR_STALL = DE_V && ((DE_IR[6:2] ==5'b11000) || (DE_IR[6:2] ==5'b11001) || (DE_IR[6:2] ==5'b11011));
assign V_DE_FE_TRAP_STALL = (DE_V && DE_IR[19:0] == 20'h00073 && !DE_Context_Switch && IE && !cut_trap) ? 1'd1 : 1'd0;

wire [6:0] opcode = DE_IR[6:0];
wire [4:0] rs1 = DE_IR[19:15];
wire [4:0] rs2 = DE_IR[24:20];
wire [4:0] rd = DE_IR[11:7];
wire [63:0] SAVE_PC = OUT_DE_CAUSE[63] ? DE_NPC:OUT_DE_WB_PC;

reg [63:0] immediate; 
wire [63:0] reg_file_out1; // rs1 content
wire [63:0] reg_file_out2; // rs2 content
wire [63:0] DE_rfd_latch;

register_file register_file (
    .DR(OUT_DE_DR),
    .SR1(rs1),
    .SR2(rs2),
    .WB_DATA(OUT_DE_Data),
    .ST_REG(OUT_DE_REG_WEN),
    .reset(RESET),
    .out_one(reg_file_out1),
    .out_two(reg_file_out2),
    .CLK(CLK)
);

csr_file csr(
    .RESET(RESET),
    .DR(OUT_DE_IR[31:20]),
    .SR(DE_IR[31:20]),
    .IR(DE_IR[31:0]),
    .DATA(OUT_DE_CSR_DATA),
    .ST_REG(OUT_DE_ST_CSR),
    .CS(OUT_DE_CS),
    .CAUSE(OUT_DE_CAUSE),
    .SAVE_PC(SAVE_PC),
    .OUT(DE_rfd_latch),
    .PC_OUT(DE_FE_MT_VEC),
    .CLK(CLK),
    .DE_CS(DE_Context_Switch),
    .PRIVILEGE(DE_WB_PRIVILEGE),
    .IE(IE)
    );

always @(*) begin
    if (DE_V && EXE_V && ((EXE_DR == rs1) || (EXE_DR == rs2)) && !DE_Context_Switch && !V_DE_FE_TRAP_STALL) begin
        stall <= 1'b1;
    end else if (DE_V && MEM_V && ((MEM_DR == rs1) || (MEM_DR == rs2)) && !DE_Context_Switch && !V_DE_FE_TRAP_STALL) begin
        stall <= 1'b1;
    end else if (DE_V && WB_V && ((WB_DR == rs1) || (WB_DR == rs2)) && !DE_Context_Switch && !V_DE_FE_TRAP_STALL) begin
        stall <= 1'b1;
    end else begin
        stall <= 1'b0;
    end
end

always @(posedge CLK) begin
    if (RESET) begin
        EXE_V <= 1'b0;
        cut_trap <= 1'b0;
    end else begin
        if(V_DE_FE_TRAP_STALL)begin
            cut_trap <= 1'b1;
        end
        if(DE_Context_Switch)begin
            cut_trap <= 1'b0;
        end
        EXE_Cst <= control_signals;
        EXE_NPC <= DE_NPC;
        EXE_IR <= DE_IR;
        if (DE_V && EXE_V && ((EXE_DR == rs1) || (EXE_DR == rs2)) && DE_IR[19:0] != 20'h00073) begin
            EXE_V <= 1'b0;
        end else if (DE_V && MEM_V && ((MEM_DR == rs1) || (MEM_DR == rs2)) && DE_IR[19:0] != 20'h00073) begin
            EXE_V <= 1'b0;
        end else if (DE_V && WB_V && ((WB_DR == rs1) || (WB_DR == rs2)) && DE_IR[19:0] != 20'h00073) begin
            EXE_V <= 1'b0;
        end else if (DE_Context_Switch)begin
            EXE_V <= 1'b0;
        end else begin
            EXE_V <= DE_V;
            case (opcode[6:2])

                5'b11100: begin
                    EXE_CSRFD <= DE_rfd_latch;
                    EXE_RFD <= reg_file_out1;
                end
                // I-type (Immediate Instructions)
                //LOAD
                5'b00000: begin
                    // ALU1 <= reg_file_out1; // Base address
                    // ALU2 <= {{52{DE_IR[31]}}, DE_IR[31:20]}; // Offset
                    MEM_ADDRESS <= reg_file_out1 + {{52{DE_IR[31]}}, DE_IR[31:20]}; // Address for load
                end

                //OP-IMM
                5'b00100: begin
                    ALU1 <= reg_file_out1; // Base address
                    ALU2 <= {{52{DE_IR[31]}}, DE_IR[31:20]}; // Offset
                end

                //OP-IMM-32
                5'b00110: begin
                    ALU1 <= {{32{reg_file_out1[31]}}, reg_file_out1[31:0]}; // Base address
                    ALU2 <= {{52{DE_IR[31]}}, DE_IR[31:20]}; // Offset
                end

                // S-type (Store instructions)
                //STORE
                5'b01000: begin
                    ALU1 <= reg_file_out2; // Value to store
                    MEM_ADDRESS <= reg_file_out1 + {{52{DE_IR[31]}}, DE_IR[31:25], DE_IR[11:7]}; // Address for store
                end

                // R-type (ALU operations with two registers)
                //OP
                5'b01100: begin
                    ALU1 <= reg_file_out1;
                    ALU2 <= reg_file_out2;
                end
                //OP-32
                5'b01110: begin
                    if (`DE_Cst_Unsigned)begin
                        ALU1 <= {32'b0, reg_file_out1[31:0]};
                        ALU2 <= {32'b0, reg_file_out2[31:0]};
                    end else begin
                        ALU1 <= {{32{reg_file_out1[31]}}, reg_file_out1[31:0]};
                        ALU2 <= {{32{reg_file_out2[31]}}, reg_file_out2[31:0]};
                    end
                end

                // B-type (Branch instructions)
                //BRANCH
                5'b11000: begin
                    ALU1 <= reg_file_out1;
                    ALU2 <= reg_file_out2;
                    TARGET_ADDRESS <= DE_PC + {{51{DE_IR[31]}}, DE_IR[31], DE_IR[7], DE_IR[30:25], DE_IR[11:8], 1'b0};
                end

                // U-type (Immediate instructions with upper 20 bits)
                //LUI, AUIPC
                5'b01101, 5'b00101: begin
                    ALU1 <= {{32{DE_IR[31]}}, DE_IR[31:12], {12{1'b0}}};
                    ALU2 <= 64'd0;
                end

                // J-typ (Jump Instructions)
                //JAL
                5'b11011: begin
                    ALU1 <= DE_NPC;
                    // ALU2 <= {{44{DE_IR[31]}}, DE_IR[19:12], DE_IR[20], DE_IR[30:21], 1'b0};
                    TARGET_ADDRESS <= DE_PC + {{44{DE_IR[31]}}, DE_IR[19:12], DE_IR[20], DE_IR[30:21], 1'b0};
                end

                // JALR
                5'b11001: begin
                    ALU1 <= DE_NPC;
                    // ALU2 <= {{44{DE_IR[31]}}, DE_IR[19:12], DE_IR[20], DE_IR[30:21], 1'b0};
                    TARGET_ADDRESS <= reg_file_out1 + {{56{DE_IR[11]}}, DE_IR[11:0]};
                end
            endcase
        end
    end
end
endmodule
