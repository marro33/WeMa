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

+ (NSString*) handleTheBuffer:(CVImageBufferRef) imageBuffer :(CGRect) interestRect{
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


    NSLog(@"tempd: %d + %d",tempData,tempDataSize);
    memcpy(tempData, yuvFrame, yuvSize);

//    _width = width;
//    _height = height;

    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    //        NSLog(@"%@",@"SS");
    free(yuvFrame);


//    CGRect interestRect = [_layer metadataOutputRectOfInterestForRect:_scanRect];


    int dstLeftT = (int)(interestRect.origin.x*width);
    int dstTopT = (int)(interestRect.origin.y*height);
    int dstWidthT = (int)(interestRect.size.width*width);
    int dstHeightT = (int)(interestRect.size.height*height);

    NSLog(@"interestRect%f,%f", interestRect.size.height, interestRect.size.width);

    NSLog(@"#:%d + %d + %d + %d",dstLeftT,dstTopT,dstWidthT,dstHeightT);


    //在这一步处理图像的时候，需要了解扫描框的具体大小但是明显有错误

//    MyZXPlanarYUVLuminanceSource *source = [[MyZXPlanarYUVLuminanceSource alloc] initWithYuvData:tempData
//                                                        yuvDataLen:tempDataSize dataWidth:(int)width
//                                                        dataHeight:(int)height
//                                                              left:588
//                                                               top:168
//                                                             width:742
//                                                            height:743];
        MyZXPlanarYUVLuminanceSource *source = [[MyZXPlanarYUVLuminanceSource alloc] initWithYuvData:tempData
                                                            yuvDataLen:tempDataSize dataWidth:(int)width
                                                            dataHeight:(int)height
                                                                  left:dstLeftT
                                                                   top:dstTopT
                                                                 width:dstWidthT
                                                                height:dstHeightT];


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
