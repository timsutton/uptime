#include <cerrno>
#include <chrono>
#include <cstdlib>
#include <cstring>
#include <iostream>

#if defined(__APPLE__) || defined(__FreeBSD__)
#include <sys/sysctl.h>
#include <sys/time.h>
#include <sys/types.h>
#elif defined(__linux__)
#include <sys/sysinfo.h>
#else
#error "Unsupported platform"
#endif

int main() {
  std::chrono::seconds uptime;

#if defined(__APPLE__) || defined(__FreeBSD__)
  struct timeval boot_time{};
  std::size_t size = sizeof(boot_time);
  int mib[] = {CTL_KERN, KERN_BOOTTIME};

  if (sysctl(mib, 2, &boot_time, &size, nullptr, 0) < 0) {
    std::cerr << "sysctl: " << std::strerror(errno) << '\n';
    return EXIT_FAILURE;
  }

  const auto boot = std::chrono::system_clock::from_time_t(boot_time.tv_sec) +
                    std::chrono::microseconds(boot_time.tv_usec);
  uptime = std::chrono::duration_cast<std::chrono::seconds>(
      std::chrono::system_clock::now() - boot);
#elif defined(__linux__)
  struct sysinfo info{};
  if (sysinfo(&info) < 0) {
    std::cerr << "sysinfo: " << std::strerror(errno) << '\n';
    return EXIT_FAILURE;
  }

  uptime = std::chrono::seconds(info.uptime);
#endif

  std::cout << uptime.count() << '\n';
  return EXIT_SUCCESS;
}
