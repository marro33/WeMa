//
//  MyImageChecker.h
//  InvisibleBarcodeIos
//
//  Created by Manish Adhikari on 10/07/2017.
//  Copyright © 2017 W. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyPoint.h"
#include<math.h>


#define MyImageChecker_h

static const int RED=3;
static const int GREEN=2;
static const int BLUE=1;
static const int ALPHA=0;

@import MobileCoreServices; // or `@import CoreServices;` on Mac
@import ImageIO;

@interface MyImageChecker :NSObject
+ (BOOL) writeCGImageToFile:(CGImageRef) image andPath: (NSString *)path;
+ (CGImageRef) locateCentres: (CGImageRef) image forPoints: (NSMutableArray<MyPoint *> *) pointsList;
+ (CGImageRef) paintRegion:(uint32_t *)pixel bitmapWidth : (int) width bitmapHeight : (int) height forPoints: (NSMutableArray<MyPoint *> *) pointsList withColor: (CGColorRef) color ;

@end








//#endif /* MyImageChecker_h */
