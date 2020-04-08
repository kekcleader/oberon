#include <sys/stat.h>

int MakeExecutable(const char *path) {
  chmod(path, 0755); // S_IXUSR | S_IXGRP | S_IROTH
}
