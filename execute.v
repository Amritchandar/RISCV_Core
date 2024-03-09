`timescale 1ns / 1ps
module  execute (
    input CLK,
    input RESET,
    input [63:0] EXE_Address,
    input [63:0] EXE_ALU1,
    input [63:0] EXE_ALU2,
    input [31:0] EXE_IR,
    input [18:0] EXE_Cst,
    input [63:0] EXE_NPC,
    input [63:0] EXE_Target_Address,
    input EXE_V,
    output reg MEM_V,
    output reg [63:0] MEM_Target_Address,
    output reg [18:0] MEM_Cst,
    output reg [63:0] MEM_RES,
    output reg MEM_PC_MUX,
    output reg [31:0] MEM_IR,
    output reg [63:0] MEM_NPC,
    output V_EXE_FE_BR_STALL,
    output reg [63:0] MEM_Address,
    output [4:0] EXE_DR
);

`define EXE_Cst_CMP_JMP EXE_Cst[16:14]
`define EXE_Cst_ALU EXE_Cst[13:10]
`define EXE_Cst_Res_Mux EXE_Cst[9]
`define EXE_Cst_ALU_M EXE_Cst[8:6]
`define EXE_Cst_W EXE_Cst[17]

assign EXE_DR = EXE_IR[11:7];

wire [127:0] EXE_Unsigned_MUL, EXE_Signed_MUL, EXE_Signed_Unsigned_MUL;

