#include "logger.hpp"

void loga(const char *s, ...) {
    __android_log_print(ANDROID_LOG_DEBUG, "flutter_ffi", "%s", s);
}