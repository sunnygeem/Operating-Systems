#include "kernel/types.h"
#include "user/user.h"

#define NUM_LOOP 100000
#define NUM_YIELD 20000
#define NUM_SLEEP 500

#define NUM_THREAD 4
#define MAX_LEVEL 3

int parent;

char cmd;

int fork_children()
{
  int i, p;
  for (i = 0; i < NUM_THREAD; i++) {
    p = fork();
    if (p == 0)
    {
      sleep(10);
      return getpid();
    }
  }
  return parent;
}

void exit_children()
{
  if (getpid() != parent) {
    exit(0);
  }
  while (wait(0) != -1);
}

int main(int argc, char* argv[]) {
    fprintf(1, "Switching mode to ");
    cmd = argv[1][0];

    int ret = 1;

    if(cmd == '0'){
        fprintf(1, "FCFS mode\n");
        ret = fcfsmode();
    }
    else if(cmd == '1'){
        fprintf(1, "MLFQ mode\n");
        ret = mlfqmode();
    }

    if(ret == 0){
        if(cmd == '1'){
            parent = getpid();

            int i = 0, pid = 0;
            int count[MAX_LEVEL] = { 0, 0, 0 };

            pid = fork_children();

            if (pid != parent)
            {
            for (i = 0; i < NUM_LOOP; i++)
            {
                int x = getlev();
                if (x < 0 || x > 2)
                {
                fprintf(1, "Wrong level: %d\n", x);
                exit(0);
                }
                count[x]++;
            }
            fprintf(1, "Process %d\n", pid);
            for (i = 0; i < MAX_LEVEL; i++)
                fprintf(1, "Process %d , L%d: %d\n", pid, i, count[i]);
            }
            exit_children();
        }
        else if(cmd == '0'){
            int pid;
            fprintf(2, "=== FCFS Scheduler Test ===\n");

            for (int i = 0; i < NUM_THREAD; i++) {
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
        
    }
    else if(ret == -1){
        fprintf(1, "System is already in %c mode", cmd);
    }

    return 0;
}
