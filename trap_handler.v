`timescale 1ns / 1ps

module trap_handler(
    input         CLK,
    input         ECALL,
    input         F_IAM,
    input         F_IAF,
    input         F_II,
    input         MEM_LAM,
    input         MEM_LAF,
    input         MEM_SAM,
    input         MEM_SAF,
    input         TIMER,
    input         EXTERNAL,
    input  [1:0]  PRIVILEGE,
    input  [31:0] WB_IR,
    input RET_INST,
    output reg [63:0] CAUSE,
    output reg       CS
    
);


always@(posedge CLK)begin
    if(F_IAM)begin
        CS <= 1;
        CAUSE <= 0;
    end
    else if(F_IAF)begin
        CS <= 1;
        CAUSE <= 1;
    end
    else if(F_II)begin
        CS <= 1;
        CAUSE <= 2;
    end
    else if(MEM_LAM)begin
        CS <= 1;
        CAUSE <= 4;
    end
    else if(MEM_LAF)begin
        CS <= 1;
        CAUSE <= 5;
    end
    else if(MEM_SAM)begin
        CS <= 1;
        CAUSE <= 6;
    end
    else if(MEM_SAF)begin
        CS <= 1;
        CAUSE <= 7;
    end
    else if(ECALL)begin
        CS <= 1;
        CAUSE <= {1'b1,59'b0,4'h8};
    end
    else if(TIMER)begin
        CS <= 1;
        CAUSE <= {1'b1,60'b0,PRIVILEGE+4};
    end
    else if(EXTERNAL)begin
        CS <= 1;
        CAUSE <= {1'b1,59'b0,PRIVILEGE+8};
    end
    else if(RET_INST)begin
        CS <= 1;
    end 
    else begin
        CS <= 0;
    end
end

endmodule