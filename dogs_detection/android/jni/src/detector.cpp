//#include <iostream>
#include "helper.h"
#include "detector.h"

extern double wData[];
extern double bData[];
extern double meanData[];
extern double whiteData[];
extern double optThetaData[];

const int DogDetector::inputImageSize = 64;
const int DogDetector::convPatchSize = 8;
const int DogDetector::visualSize = 192;
const int DogDetector::hiddenSize = 400;
const int DogDetector::poolSize = 19;
const int DogDetector::featureSize = 3600 + 1;

DogDetector::DogDetector() {
    loadFeatureMatrix();    
}
DogDetector::~DogDetector() {
}

double DogDetector::detect(std::vector<Eigen::MatrixXf>& sourcePatches) {
    // Convolved input raw images to 400x57x57 size
    std::vector<Eigen::MatrixXf> convFeatures;
    convFeatures.resize(hiddenSize);
    for (int i = 0; i < hiddenSize; i++) {
        convFeatures[i].resize(inputImageSize - convPatchSize+1, inputImageSize - convPatchSize+1);
    }
    Eigen::MatrixXf fw = *featureW * *zcaWhite;
    Eigen::MatrixXf nb = *featureB - fw * *zcaMean;
    for (int y = 0; y <= inputImageSize - convPatchSize; y++) {
        for (int x = 0; x <= inputImageSize - convPatchSize; x++) {
            // 生成192维度的特征向量
#if 0
            Eigen::MatrixXf patch(convPatchSize, convPatchSize * 3);                
            Eigen::MatrixXf patch_r = sourcePatches[0].block(y, x, convPatchSize, convPatchSize);
            Eigen::MatrixXf patch_g = sourcePatches[1].block(y, x, convPatchSize, convPatchSize);
            Eigen::MatrixXf patch_b = sourcePatches[2].block(y, x, convPatchSize, convPatchSize);
            patch << patch_r, patch_g, patch_b;
            patch.resize(visualSize, 1);
#else
            Eigen::MatrixXf patch(convPatchSize * convPatchSize * 3,1);
            for(int xx = x, i=0; xx < x + convPatchSize; xx++, i++) {
                for (int yy = y, j=0; yy < y + convPatchSize; yy++, j++) {
                    int seq = j + i * convPatchSize;
                    patch(seq + 0) = sourcePatches[0](yy,xx);
                    patch(seq + 64) = sourcePatches[1](yy,xx);
                    patch(seq + 128) = sourcePatches[2](yy,xx);
                }
            }
#endif
            // 计算输出的400个特征向量
            patch = fw * patch + nb;
            patch.array() = ((patch.array() * (-1) ).exp() + 1.0).inverse();
            
            for (int i = 0; i < hiddenSize; i++) {
                //convFeatures[i](y,x) = 1.0 / ( 1 + exp(-1*patch(i,0)) );
                convFeatures[i](y,x) = patch(i,0);
            }

        }
    }
    //std::cout << convFeatures[0] << std::endl;
    
    // Pools the given convolved features
    Eigen::MatrixXf poolFeatures(featureSize,1);
    poolFeatures(0,0) = 1;
    for (int i = 0; i < hiddenSize; i++) {      //注意排列顺序需要和模型文件一致 
        for (int y = 0; y < 3; y++) {
            for (int x = 0; x < 3; x++) {
                int f = y*3 + x;
                poolFeatures(f*hiddenSize + i + 1, 0) = convFeatures[i].block(x*poolSize, y*poolSize, poolSize, poolSize).sum() / (poolSize * poolSize);
            }
        } 
    }
    
    double value = ((*optTheta).transpose() * poolFeatures)(0,0);
    value = 1.0 / ( 1.0 + exp(-1*value));  
    
    return value;
}

void DogDetector::loadFeatureMatrix() {
    featureW = new Eigen::MatrixXf(hiddenSize, visualSize);
    for(int i = 0; i < visualSize; i++) {
        for(int j = 0; j < hiddenSize; j++) {
            (*featureW)(j,i) = wData[i*hiddenSize + j];
        }
    }
    
    featureB = new Eigen::MatrixXf(hiddenSize, 1);
    for(int i = 0; i < hiddenSize; i++) {
        (*featureB)(i,0) = bData[i];
    }

    zcaMean = new Eigen::MatrixXf(visualSize, 1);
    for(int i = 0; i < visualSize; i++) {
        (*zcaMean)(i,0) = meanData[i];
    }

    zcaWhite = new Eigen::MatrixXf(visualSize, visualSize); 
    for(int i = 0; i < visualSize; i++) {
        for (int j = 0; j < visualSize; j++) {
            (*zcaWhite)(j,i) = whiteData[i*visualSize+j];
        }
    }

    optTheta = new Eigen::MatrixXf(featureSize, 1);
    for(int i = 0; i < featureSize; i++) {
        (*optTheta)(i,0) = optThetaData[i];
    }
}

