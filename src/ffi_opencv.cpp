#include "ffi_opencv.hpp"
#include "face_detctor.hpp"
#include <opencv2/opencv.hpp>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

using namespace cv;
using namespace std;




EXTERN_C
char* getMajorVersion() {
    return CV_VERSION;
}
EXTERN_C
char* sayHelloFromFd() {
    auto fd = new CppFaceDetect();
    fd->sayHello();
    auto result = new StringResult();
    result -> result = fd->sayHello();
    return (char*) fd->sayHello();
}
EXTERN_C
intptr_t sum(intptr_t a, intptr_t b) { return a + b; }

EXTERN_C
intptr_t sumLongRunning(intptr_t a, intptr_t b) {

    usleep(5000 * 1000);

    return a + b;
}
