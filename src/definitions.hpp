#pragma once

#ifndef EXTERN_C
#define EXTERN_C extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

#ifndef FLUTTER_ATT
#define FLUTTER_ATT __attribute__((visibility("default"))) __attribute__((used))
#endif