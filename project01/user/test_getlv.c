#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  int lv = getlev();
  if(lv == 99){
    fprintf(2, "System is in FCFS mode.\n");
  }
  else{
    fprintf(1, "Now process running in level %d.\n", lv);
  }
 
  exit(0);
}
