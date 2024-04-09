.section .text
.global m_vector_table

m_vector_table:
#exceptions
                j IAM           #instruction address misaligned 
                j IAF           #instruction access fault
                j II            #illegal instruction
                addi x0, x0, 0  #impliment breakpoint
                j LAM           #load access misaligned
                j LAF           #load access fault
                j SAM           #store address misaligned
                j SAF           #store access fault
                j ECALL         #software machine ECALL
#interrupts                
                addi x0, x0, 0        
                addi x0, x0, 0         
                addi x0, x0, 0          
                addi x0, x0, 0
                addi x0, x0, 0         
                addi x0, x0, 0         
                addi x0, x0, 0         
                addi x0, x0, 0         
                j EXTERNAL      #external interrupt (UART)       



IAM:
                jal ra, save_context
                addi x10, x10, 5 
                jal ra, restore_context
IAF:
                jal ra, save_context
                addi x10, x10, 5 
                jal ra, restore_context
II:
                jal ra, save_context
                addi x10, x10, 5 
                jal ra, restore_context
LAM:
                jal ra, save_context
                addi x10, x10, 5 
                jal ra, restore_context
LAF:
                jal ra, save_context
                addi x10, x10, 5 
                jal ra, restore_context
SAM:
                jal ra, save_context
                addi x10, x10, 5 
                jal ra, restore_context
SAF:
                jal ra, save_context
                addi x10, x10, 5 
                jal ra, restore_context
ECALL:
                
                jal ra, save_context
                addi x10, x10, 5 
                jal ra, restore_context

EXTERNAL:
	addi x10, x10, 5


save_context:

                sw x8, 0(x2)
                addi x2, x2, 8
                sw x9, 0(x2)
                addi x2, x2, 8
                sw x18, 0(x2)
                addi x2, x2, 8
                sw x19, 0(x2)
                addi x2, x2, 8
                sw x20, 0(x2)
                addi x2, x2, 8
                sw x21, 0(x2)
                addi x2, x2, 8
                sw x22, 0(x2)
                addi x2, x2, 8
                sw x23, 0(x2)
                addi x2, x2, 8
                sw x24, 0(x2)
                addi x2, x2, 8
                sw x25, 0(x2)
                addi x2, x2, 8
                sw x26, 0(x2)
                addi x2, x2, 8
                sw x27, 0(x2)
                addi x2, x2, 8
                ret



restore_context:

                lw x27, 0(x2)
                addi x2, x2, -8
                lw x26, 0(x2)
                addi x2, x2, -8
                lw x25, 0(x2)
                addi x2, x2, -8
                lw x24, 0(x2)
                addi x2, x2, -8
                lw x23, 0(x2)
                addi x2, x2, -8
                lw x22, 0(x2)
                addi x2, x2, -8
                lw x21, 0(x2)
                addi x2, x2, -8
                lw x20, 0(x2)
                addi x2, x2, -8
                lw x19, 0(x2)
                addi x2, x2, -8
                lw x18, 0(x2)
                addi x2, x2, -8
                lw x9, 0(x2)
                addi x2, x2, -8
                lw x8, 0(x2)
                addi x2, x2, -8
                ret