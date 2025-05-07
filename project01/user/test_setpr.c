#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  int pid = atoi(argv[1]);
  int pr = atoi(argv[2]);

  int ret = setpriority(pid, pr);
  fprintf(1, "setpriority return value: %d\n", ret);
  if(ret == -1){
    fprintf(2, "Cannot find matched pid.\n");
  }
  else if(ret == -2){
    fprintf(2, "Priority value is out of range.\n");
  }
  else{ // ret == 0; default
    fprintf(2, "Setpriority has completed.\n");
  }

  exit(0);
}
