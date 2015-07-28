#ifdef ANDROID

#include <string>
#include <jni.h>

#undef JNIEXPORT
#define JNIEXPORT __attribute__((visibility("default")))
#define JOW(rettype, name) extern "C" rettype JNIEXPORT JNICALL \
      Java_com_beginvision_dogdetector_NativeAgent_##name

//
//  Global variables
//


//
//  Internal helper functions
//

/*
static std::string convert_jstring(JNIEnv* env, const jstring &js) {
    static char outbuf[1024];
    int len = env->GetStringLength(js);
    env->GetStringUTFRegion(js, 0, len, outbuf);
    std::string str = outbuf;
    return str;
}
static jint get_native_fd(JNIEnv* env, jobject fdesc) {
    jclass clazz;
    jfieldID fid;

    if (!(clazz = env->GetObjectClass(fdesc)) ||
            !(fid = env->GetFieldID(clazz,"descriptor","I"))) return -1;
    return env->GetIntField(fdesc,fid);
}
*/

//
//  Global functions called from Java side 
//
int DetectorInit();
double DetectorUpdateForResult(JNIEnv* env,
        const unsigned char* frameIn,
        jobject result,
        unsigned int wid, unsigned int hei );

JOW(int, init)(JNIEnv* env, jclass) {
    return DetectorInit();
}

JOW(double, updatePictureForResult)(JNIEnv* env, jclass, jbyteArray yuvData, jobject result, jint wid, jint hei) {
    double ret;
    jbyte* cameraFrame = env->GetByteArrayElements(yuvData, NULL);
    ret = DetectorUpdateForResult(env, (unsigned char*)cameraFrame, result, wid, hei);
    env->ReleaseByteArrayElements(yuvData, cameraFrame, 0);
    return ret;
}

JOW(int, updatePicture)(JNIEnv* env, jclass, jbyteArray yuvData, jint wid, jint hei) {
    jbyte* cameraFrame= env->GetByteArrayElements(yuvData, NULL);
    // TOOD
    env->ReleaseByteArrayElements(yuvData, cameraFrame, 0);
    return 0;
}


//
//  Top level library load/unload 
//
extern "C" jint JNIEXPORT JNICALL JNI_OnLoad(JavaVM *jvm, void *reserved) {
    JNIEnv* jni;
    if (jvm->GetEnv(reinterpret_cast<void**>(&jni), JNI_VERSION_1_6) != JNI_OK)
        return -1;
    return JNI_VERSION_1_6;
}

extern "C" jint JNIEXPORT JNICALL JNI_OnUnLoad(JavaVM *jvm, void *reserved) {
    return 0;
}

#endif
