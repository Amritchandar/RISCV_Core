`timescale 1ns / 1ps

module csr_file(
    input [11:0] DR,
    input [11:0] SR,
    input [63:0] DATA,
    input [31:0] IR,
    input ST_REG,               //stores data to csr file when high
    input CS,                   //signals when a context switch occurs
    input [63:0] CAUSE,         //cause of interrupt/exception
    input [63:0] DE_NPC,
    output [63:0] OUT,
    output reg [63:0] PC_OUT,
    output reg DE_CS,
    input CLK,
    input RESET,
    output [1:0] PRIVILEGE_OUT
);

parameter ustatus = 12'h000;
parameter sstatus = 12'h100;
parameter mstatus = 12'h300;
parameter misa = 12'h301;
parameter medeleg = 12'h302;
parameter medeleg = 12'h303;
parameter mie = 12'h304;
parameter mtvec = 12'h305;
parameter mepc = 12'h341;
parameter mcause = 12'h342;
parameter mip = 12'h344;



reg [63:0] regFile [4095:0];
reg [1:0]  PRIVILEGE;   //holds the privilege mode for the current thread
wire [1:0] RETURN_PRIVILEGE;
wire [31:0] RET;

assign RETURN_PRIVILEGE = regFile[{2'b00,PRIVILEGE,8'h00}][12:11];  //status register contains return privilege
assign RET = {2'b0,PRIVILEGE,28'h0200073};
assign PRIVILEGE_OUT = PRIVILEGE;

always @(posedge CLK) begin
    if(CS)begin
        regFile[mcause] <= CAUSE;                                 //MCause register set
        PC_OUT <= regFile[mtvec] + (4*(CAUSE[12:0]));             //trap address in vector table
        regFile[mstatus][12:11] <= PRIVILEGE;                     //setting Mstatus.mpp
        regFile[mstatus][1'h7] <= regFile[{mstatus}][PRIVILEGE]; //setting Mstatus.mpie to Mstatus.yie
        regFile[mstatus][1'h3] <= 0;                              //setting Mstatus.mie to 0
        regFile[mepc] <= DE_NPC;                                  //saving PC in MEPC
        PRIVILEGE <= 2'b11;                                       //switching to machine mode
        DE_CS <= 1;                                                                                                 
    end
    else if(IR == RET)begin
        regFile[{2'b0,PRIVILEGE,8'h00}][RETURN_PRIVILEGE] <= regFile[{2'b0,PRIVILEGE,8'h00}][PRIVILEGE+4];  //setting _status.yie to _status.xpie
        regFile[{2'b0,PRIVILEGE,8'h00}][PRIVILEGE+4] <= 1;                                                  //setting _status.xie to 1
        PC_OUT <= regFile[{2'b0,PRIVILEGE,8'h41}];                                                          //outputting _epc
        PRIVILEGE <= RETURN_PRIVILEGE;                                                                      //reseting the privilige
        DE_CS <= 1;                                                                                                 

    end

end

integer i;
always @(posedge CLK)begin
    if(RESET)begin
        PRIVILEGE <= 0;
        PC_OUT <= 0;
        DE_CS <= 0;
        //TODO: reset misa and mhartid registers

        for(i = 0; i < 4096; i= i+1)  //synchronous reset for CSR file
        begin
            if(i == misa)begin
                regFile[misa] <= 64'h2000000002041100;
            end
            else if(i == )
            regFile[i] <= 64'd0;
        end 
    end
    else if(ST_REG)begin
        regFile[DR] <= DATA;
    end

end

 assign OUT = (RESET) ? 'd0: regFile[SR];

endmodule