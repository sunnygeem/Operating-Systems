#include "kernel/types.h"
#include "user/user.h"

#define NUM_LOOP 100000
#define NUM_YIELD 20000
#define NUM_SLEEP 500

#define NUM_THREAD 4
#define MAX_LEVEL 3
int parent;

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


int fork_children2()
{
  int i, p;
  for (i = 0; i < NUM_THREAD; i++)
  {
    if ((p = fork()) == 0)
    {
      int pid = getpid();
      fprintf(1, "before sleep pid: %d, lv: %d\n", pid, getlev());
      sleep(5);
      fprintf(1, "after sleep pid: %d, lv: %d\n", pid, getlev());
      return getpid();
    }
    else
    {
      setpriority(p, i);
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

int main(int argc, char* argv[])
{
  parent = getpid();

  fprintf(1, "MLFQ test start\n");
  int i = 0, pid = 0;
  int count[MAX_LEVEL] = { 0, 0, 0 };
  char cmd = argv[1][0];
  switch (cmd) {
  case '1':
    fprintf(1, "[Test 1] default\n");
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
    fprintf(1, "[Test 1] finished\n");
    break;

  case '2':
    fprintf(1, "[Test 2] yield\n");
    pid = fork_children2();

    if (pid != parent)
    {
      for (i = 0; i < NUM_YIELD; i++)
      {
        int x = getlev();
        if (x < 0 || x > 2)
        {
          fprintf(1, "Wrong level: %d\n", x);
          exit(0);
        }
        count[x]++;
        yield();
      }
      fprintf(1, "Process %d\n", pid);
      for (i = 0; i < MAX_LEVEL; i++)
        fprintf(1, "Process %d , L%d: %d\n", pid, i, count[i]);

    }
    exit_children();
    fprintf(1, "[Test 2] finished\n");
    break;

  case '3':
    fprintf(1, "[Test 3] sleep\n");
    pid = fork_children2();
    if (pid != parent)
    {
      int my_pid = getpid();
      fprintf(1, "pid: %d fork: %d\n", my_pid, getlev());

      for (i = 0; i < NUM_SLEEP; i++)
      {
        int x = getlev();
        if (x < 0 || x > 2)
        {
          fprintf(1, "Wrong level: %d\n", x);
          exit(0);
        }
        count[x]++;
        sleep(1);
      }
      sleep(my_pid * 3);
      fprintf(1, "Process %d\n", pid);
      for (i = 0; i < MAX_LEVEL; i++)
        fprintf(1, "Process %d , L%d: %d\n", pid, i, count[i]);

    }
    exit_children();
    fprintf(1, "[Test 3] finished\n");
    break;

  default:
    fprintf(1, "wrong cmd\n");
    break;
  }

  fprintf(1, "done\n");
  exit(0);
}
