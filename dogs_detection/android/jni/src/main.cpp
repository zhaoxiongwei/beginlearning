#include <vector>
#include <bv/image.h>
#include <bv/image_convert.h>

#include "detector.h"
#include "helper.h"

#ifdef ANDROID
#include <android/bitmap.h>

DogDetector* myDetector = NULL;
/********************************************************************************/
#define SATURATE(a,min,max) ((a)<(min)?(min):((a)>(max)?(max):(a)))
static void yuvToRgb(unsigned char inY, unsigned char inU, unsigned char inV,
        unsigned char& R, unsigned char& G, unsigned char& B) {
    int Gi = 0, Bi = 0;
    int Y = 9535*(inY-16);
    int U = inU - 128;
    int V = inV - 128;
    int Ri = (Y + 13074*V) >> 13;
    Ri = SATURATE(Ri, 0, 255);
    Gi = (Y - 6660*V - 3203*U) >> 13;
    Gi = SATURATE(Gi, 0, 255);
    Bi = (Y + 16531*U) >> 13;
    Bi = SATURATE(Bi, 0, 255);
    R = Ri;
    G = Gi;
    B = Bi;
}
/********************************************************************************/
int DetectorInit() {
    if ( myDetector != NULL ) {
        delete myDetector;
        myDetector = NULL;
    }
    myDetector = new DogDetector();

    return 0;
}

double DetectorUpdateForResult(JNIEnv* env,
        const unsigned char* frameIn,
        jobject bitmap,
        unsigned int wid, unsigned int hei ) {

    int rectangleSize = hei/2;
    // 将YUV图像转换为64x64的RGB矩阵 
    std::vector<Eigen::MatrixXf> sourcePatches;
    sourcePatches.resize(3);
    for(int i = 0; i < 3; i++) {
        sourcePatches[i].resize(rectangleSize, rectangleSize);
    }
    int beginX = wid/2 - rectangleSize/2;
    int beginY = hei/2 - rectangleSize/2;
    for (int y = beginY; y < beginY + rectangleSize; y++) {
        for (int x = beginX; x < beginX + rectangleSize; x++)   {
            unsigned char Y = frameIn[y * wid + x];
            unsigned char V = frameIn[y/2 * wid + (x&0xFFFFFFFE) + wid*hei];
            unsigned char U = frameIn[y/2 * wid + (x&0xFFFFFFFE) + 1 + wid*hei];
            unsigned char r,g,b;
            yuvToRgb(Y,U,V,r,g,b);
            sourcePatches[0](x-beginX,y-beginY) = r/255.0;
            sourcePatches[1](x-beginX,y-beginY) = g/255.0;
            sourcePatches[2](x-beginX,y-beginY) = b/255.0;
        }
    }

    // resize to 64x64
    Eigen::MatrixXf targetPatch(DogDetector::inputImageSize, DogDetector::inputImageSize);
    for(int i = 0; i < 3; i++) {
        bv::Convert::resizeImage(sourcePatches[i], targetPatch);
        sourcePatches[i] = targetPatch.transpose();
    }
    
    double likeDog = myDetector->detect(sourcePatches); 
    LOGD(" >>>>>>>>>>>>>>>>>>>likeDog = %f", likeDog);

#if 0
    // 修改输出图像 
    int ret; 
    AndroidBitmapInfo  info;
    unsigned int*              pixels;
    unsigned int color = 0xFFFFFFFF;
    if ( isDog ) {
        color = 0xFF00FFFF;
    }
    if ((ret = AndroidBitmap_getInfo(env, bitmap, &info)) < 0) {
        LOGD("AndroidBitmap_getInfo() failed ! error=%d", ret);
        return -1;
    }
    
    if ((ret = AndroidBitmap_lockPixels(env, bitmap, (void**)&pixels)) < 0) {
        LOGD("AndroidBitmap_lockPixels() failed ! error=%d", ret);
        return -1;
    } 
    int lineStride = info.stride / 4;
    for(unsigned int x = (wid - rectangleSize)/2; x < (wid + rectangleSize)/2; x++) {
        int y = (hei - rectangleSize)/2;
        pixels[(y-1)*lineStride+x] = color;
        pixels[y*lineStride+x] = color;
        pixels[(y+1)*lineStride+x] = color;
        y = (hei + rectangleSize) / 2;
        pixels[(y-1)*lineStride+x] = color;
        pixels[y*lineStride+x] = color;
        pixels[(y+1)*lineStride+x] = color;
    }
    for(unsigned int y = (hei - rectangleSize)/2; y < (hei + rectangleSize)/2; y++) {
        int x = (wid - rectangleSize)/2;
        pixels[y*lineStride+x-1] = color;
        pixels[y*lineStride+x] = color;
        pixels[y*lineStride+x+1] = color;
        x = (wid + rectangleSize) / 2;
        pixels[y*lineStride+x-1] = color;
        pixels[y*lineStride+x] = color;
        pixels[y*lineStride+x+1] = color;
    }

    AndroidBitmap_unlockPixels(env, bitmap);
#endif
  
    return likeDog;
}

#else

int main(int argc, const char *argv[]) {
    if ( argc < 2) {
        std::cout << "Please input bmp file name" << std::endl;
        return 0; 
    }    
    
    std::string fileName(argv[1]);
    bv::ColorImage<3> img(fileName);
    assert(img.width() == DogDetector::inputImageSize);
    assert(img.height() == DogDetector::inputImageSize);
    
    std::vector<Eigen::MatrixXf> sourcePatches;  
    sourcePatches.resize(3);
    for(int i = 0; i < 3; i++) {
        sourcePatches[i].resize(DogDetector::inputImageSize, DogDetector::inputImageSize);
        for (int y = 0; y < DogDetector::inputImageSize; y++) {
            for ( int x = 0; x < DogDetector::inputImageSize; x++) {
                sourcePatches[i](y,x) = img.color(i).data(x,y) / 255.0;
            }
        }
    }
    
    DogDetector* myDetector = new DogDetector();
    double likeDog = myDetector->detect( sourcePatches);
    std::cout << ">>>>> dog like value = " << likeDog << std::endl;
    delete myDetector; 

    return 0;
}
#endif
