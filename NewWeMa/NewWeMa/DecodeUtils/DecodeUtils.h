//
//  DecodeUtils.h
//  InvisibleBarcodeIos
//
//  Created by W on 17/04/2017.
//  Copyright © 2017 W. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "math.h"
#import <ZXingObjC/ZXingObjC.h>
#include "com_example_testdecode_RSDecoder.h"
#import "MyPoint.h"
#import "MyImageChecker.h"
#include "rc4.h"
#include "dataconstants.h"


@interface DecodeUtils : NSObject

- (DecodeUtils *) initWithSide : (int)side andDataSize : (int)datasize;

- (NSString *) decodeBitMap : (ZXBinaryBitmap *) bitmap ;

- (CGImageRef) rotateBitmapWithDegree : (double) degree bitMap: (CGImageRef) grayMap;

+ (void) test;
//- (NSString *) decodeBitMap : (ZXBinaryBitmap *) bitmap : (UIImage *) grayMap;
//- (UIImage *) rotateBitmapWithDegree : (double) degree bitMap: (UIImage *) grayMap;
//@property(nonatomic) ImageTestViewController *_imgAlert;

@end
