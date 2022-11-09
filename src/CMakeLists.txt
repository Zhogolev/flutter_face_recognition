# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
project(ffi_opencv_project)

cmake_minimum_required(VERSION 3.10.2)

set(OpenCV_STATIC ON)
set(OpenCV_DIR $ENV{ANDROID_OPENCVV}/sdk/native/jni)
set(CMAKE_VERBOSE_MAKEFILE ON)

find_package(OpenCV REQUIRED)

add_library(ffi_opencv
  SHARED
  ../ios/Classes/ffi_opencv.cpp
  src/face_detctor.cpp
  #ffi_opencv.cpp
)

target_include_directories(
        ffi_opencv
        PRIVATE
        src
)


message(WARNING "ANDROID_NDK_ABI_NAME ${ANDROID_NDK_ABI_NAME}")


set_target_properties(ffi_opencv 
  PROPERTIES
  PUBLIC_HEADER 
  "ffi_opencv.hpp"
  OUTPUT_NAME "ffi_opencv"
)

# target_compile_definitions(ffi_opencv PUBLIC DART_SHARED_LIB)


target_link_libraries(
    ffi_opencv
    ${OpenCV_LIBS}
)