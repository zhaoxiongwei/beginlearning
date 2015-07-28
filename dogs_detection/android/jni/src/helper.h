#ifndef _HELPER_H_
#define _HELPER_H_

#ifdef ANDROID

#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "BV"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)  

#else
#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#define  LOGD(...)  printf(__VA_ARGS__) 

#endif

#endif
