
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

        $readmemh("instructions.txt", memory);
        
    end
end
// assign icache_r = (PC[63:12] == cacheAddress) ? 'd1 : 'd0;
assign instruction = {memory[{PC[`fe_bitMemSize:2],2'b11}], memory[{PC[`fe_bitMemSize:2],2'b10}], memory[{PC[`fe_bitMemSize:2],2'b01}], memory[{PC[`fe_bitMemSize:2],2'b00}]};

//add in code to talk to memory bus


endmodule