
`timescale 1ns / 1ps
module instruction_cache (
    input CLK,
    input RESET,
    input [63:0] PC,
    output [31:0] instruction
);
// reg [63:12] cacheAddress;
//Page Size of 2^4 byte sized elements
//Memory Currently Loops. As a result, a fake halt instruction is needed.
`define fe_memSize 1023
`define fe_bitMemSize 9
reg [7:0] memory [`fe_memSize:0];
integer i;

always @(posedge CLK) begin
    if (RESET) begin
        for(i = 0; i < `fe_memSize + 1; i = i + 1) begin
            memory[i] = 'd0;
        end

        $readmemh("instructions.mem", memory);

        //Add instructions at desired addresses
        //ADDI R1, R1, #5
        // memory[0] <= 8'h93;
        // memory[1] <= 8'h80;
        // memory[2] <= 8'h50;
        // memory[3] <= 8'h00;
        // //LB R2, R1
        // memory[4] <= 8'h3;
        // memory[5] <= 8'h10;
        // memory[6] <= 8'h22;
        // memory[7] <= 8'h00;
        //JAL R0, #-4
        // memory[4] <= 8'h6F;
        // memory[5] <= 8'hF0;
        // memory[6] <= 8'hDF;
        // memory[7] <= 8'hFF;
    end
end
// assign icache_r = (PC[63:12] == cacheAddress) ? 'd1 : 'd0;
assign instruction = {memory[{PC[`fe_bitMemSize:2],2'b11}], memory[{PC[`fe_bitMemSize:2],2'b10}], memory[{PC[`fe_bitMemSize:2],2'b01}], memory[{PC[`fe_bitMemSize:2],2'b00}]};

//add in code to talk to memory bus


endmodule