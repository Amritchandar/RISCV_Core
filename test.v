`timescale 1ns/1ps
module test();
reg CLK;
reg [7:0] A, B;
reg [15:0] out1;
reg [7:0] out2;
initial begin
    A <= -8'd100;
    B <= 8'd100;
    CLK <= 1'b1;
end
always @(posedge CLK)begin
    out1 <= $signed(A) + $signed(B);
    out2 <= ($signed(A) * $signed(B));
end
always begin
    #5 CLK <= !CLK;
end
endmodule