#pragma once

#include <cstdint>

#include "definitions.hpp"
#include "string_struct.hpp"

EXTERN_C
char* getMajorVersion();
EXTERN_C
char* sayHelloFromFd();
EXTERN_C
intptr_t sum(intptr_t a, intptr_t b);
EXTERN_C
intptr_t sumLongRunning(intptr_t a, intptr_t b);
