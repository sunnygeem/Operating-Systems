#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  yield();
  fprintf(1, "yield complete.\n");

  exit(0);
}
