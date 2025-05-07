# Initial process that execs /init.
# This code runs in user space.

#include "syscall.h"

# exec(init, argv)
.globl start
start:
        # use $a0, $a1 for arguments
        la a0, init
        la a1, argv
        # loads the number for the exec system call (=sys_exec) into register a7
        li a7, SYS_exec
        # to re-enter the kernel
        ecall 

# for(;;) exit();
exit:
        li a7, SYS_exit
        ecall
        jal exit

# char init[] = "/init\0";
init:
  .string "/init\0"

# char *argv[] = { init, 0 };
.p2align 2
argv:
  .quad init
  .quad 0
