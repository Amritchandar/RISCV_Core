`timescale 1ns / 1ps
module memoryFile (
    input MEM_V,
    input CLK,
    input RESET,
    input r_w,
    input [1:0] size,
    input [63:0] data_in,
    input [63:0] address,
    output [63:0] data_out
);
// reg [63:12] cacheAddress;
`define memSize 15
//Page Size of 2^12 byte sized elements
reg [7:0] memory [`memSize:0];
`define numInstructions 2*4

integer i;
always @(posedge CLK) begin
    if (RESET) begin
        //Contains instructions to be loaded in
        memory[0] <= 8'h01;
        memory[1] <= 8'h02;
        memory[2] <= 8'h03;
        memory[3] <= 8'h04;
        memory[4] <= 8'h01;
        memory[5] <= 8'h02;
        memory[6] <= 8'h03;
        memory[7] <= 8'h04;

        for(i = `numInstructions; i < `memSize + 1; i = i + 1) begin
            memory[i] = 'd0;
        end
    end else begin
        //Memory storing mechanism
        if (r_w && MEM_V) begin
            if (size == 2'b00) begin
                memory[{address[3], 3'b000}] <= data_in[7:0];
            end else if (size == 2'b01) begin
                memory[{address[3], 3'b001}] <= data_in[15:8];
                memory[{address[3], 3'b000}] <= data_in[7:0];
            end else if (size == 2'b10) begin
                memory[{address[3], 3'b011}] <= data_in[31:24];
                memory[{address[3], 3'b010}] <= data_in[23:16];
                memory[{address[3], 3'b001}] <= data_in[15:8];
                memory[{address[3], 3'b000}] <= data_in[7:0];
            end else if (size == 2'b11) begin
                memory[{address[3], 3'b111}] <= data_in[63:56];
                memory[{address[3], 3'b110}] <= data_in[55:48];
                memory[{address[3], 3'b101}] <= data_in[47:40];
                memory[{address[3], 3'b100}] <= data_in[39:32];
                memory[{address[3], 3'b011}] <= data_in[31:24];
                memory[{address[3], 3'b010}] <= data_in[23:16];
                memory[{address[3], 3'b001}] <= data_in[15:8];
                memory[{address[3], 3'b000}] <= data_in[7:0];
            end
        end
    end
end

//Data output upon read
assign data_out = ((r_w && MEM_V) == 1'b0) ? {memory[{address[3],3'b111}], memory[{address[3],3'b110}], memory[{address[3],3'b101}], memory[{address[3],3'b100}], memory[{address[3],3'b011}], memory[{address[3],3'b010}], memory[{address[3],3'b001}], memory[{address[3],3'b000}]}: 64'bz;;

endmodule