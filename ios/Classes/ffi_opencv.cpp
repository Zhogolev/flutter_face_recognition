#include "ffi_opencv.hpp"

using namespace cv;
using namespace std;


static CppFaceDetector *faceDetector = nullptr;



EXTERN_C
void initFaceDetector(const char *cascadeFilePath) {
    loga(cascadeFilePath);
    faceDetector = new CppFaceDetector(cascadeFilePath);
}

EXTERN_C
void rotateMat(Mat &matImage, int rotation) {
    if (rotation == 90) {
        transpose(matImage, matImage);
        flip(matImage, matImage, 1); //transpose+flip(1)=CW
    } else if (rotation == 270) {
        transpose(matImage, matImage);
        flip(matImage, matImage, 0); //transpose+flip(0)=CCW
    } else if (rotation == 180) {
        flip(matImage, matImage, -1);    //flip(-1)=180
    }
}



EXTERN_C
const int16_t *
detect(uint8_t *bytes, uint16_t rotation, bool isYUV, int width,int height ,int size,
       unsigned int *resCount) {

    if (faceDetector == nullptr) {
        auto *res = new int16_t[1];
        res[0] = 0;
        return res;
    }

    Mat frame;
    if (isYUV) {
        Mat myuv(height + height / 2, width, CV_8UC1, bytes);
        cvtColor(myuv, frame, COLOR_YUV2BGRA_NV21);
    } else {
        frame = Mat(height, width, CV_8UC4, bytes);
    }

    rotateMat(frame, rotation);
    cvtColor(frame, frame, COLOR_BGRA2GRAY);
    vector <Rect> faces;

    auto res = faceDetector->detect(frame, size, resCount);

    return res;
}

EXTERN_C
bool isInit() {
    if (faceDetector == nullptr) {
        return false;
    }
    return faceDetector->isInit();
}


void deactivate() {
    if (faceDetector != nullptr) {
        delete faceDetector;
        faceDetector = nullptr;
    }
}





EXTERN_C
char *getMajorVersion() {
    return CV_VERSION;
}