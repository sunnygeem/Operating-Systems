#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    fprintf(2, "My student ID is 2021011158\n");
    int pid_val = getpid();
    fprintf(1, "My pid is %x\n", pid_val);
    int ppid_val = getppid();
    fprintf(1, "My ppid is %x\n", ppid_val);
    exit(0);
};
