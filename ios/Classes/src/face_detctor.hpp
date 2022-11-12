#include "../definitions.hpp"
#include <opencv2/objdetect.hpp>
#include <opencv2/core.hpp>
#include <opencv2/objdetect.hpp>
#include "logger.hpp"

class CppFaceDetector {

public:
    CppFaceDetector(const char *classifierPath);
    ~CppFaceDetector();
    bool isInit();
    const int16_t*  detect(cv::Mat frame, uint8_t size,unsigned int* resultCount);
private:
    cv::CascadeClassifier *classifier;
};


