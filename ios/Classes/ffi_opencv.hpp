#pragma once

#include <cstdint>

#include "definitions.hpp"
#include <opencv2/opencv.hpp>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <fstream>
#include <iostream>
#include <dirent.h>
#include <android/log.h>
#include <filesystem>
#include "src/face_detctor.hpp"
#include "src/logger.hpp"
EXTERN_C
void initFaceDetector(const char *cascadeFilePath);

EXTERN_C
void deactivate();

EXTERN_C
const int16_t *detect(uint8_t *bytes, uint16_t rotation, bool isYUV, int width,int height, int size = 50,  unsigned int* resCount = 0);

EXTERN_C
char *getMajorVersion();

EXTERN_C
bool isInit();
