module tb_top();
reg CLK, RESET;
wire [63:0] MEM_Data_Out;
wire MEM_V, MEM_Cst_R_W;
wire [2:0] MEM_Cst_Size;
wire [63:0] MEM_RES, MEM_Address;
top top_level (
    .CLK(CLK),
    .MEM_Data_Out(MEM_Data_Out),
    .RESET(RESET),
    .MEM_V(MEM_V),
    .MEM_Cst_R_W(MEM_Cst_R_W),
    .MEM_Cst_Size(MEM_Cst_Size),
    .MEM_RES(MEM_RES),
    .MEM_Address(MEM_Address)
);
memoryFile m0(
    MEM_V,
    CLK,
    RESET,
    MEM_Cst_R_W,
    MEM_Cst_Size,
    MEM_RES,
    MEM_Address,
    MEM_Data_Out
);
initial begin
    RESET <= 1'b1;
    CLK <= 1'b1;

    #10

    RESET <= 1'b0;
end

always begin
    #5 CLK <= !CLK;
end
endmodule