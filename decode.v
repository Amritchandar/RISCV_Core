module decode_stage(
    input [63:0] DE_NPC, // Program Counter
    input [31:0] DE_IR, // Instruction 
    input DE_V, 
    output reg [63:0] ALU1, // First ALU operand
    output reg [63:0] ALU2, // Second ALU operand
    output reg [63:0] TARGET_ADDRESS, // Offset for branch target
    output reg [63:0] MEM_ADDRESS, // Memory address for load/store
    output EXE_Vout, // Output to indicate if the decode stage has a valid instruction
    output reg [31:0] EXE_IR, // Output the instruction to the execute stage
    output reg stall,
    input [4:0] EXE_RD, // Destination register in EXE
    // input EXE_WB_EN, // Write-back enable signal for the Execute stage - 
                     // indicates whether the execute stage's instruction will write back to a register
);
    reg EXE_V;
    assign EXE_Vout = EXE_V;
    wire [6:0] opcode = DE_IR[6:0];
    wire [4:0] rs1 = DE_IR[19:15];
    wire [4:0] rs2 = DE_IR[24:20];
    wire [4:0] rd = DE_IR[11:7];

    reg [63:0] immediate; // Immediate value for ALU operations

    // Get register file outputs
    wire [63:0] reg_file_out1; // rs1 content
    wire [63:0] reg_file_out2; // rs2 content

    always @(*) begin
        // Default outputs to zero and valid to DE_V
        stall = 0; // Default to no stall
        EXE_V = DE_V; // Propagate the valid bit
        EXE_IR = DE_IR; // Latch the instruction to the execute stage

        ALU1 = 64'd0;
        ALU2 = 64'd0;
        immediate = 64'd0;
        TARGET_ADDRESS = 64'd0;
        MEM_ADDRESS = 64'd0;

        if (EXE_V && ((EXE_RD == rs1) || (EXE_RD == rs2))) begin
            // Stall due to dependency with the execute stage instruction
            stall = 1;
            EXE_V = 0; // Invalidate this stage's output due to stall
        end else if (!stall && DE_V) begin // Process the instruction if it is valid
            case (opcode)
                // I-type (Load instructions)
                7'b0000011: begin
                    immediate = {{52{DE_IR[31]}}, DE_IR[31:20]};
                    ALU1 = reg_file_out1; // Base address
                    ALU2 = immediate; // Offset
                    MEM_ADDRESS = reg_file_out1 + immediate; // Address for load
                end

                // S-type (Store instructions)
                7'b0100011: begin
                    immediate = {{52{DE_IR[31]}}, DE_IR[31:25], DE_IR[11:7]};
                    ALU1 = reg_file_out1; // Base address
                    ALU2 = reg_file_out2; // Value to store
                    MEM_ADDRESS = reg_file_out1 + immediate; // Address for store
                end

                // R-type (ALU operations with two registers)
                7'b0110011: begin
                    ALU1 = reg_file_out1;
                    ALU2 = reg_file_out2;
                end

                // B-type (Branch instructions)
                7'b1100011: begin
                    immediate = {{51{DE_IR[31]}}, DE_IR[31], DE_IR[7], DE_IR[30:25], DE_IR[11:8], 1'b0};
                    ALU1 = reg_file_out1;
                    ALU2 = reg_file_out2;
                    TARGET_ADDRESS = DE_NPC + immediate;
                end

                // U-type (Immediate instructions with upper 20 bits)
                7'b0110111, 7'b0010111: begin
                    immediate = {{32{DE_IR[31]}}, DE_IR[31:12], {12{1'b0}}};
                    ALU1 = immediate;
                    ALU2 = 64'd0;
                end

                // J-type (Jump instructions)
                7'b1101111: begin
                    immediate = {{43{DE_IR[31]}}, DE_IR[19:12], DE_IR[20], DE_IR[30:21], 1'b0};
                    ALU1 = DE_NPC;
                    ALU2 = immediate;
                    TARGET_ADDRESS = DE_NPC + immediate;
                end

                default: begin
                    // Default case to handle unknown opcodes or no operation
                    ALU1 = 64'd0;
                    ALU2 = 64'd0;
                    immediate = 64'd0;
                    TARGET_ADDRESS = 64'd0;
                    MEM_ADDRESS = 64'd0;
                    EXE_V = 1'b0; // Invalidate the output if the opcode is unknown
                    EXE_IR = 32'd0;
                end
            endcase
        end else begin
            // Invalidate the outputs if the instruction is not valid
            EXE_IR = 32'd0;
        end
    end

endmodule
