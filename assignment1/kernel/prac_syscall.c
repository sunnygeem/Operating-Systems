#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

// Simple system call
int myfunction(char *str) {
    printf("%s\n", str);    
    return 0xABCDABCD;
}

int sys_myfunction(void) {
    char str[100];
    //Decode argument using argstr
    if (argstr(0, str, 100) < 0) return -1;
    return myfunction(str);
}

// assignment1
// system call: get parent process id 
int sys_getppid(void){
    return myproc()->parent->pid;
}
