#include <stdio.h>

#if defined(__APPLE__) || defined(__FreeBSD__)
#include <stdlib.h>
#include <sys/sysctl.h>
#include <sys/time.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#elif defined(__linux__)
#include <sys/sysinfo.h>
#endif

int main(void) {
#if defined(__APPLE__) || defined(__FreeBSD__)
  struct timeval boottime;
  size_t len = sizeof(boottime);
  int mib[2] = {CTL_KERN, KERN_BOOTTIME};  // MIB for kern.boottime

  // Retrieve the boottime
  if (sysctl(mib, 2, &boottime, &len, NULL, 0) < 0) {
    perror("sysctl");
    exit(EXIT_FAILURE);
  }

  time_t now;
  time(&now);                                     // Get the current time
  time_t uptime_seconds = now - boottime.tv_sec;  // Calculate uptime in seconds

  printf("%ld\n", uptime_seconds);
  return EXIT_SUCCESS;
#endif

#if defined(__linux__)
  struct sysinfo info;
  sysinfo(&info);
  printf("%ld\n", info.uptime);
#endif
}
