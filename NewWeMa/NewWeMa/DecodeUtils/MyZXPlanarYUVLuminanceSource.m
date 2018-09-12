//
//  ZXPlanarYUVLuminanceSource.m
//  InvisibleBarcodeIos
//
//  Created by W on 27/04/2017.
//  Copyright © 2017 W. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MyZXPlanarYUVLuminanceSource.h"


@interface MyZXPlanarYUVLuminanceSource ()

@property (nonatomic, strong, readonly) ZXByteArray *yuvData;

@property (nonatomic, assign, readonly) int dataWidth;
@property (nonatomic, assign, readonly) int dataHeight;
@property (nonatomic, assign, readonly) int left;
@property (nonatomic, assign, readonly) int top;

@end

@implementation MyZXPlanarYUVLuminanceSource

- (id)initWithYuvData:(int8_t *)yuvData yuvDataLen:(int)yuvDataLen dataWidth:(int)dataWidth
           dataHeight:(int)dataHeight left:(int)left top:(int)top width:(int)width height:(int)height{
    
    if (self = [super initWithWidth:width height:height]) {
        if (left + width > dataWidth || top + height > dataHeight) {
//            [NSException raise:NSInvalidArgumentException format:@"Crop rectangle does not fit within image data."];
        }
        _yuvData = [[ZXByteArray alloc] initWithLength:yuvDataLen];
        memcpy(_yuvData.array, yuvData, yuvDataLen * sizeof(int8_t));
        _dataWidth = dataWidth;
        _dataHeight = dataHeight;
        _left = left;
        _top = top;
        NSLog(@"dataWidth=%d dataHeight=%d\n",_dataWidth,_dataHeight);
        NSLog(@"left=%d top=%d width=%d height=%d\n",_left,_top,self.width,self.height);
    }

    return self;
}

- (void) clear {
    if (self.yuvData){
        if (self.yuvData.array){
            free( self.yuvData.array);
        }
    }
}




- (ZXByteArray *)rowAtY:(int)y row:(ZXByteArray *)row {
    if (y < 0 || y >= self.height) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Requested row is outside the image: %d", y];
    }
    int width = self.width;
    if (!row || row.length < width) {
        row = [[ZXByteArray alloc] initWithLength:width];
    }
    int offset = (y + self.top) * self.dataWidth + self.left;
    memcpy(row.array, self.yuvData.array + offset, self.width * sizeof(int8_t));
    return row;
}


- (ZXByteArray *)matrix {
    int width = self.width;
    int height = self.height;
    
    // If the caller asks for the entire underlying image, save the copy and give them the
    // original data. The docs specifically warn that result.length must be ignored.
    if (width == self.dataWidth && height == self.dataHeight) {
        return self.yuvData;
    }
    
    int area = self.width * self.height;
    ZXByteArray *matrix = [[ZXByteArray alloc] initWithLength:area];
    int inputOffset = self.top * self.dataWidth + self.left;
    
    // If the width matches the full width of the underlying data, perform a single copy.
    if (self.width == self.dataWidth) {
        memcpy(matrix.array, self.yuvData.array + inputOffset, (area - inputOffset) * sizeof(int8_t));
        return matrix;
    }
    
    // Otherwise copy one cropped row at a time.
    ZXByteArray *yuvData = self.yuvData;
    for (int y = 0; y < self.height; y++) {
        int outputOffset = y * self.width;
        memcpy(matrix.array + outputOffset, yuvData.array + inputOffset, self.width * sizeof(int8_t));
        inputOffset += self.dataWidth;
    }
    return matrix;
}


- (BOOL)cropSupported {
    return YES;
}

- (CGImageRef) renderCroppedGreyscaleBitmap {
    int width = [self width];
    int height = [self height];
    int pixels[width * height];
   // int8_t this=_yuvData.array[0];
    int8_t *yuv = _yuvData.array;
    int tmpPixels[width * height];

    int inputOffset = _top * _dataWidth + _left;
    
    for (int y = 0; y < height; y++) {
        int outputOffset = y * width;
        for (int x = 0; x < width; x++) {
            tmpPixels[outputOffset + x] = yuv[inputOffset + x];
        }
        inputOffset += _dataWidth;
    }
    
//    for(int i=0;i<height;i++) {
//        int offset = i * width;
//        for(int j=0;j<width;j++) {
//            NSLog(@"tmpPixels: %d", tmpPixels[offset+j]);
//        }
//    }
    
    int laplacian[9] = { -1, -1, -1, -1, 9, -1, -1, -1, -1 };
    int pixR = 0;
    int pixG = 0;
    int pixB = 0;
    
    int pixColor = 0;
    
    int newR = 0;
    int newG = 0;
    int newB = 0;
    
    int idx = 0;
    float alpha = 2.0;
    int pixels2[width * height];
    
    for (int i = 1, length = height - 1; i < length; i++) {
        for (int k = 1, len = width - 1; k < len; k++) {
            idx = 0;
            for (int m = -1; m <= 1; m++){
                for (int n = -1; n <= 1; n++) {
                    pixColor = tmpPixels[(i + n) * width + k + m];
                    
                    pixR = (pixColor >> 16) & 0xff;
                    pixG = (pixColor >>  8) & 0xff;
                    pixB = (pixColor      ) & 0xff;
                    
                    newR = newR + (int) (pixR * laplacian[idx] * alpha);
                    newG = newG + (int) (pixG * laplacian[idx] * alpha);
                    newB = newB + (int) (pixB * laplacian[idx] * alpha);
                    idx++;
                    
                }
            }
            
            newR = MIN(255, MAX(0, newR));
            newG = MIN(255, MAX(0, newG));
            newB = MIN(255, MAX(0, newB));
            
            int newC = MIN(MIN(newR, newG), newB);
//            int test = (255 & 0xff) << 24 | (newC & 0xff) << 16 | (newC & 0xff) << 16 | (newC & 0xff);
            pixels2[i * width + k] = (255 & 0xff) << 24 | (newC & 0xff) << 16 | (newC & 0xff) << 16 | (newC & 0xff);
            
            newR = 0;
            newG = 0;
            newB = 0;
        }
    }
    
    for (int y = 0; y < height * width; y++){
        int grey = pixels2[y] & 0xff;
        pixels[y] = 0xFF000000 | (grey * 0x00010101);
//        NSLog(@"pixel: %d",pixels[y]);
    }
    
    
    CGImageRef imageRef = [self createBitmap:pixels : width : height];
    return imageRef;
}

- (CGImageRef) createBitmap : (int *) pixels : (int) width : (int) height {
    //create new bitmap
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return imageRef;
}


- (int8_t *) getTheYUV {
    int width = [self width];
    int height = [self height];
    int y = 0;
    int x = 0;
    int nOriganlYLen = _dataWidth * _dataHeight;
    
    int8_t *yuv = _yuvData.array;
    int8_t ret[width * height * 3 / 2];

    int inputOffset = _top * _dataWidth + _left;
    for (y = 0; y < height; y++) {
        int outputOffset = y * width;
        for (x = 0; x < width; x++) {
            ret[outputOffset + x] = yuv[inputOffset + x];
        }
        inputOffset += _dataWidth;
    }
    
    for (y = 0; y < height; y += 2) {
        for (x = 0; x < width; x++) {
            ret[height * width + width * (y >> 1) + x] = yuv[nOriganlYLen + ((_top + y) >> 1) * _dataWidth + (x + _left)];
        }
    }
    return ret;
}


@end
