//
//  Point.h
//  InvisibleBarcodeIos
//
//  Created by W on 19/04/2017.
//  Copyright © 2017 W. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyPoint : NSObject

@property(nonatomic) double centX;
@property(nonatomic) double centY;
@property(nonatomic) double distance;


- (MyPoint*) initWithCentX : (double) centX andCentY : (double) centY;
- (void) setDistanceTo : (MyPoint*) pb;


- (NSComparisonResult) distanceCompare : (MyPoint*) pb;
- (NSComparisonResult) byxyvalues : (MyPoint*) pb;

@end
