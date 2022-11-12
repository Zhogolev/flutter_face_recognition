#include "face_detctor.hpp"

CppFaceDetector::CppFaceDetector(const char *classifierPath) {
    classifier = new cv::CascadeClassifier(classifierPath);
}

CppFaceDetector::~CppFaceDetector() {
    if (classifier != nullptr) {
        delete classifier;
        classifier = nullptr;
    }
}

bool CppFaceDetector::isInit() {
    return !classifier->empty();
}

const int16_t*  CppFaceDetector::detect(cv::Mat frame, uint8_t size,unsigned int* resultCount) {

    std::vector<cv::Rect> faces;
    auto maxSize = cv::Size(size, size);
    auto minSize = cv::Size();
    classifier->detectMultiScale( frame, faces, 1.1,
                              1, 0|cv::CASCADE_SCALE_IMAGE, minSize, maxSize );
    std::vector<int16_t> output;
    for(auto rect : faces){
        cv::Point tl =rect.tl();
        cv::Point br = rect.br();
        output.push_back((int16_t) tl.x);
        output.push_back((int16_t) tl.y);
        output.push_back((int16_t) br.x);
        output.push_back((int16_t) br.y);
    }

    unsigned int total = sizeof(int16_t) * output.size();
    auto* jres = (int16_t*)malloc(total);
    memcpy(jres, output.data(), total);

    *resultCount = output.size();
    return jres;

}
