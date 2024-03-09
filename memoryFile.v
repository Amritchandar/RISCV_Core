`timescale 1ns / 1ps
module memoryFile (
    input MEM_V,
    input CLK,
    input RESET,
    input r_w,
    input [2:0] size,
    input [63:0] data_in,
    input [63:0] address,
    output reg [63:0] data_out
);
// reg [63:12] cacheAddress;
`define memSize 1023
`define bitMemSize 9
//Page Size of 2^12 byte sized elements
reg [7:0] memory [`memSize:0];

integer i;
always @(posedge CLK) begin
    if (RESET) begin
        for(i = 0; i < `memSize + 1; i = i + 1) begin
            memory[i] = 'd0;
        end
        //Contains memory to be loaded in
        $readmemh("data.txt", memory);
        // memory[0] <= 8'h01;
        // memory[1] <= 8'h02;
        // memory[2] <= 8'h03;
        // memory[3] <= 8'h04;
        // memory[4] <= 8'h01;
        // memory[5] <= 8'h02;
        // memory[6] <= 8'h03;
        // memory[7] <= 8'h04;
    end else begin
        //Memory storing mechanism
        if (r_w && MEM_V) begin
            if (size == 2'b00) begin
                memory[{address[`bitMemSize:3], 3'b000}] <= data_in[7:0];
            end else if (size == 2'b01) begin
                memory[{address[`bitMemSize:3], 3'b001}] <= data_in[15:8];
                memory[{address[`bitMemSize:3], 3'b000}] <= data_in[7:0];
            end else if (size == 2'b10) begin
                memory[{address[`bitMemSize:3], 3'b011}] <= data_in[31:24];
                memory[{address[`bitMemSize:3], 3'b010}] <= data_in[23:16];
                memory[{address[`bitMemSize:3], 3'b001}] <= data_in[15:8];
                memory[{address[`bitMemSize:3], 3'b000}] <= data_in[7:0];
            end else if (size == 2'b11) begin
                memory[{address[`bitMemSize:3], 3'b111}] <= data_in[63:56];
                memory[{address[`bitMemSize:3], 3'b110}] <= data_in[55:48];
                memory[{address[`bitMemSize:3], 3'b101}] <= data_in[47:40];
                memory[{address[`bitMemSize:3], 3'b100}] <= data_in[39:32];
                memory[{address[`bitMemSize:3], 3'b011}] <= data_in[31:24];
                memory[{address[`bitMemSize:3], 3'b010}] <= data_in[23:16];
                memory[{address[`bitMemSize:3], 3'b001}] <= data_in[15:8];
                memory[{address[`bitMemSize:3], 3'b000}] <= data_in[7:0];
            end
        end
    end
end

always @(*)begin
    if (!r_w && MEM_V) begin
        if (size == 3'd0) begin
            data_out = {56'd0, memory[{address[`bitMemSize:3],3'b000}]};
        end else if (size == 3'd1) begin
            data_out = {48'd0, memory[{address[`bitMemSize:3],3'b001}], memory[{address[`bitMemSize:3],3'b000}]};
        end else if (size == 3'd2) begin
            data_out = {32'd0, memory[{address[`bitMemSize:3],3'b011}], memory[{address[`bitMemSize:3],3'b010}], memory[{address[`bitMemSize:3],3'b001}], memory[{address[`bitMemSize:3],3'b000}]};
        end else if (size == 3'd3) begin
            data_out = {48'd0, memory[{address[`bitMemSize:3],3'b001}], 8'd0}; 
        end else if (size == 3'd4) begin
            data_out = {32'd0, memory[{address[`bitMemSize:3],3'b011}], memory[{address[`bitMemSize:3],3'b010}], 16'd0};
        end else if (size == 3'd5) begin
            data_out = {memory[{address[`bitMemSize:3],3'b011}], memory[{address[`bitMemSize:3],3'b010}], memory[{address[`bitMemSize:3],3'b001}], memory[{address[`bitMemSize:3],3'b000}], 32'd0};
        end else if (size == 3'd6) begin
            data_out = {memory[{address[`bitMemSize:3],3'b111}], memory[{address[`bitMemSize:3],3'b110}], memory[{address[`bitMemSize:3],3'b101}], memory[{address[`bitMemSize:3],3'b100}], memory[{address[`bitMemSize:3],3'b011}], memory[{address[`bitMemSize:3],3'b010}], memory[{address[`bitMemSize:3],3'b001}], memory[{address[`bitMemSize:3],3'b000}]};
        end
    end
end

endmodule