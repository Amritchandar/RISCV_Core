module tb_top();
reg CLK, RESET, INTERRUPT;

top top_level (
    .CLK(CLK),
    .RESET(RESET),
    .INTERRUPT(INTERRUPT)
);

initial begin
    RESET <= 1'b1;
    CLK <= 1'b1;
    INTERRUPT <= 1'b0;

    #10

    RESET <= 1'b0;
end

always begin
    #5 CLK <= !CLK;
end
endmodule