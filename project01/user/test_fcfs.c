#include "kernel/types.h"
#include "user/user.h"

#define NUM_CHILDREN 4

int main() {
  int pid;
  fprintf(2, "=== FCFS Scheduler Test ===\n");

  for (int i = 0; i < NUM_CHILDREN; i++) {
    pid = fork();
    if (pid == 0) {
      int pid_child = getpid();
      fprintf(1, "process %d finished\n", pid_child);
      exit(0);
    }
  }
  while (wait(0) != -1);

  exit(0);
}
