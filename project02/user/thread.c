#include "kernel/types.h"
#include "user/user.h"
#include "user/thread.h"
#include "kernel/riscv.h"

int thread_create(void (*start_routine)(void *, void *), void *arg1, void *arg2)
{
  //printf("current process for clone: %d\n", getpid());
  // void *stack = sbrk(4096);
  void *stack = malloc(PGSIZE*2);

  if (stack == 0) {
    printf("stack allocation failed\n");
    return -1;
  }

  int tid = clone(start_routine, arg1, arg2, stack);

  if (tid < 0) {
    printf("clone failed\n");
    return -1;
  }

  return tid;
}

int thread_join(){
  //printf("thread join executed\n");
  void *stack;

  int pid = join(&stack);

  if (pid < 0)
    return -1;

  free(stack);

  return pid;
}