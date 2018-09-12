//
//  ZXPlanarYUVLuminanceSource.h
//  InvisibleBarcodeIos
//
//  Created by W on 27/04/2017.
//  Copyright © 2017 W. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZXingObjC/ZXingObjC.h>


@interface MyZXPlanarYUVLuminanceSource : ZXLuminanceSource

//- (id)initWithYuvData:(int8_t *)yuvData yuvDataLen:(int)yuvDataLen dataWidth:(int)dataWidth
//           dataHeight:(int)dataHeight left:(int)left top:(int)top width:(int)width height:(int)height;
//- (UIImage *) renderCroppedGreyscaleBitmap;
- (id)initWithYuvData:(int8_t *)yuvData yuvDataLen:(int)yuvDataLen dataWidth:(int)dataWidth
dataHeight:(int)dataHeight left:(int)left top:(int)top width:(int)width height:(int)height;
- (CGImageRef) renderCroppedGreyscaleBitmap;
- (void) clear;

@end
