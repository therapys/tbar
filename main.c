#include <stdio.h>

#define LOG_MODULE "main"
#include "log.h"
#include "version.h"

int main(int argc, char *const *argv) {
    
  enum log_class log_level = LOG_CLASS_WARNING;
  enum log_colorize log_colorize = LOG_COLORIZE_AUTO;
  bool log_syslog = true;

  log_init(log_colorize, log_syslog, LOG_FACILITY_DAEMON, log_level);

  return 0;
}
