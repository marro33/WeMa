//
//  ImageBufferHandler.m
//  NewWeMa
//
//  Created by Gaojian on 2018/9/12.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

#import "ImageBufferHandler.h"
#import <ZXingObjC/ZXingObjC.h>
#import "MyZXPlanarYUVLuminanceSource.h"
#import "DecodeUtils.h"

@implementation ImageBufferHandler

+ (NSString*) handleTheBuffer:(CVImageBufferRef) imageBuffer {

    NSLog(@"handling the buffer");
    //lock the base address
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    //        NSLog(@"cvpixel width=%d height=%d\n",width,height);
    //get yuv data
    //yuv中的y所占字节数
    size_t ySize = width * height;
    //yuv中的uv所占的字节数
    size_t uvSize = ySize / 2;
    uint8_t *yuvFrame = (uint8_t*)malloc(uvSize + ySize);
    //获取CVImageBufferRef中的y数据
    uint8_t *yFrame = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    memcpy(yuvFrame, yFrame, ySize);
    //获取CMVImageBufferRef中的uv数据
    uint8_t *uvFrame = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    memcpy(yuvFrame + ySize, uvFrame, uvSize);

    int yuvSize = (int)ySize + (int)uvSize;

    int tempDataSize = yuvSize / sizeof(int8_t);
    int8_t* tempData = (int8_t*)malloc(yuvSize);

    //        NSLog(@"temmp %d",yuvSize);
    NSLog(@"tempd: %d + %d",tempData,tempDataSize);
    memcpy(tempData, yuvFrame, yuvSize);

    //        NSLog(@"299 %zu + %zu", width, height);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    //        NSLog(@"%@",@"SS");
    free(yuvFrame);


    MyZXPlanarYUVLuminanceSource *source = [[MyZXPlanarYUVLuminanceSource alloc] initWithYuvData:tempData
                                                        yuvDataLen:tempDataSize dataWidth:(int)width
                                                        dataHeight:(int)height
                                                              left:588
                                                               top:168
                                                             width:743
                                                            height:742];


    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:
                              [[ZXHybridBinarizer alloc] initWithSource:source]];

    NSString *retString = @"";
    int datasize = 10;

    DecodeUtils *decoder = [[DecodeUtils alloc] initWithSide:5 andDataSize:datasize];
    retString = [decoder decodeBitMap:bitmap];

    free(tempData);


    return retString;
}


@end
