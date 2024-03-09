//This file contains the machine vector table
//


.section .text
.global m_vector_table

m_vector_table:
//exceptions
                j IAM           //instruction address misaligned 
                j IAF           //instruction access fault
                j II            //illegal instruction
                addi x0, x0, 0  //impliment breakpoint
                j LAM           //load access misaligned
                j LAF           //load access fault
                j SAM           //store address misaligned
                j SAF           //store access fault
                j ECALL         //software machine ECALL
//interrupts                
                addi x0, x0, 0        
                addi x0, x0, 0         
                addi x0, x0, 0          
                addi x0, x0, 0
                addi x0, x0, 0         
                addi x0, x0, 0         
                addi x0, x0, 0         
                addi x0, x0, 0         
                j EXTERNAL      //external interrupt (UART)       

ECALL:
                
                save_context
                addi r10, r10, 5 
                restore_context

.macro save_context

                sw x8, x2, 0
                addi x2, x2, 4
                sw x9, x2, 0
                addi x2, x2, 4
                sw x18, x2, 0
                addi x2, x2, 4
                sw x19, x2, 0
                addi x2, x2, 4
                sw x20, x2, 0
                addi x2, x2, 4
                sw x21, x2, 0
                addi x2, x2, 4
                sw x22, x2, 0
                addi x2, x2, 4
                sw x23, x2, 0
                addi x2, x2, 4
                sw x24, x2, 0
                addi x2, x2, 4
                sw x25, x2, 0
                addi x2, x2, 4
                sw x26, x2, 0
                addi x2, x2, 4
                sw x27, x2, 0
                addi x2, x2, 4

.endm

.macro restore_context

                ldw x2, x27, 0
                addi x2, x2, -4
                ldw x2, x26, 0
                addi x2, x2, -4
                ldw x2, x25, 0
                addi x2, x2, -4
                ldw x2, x24, 0
                addi x2, x2, -4
                ldw x2, x23, 0
                addi x2, x2, -4
                ldw x2, x22, 0
                addi x2, x2, -4
                ldw x2, x21, 0
                addi x2, x2, -4
                ldw x2, x20, 0
                addi x2, x2, -4
                ldw x2, x19, 0
                addi x2, x2, -4
                ldw x2, x18, 0
                addi x2, x2, -4
                ldw x2, x9, 0
                addi x2, x2, -4
                ldw x2, x8, 0
                addi x2, x2, -4
.endm


