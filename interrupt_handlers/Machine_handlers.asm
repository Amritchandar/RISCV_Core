//This file contains the machine vector table
//


.section .text
.global m_vector_table

m_vector_table:
//exceptions
                j IAM           //instruction address misaligned 
                j IAF           //instruction access fault
                j II            //illegal instruction
                addi r0, r0, 0  //impliment breakpoint
                j LAM           //load access misaligned
                j LAF           //load access fault
                j SAM           //store address misaligned
                j SAF           //store access fault
                j ECALL         //software machine ECALL
//interrupts                
                addi r0, r0, 0        
                addi r0, r0, 0         
                addi r0, r0, 0          
                addi r0, r0, 0
                addi r0, r0, 0         
                addi r0, r0, 0         
                addi r0, r0, 0         
                addi r0, r0, 0         
                j EXTERNAL      //external interrupt (UART)       

IAM:
                


