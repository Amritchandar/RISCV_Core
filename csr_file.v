`timescale 1ns / 1ps

module csr_file(
    input [11:0] DR,
    input [11:0] SR,
    input [63:0] DATA,
    input [31:0] IR,
    input ST_REG,               //stores data to csr file when high
    input CS,                   //signals when a context switch occurs
    input [63:0] CAUSE,         //cause of interrupt/exception
    input [63:0] SAVE_PC,
    output [63:0] OUT,
    output reg [63:0] PC_OUT,
    output reg DE_CS,
    input CLK,
    input RESET,
    output reg [1:0] PRIVILEGE, //current privilege mode
    output IE
);

parameter ustatus = 12'h000;
parameter sstatus = 12'h100;
parameter mstatus = 12'h300;
parameter misa = 12'h301;
parameter medeleg = 12'h302;
parameter mideleg = 12'h303;
parameter mie = 12'h304;
parameter mtvec = 12'h305;
parameter mepc = 12'h341;
parameter mcause = 12'h342;
parameter mip = 12'h344;



reg [63:0] regFile [4095:0];
wire [1:0] RETURN_PRIVILEGE;    
wire [31:0] RET;
wire        interrupt_enable;

assign RETURN_PRIVILEGE = PRIVILEGE == 2'b11 ? regFile[mstatus][12:11]:{1'b0,regFile[mstatus][8]};  //status register contains return privilege
assign RET = {2'b0,PRIVILEGE,28'h0200073};                                                          //return instruction based on privilege
assign interrupt_enable = regFile[mstatus][PRIVILEGE];                                              //global interrupts enabled
assign IE = IR == RET ? 1:regFile[mstatus][PRIVILEGE];
assign OUT = (RESET) ? 'd0: regFile[SR];

integer i;
always @(posedge CLK) begin
    if(RESET)begin
        PRIVILEGE <= 0; //user mode
        PC_OUT <= 0;
        DE_CS <= 0;
        
        for(i = 0; i < 4096; i= i+1)  //synchronous reset for CSR file
        begin
            if(i == misa)begin
                regFile[misa] <= 64'h2000000002041100;
            end
            else if(i == mtvec)begin
                regFile[mtvec] <= 64'h0000000000000000;     //vector table located at mem 0x0
            end
            else if(i == mstatus)begin
                regFile[mstatus] <= 64'h0000000000000001;   //enable user interrupts
            end
            else begin
                regFile[i] <= 64'd0;
            end
            
        end
    end
    else if(CS)begin
        if(interrupt_enable)begin
            regFile[mcause] <= CAUSE;                           //MCause register set
            PC_OUT <= regFile[mtvec] + (4*(0));                 //trap address in vector table (replace 0 with CAUSE[3:0])
            regFile[mstatus][12:11] <= PRIVILEGE;               //setting Mstatus.mpp
            regFile[mstatus][7] <= regFile[mstatus][PRIVILEGE]; //setting Mstatus.mpie to Mstatus.yie
            regFile[mstatus][3] <= 0;                           //setting Mstatus.mie to 0
            regFile[mepc] <= SAVE_PC;                            //saving PC in MEPC
            PRIVILEGE <= 2'b11;                                 //switching to machine mode
            DE_CS <= 1;
        end
        else if(IR == RET)begin
            regFile[mstatus][RETURN_PRIVILEGE] <= regFile[mstatus][PRIVILEGE+4];  //setting mstatus.yie to mstatus.xpie
            regFile[mstatus][PRIVILEGE+4] <= 1;                                   //setting mstatus.xpie to 1
            PC_OUT <= regFile[mepc];                                              //outputting mepc
            PRIVILEGE <= RETURN_PRIVILEGE;                                        //reseting the privilige
            DE_CS <= 1; 
        end
        else begin
            DE_CS <= 0;
        end                                                                                           
    end
    else if(ST_REG)begin
        regFile[DR] <= DATA;
        DE_CS <= 0;
    end
    else begin
        DE_CS <= 0;
    end

end




endmodule