assign EXE_Unsigned_MUL = $unsigned(EXE_ALU1) * $unsigned(EXE_ALU2);
assign EXE_Signed_MUL = $signed(EXE_ALU1) * $signed(EXE_ALU2);
assign EXE_Signed_Unsigned_MUL = $signed(EXE_ALU1) * $unsigned(EXE_ALU2);
assign V_EXE_FE_BR_STALL = EXE_V && ((EXE_IR[6:2] ==5'b11000) || (EXE_IR[6:2] ==5'b11001) || (EXE_IR[6:2] ==5'b11011));

always @(posedge CLK) begin
    //Branch Comparisons and jump
    case (`EXE_Cst_CMP_JMP) 
        3'b00: begin
            //BEQ
            MEM_PC_MUX <= ($signed(EXE_ALU1) == $signed(EXE_ALU2));
        end
        3'b001: begin
            //BNE
            MEM_PC_MUX <= ($signed(EXE_ALU1) != $signed(EXE_ALU2));
        end
        3'b010: begin
            //BLT
            MEM_PC_MUX <= ($signed(EXE_ALU1) < $signed(EXE_ALU2));
        end
        3'b011: begin
            //BGE
            MEM_PC_MUX <= ($signed(EXE_ALU1) >= $signed(EXE_ALU2));
        end
        3'b100: begin
            //BLTU
            MEM_PC_MUX <= ($unsigned(EXE_ALU1) < $unsigned(EXE_ALU2));
        end
        3'b101: begin
            //BGEU
            MEM_PC_MUX <= ($unsigned(EXE_ALU1) >= $unsigned(EXE_ALU2));
        end
        3'b110: begin
            //JAL/JALR
            MEM_PC_MUX <= 1'b1;
        end
        3'b111: begin
            MEM_PC_MUX <= 1'b0;
        end
    endcase

    //Arithmetic Operations
    if (!`EXE_Cst_Res_Mux) begin
        case (`EXE_Cst_ALU)
        4'd0: begin
            //ADD
            MEM_RES <= $signed(EXE_ALU1) + $signed(EXE_ALU2);
        end
        4'd1: begin
            //SUB
            MEM_RES <= $signed(EXE_ALU1) - $signed(EXE_ALU2);
        end
        4'd2: begin
            //SLL
            MEM_RES <= EXE_ALU1 << EXE_ALU2[5:0];
        end
        4'd3: begin
            //SLT
            if ($signed(EXE_ALU1) < $signed(EXE_ALU2)) begin
                MEM_RES <= 1'b1;
            end else begin
                MEM_RES <= 1'b0;
            end
        end
        4'd4: begin
            //SLTU
            if ($unsigned(EXE_ALU1) < $unsigned(EXE_ALU2)) begin
                MEM_RES <= 1'b1;
            end else begin
                MEM_RES <= 1'b0;
            end
        end
        4'd5: begin
            //XOR
            MEM_RES <= EXE_ALU1 ^ EXE_ALU2;
        end
        4'd6: begin
            //SRL
            MEM_RES <= EXE_ALU1 >> EXE_ALU2[5:0];
        end
        4'd7: begin
            //SRA
            MEM_RES <= EXE_ALU1 >>> EXE_ALU2[5:0];
        end
        4'd8: begin
            //OR
            MEM_RES <= EXE_ALU1 | EXE_ALU2;
        end
        4'd9: begin
            //AND
            MEM_RES <= EXE_ALU1 & EXE_ALU2;
        end
        4'd10: begin
            //LUI/SB/SH/SW/SD
            MEM_RES <= EXE_ALU1;
        end
        4'd11: begin
            //AUIPC
            MEM_RES <= $signed(EXE_ALU1) + $signed(EXE_NPC);
        end
        4'd12: begin
            //JAL/JALR
            MEM_RES <= EXE_ALU1;
        end
        default: begin
            MEM_RES <= EXE_ALU1;
        end
        endcase
    end else begin
        //Multiplication Extension
        case (`EXE_Cst_ALU_M)
        3'd0: begin
            //MUL
            MEM_RES <= EXE_Signed_MUL[63:0];
        end
        3'd1: begin
            //MULH
            MEM_RES <= EXE_Signed_MUL[127:64];
        end
        3'd2: begin
            //MULHSU
            MEM_RES <= EXE_Signed_Unsigned_MUL[127:64];
        end
        3'd3: begin
            //MULHU
            MEM_RES <= EXE_Unsigned_MUL[127:64];
        end
        3'd4: begin
            //DIV
            if ($signed(EXE_ALU2) == 0) begin
                MEM_RES <= -64'd1;
            end if (((EXE_ALU1 == 64'hFFFF8000) && `EXE_Cst_W) && (EXE_ALU2 == 64'hFFFFFFFF)) begin
                MEM_RES <= 64'hFFFF8000;
            end if (((EXE_ALU1 == 64'h80000000) && !`EXE_Cst_W) && (EXE_ALU2 == 64'hFFFFFFFF)) begin
                MEM_RES <= 64'h80000000;
            end else begin
                MEM_RES <= $signed(EXE_ALU1) / $signed(EXE_ALU2);
            end
        end
        3'd5: begin
            //DIVU
            if ($signed(EXE_ALU2) == 0) begin
                MEM_RES <= 64'hFFFFFFFF;
            end else begin
                MEM_RES <= $unsigned(EXE_ALU1) / $unsigned(EXE_ALU2);
            end
        end
        3'd6: begin
            //REM
            if ($signed(EXE_ALU2) == 0) begin
                MEM_RES <= EXE_ALU1;
            end if ((((EXE_ALU1 == 64'hFFFF8000) && `EXE_Cst_W) || ((EXE_ALU1 == 64'h80000000) && !`EXE_Cst_W)) && (EXE_ALU2 == 64'hFFFFFFFF)) begin
                MEM_RES <= 64'b0;
            end else begin
                MEM_RES <= $signed(EXE_ALU1) % $signed(EXE_ALU2);
            end
        end
        3'd7: begin
            //REMU
            if ($signed(EXE_ALU2) == 0) begin
                MEM_RES <= EXE_ALU1;
            end else begin
                MEM_RES <= $unsigned(EXE_ALU1) % $unsigned(EXE_ALU2);
            end
        end
        endcase
    end
end
always @(posedge CLK) begin
    if (RESET) begin
        MEM_V <= 1'b0;
    end else begin
        MEM_Target_Address <= EXE_Target_Address;
        MEM_Cst <= EXE_Cst;
        MEM_Address <= EXE_Address;
        MEM_V <= EXE_V;
        MEM_NPC <= EXE_NPC;
        MEM_IR <= EXE_IR;
    end
end
endmodule