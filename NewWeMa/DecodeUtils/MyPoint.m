//
//  Point.m
//  InvisibleBarcodeIos
//
//  Created by W on 19/04/2017.
//  Copyright © 2017 W. All rights reserved.
//

#import "MyPoint.h"

@implementation MyPoint

- (MyPoint*) initWithCentX : (double) centX andCentY : (double) centY {
    self = [super init];
    [self setCentX: centX];
    [self setCentY: centY];
    
    return self;
}

- (void) setDistanceTo : (MyPoint*) pb {
//    self->_distance = sqrt(pow(pb->_centX - self->_centX, 2) + pow(pb->_centY - self->_centY, 2));
    self.distance =sqrt(pow(pb.centX - self.centX, 2) + pow(pb.centY - self.centY, 2));
}


/* 依据distance排序 */
- (NSComparisonResult) distanceCompare : (MyPoint*) pb {
//    if(self.distance < pb.distance) {
//        return NSOrderedDescending;
//    } else if(self.distance == pb.distance) {
//        return NSOrderedSame;
//    } else {
//        return NSOrderedAscending;
//
//    }
    if(self.distance < pb.distance) {
        return NSOrderedAscending;
    }else{
        return NSOrderedDescending;
    }
}

//这写的到底是什么东西？！！！！！
- (NSComparisonResult) byxyvalues : (MyPoint*) pb {
    if (self.centX<pb.centX){
        return NSOrderedAscending;
    } else if (self.centX>pb.centX){
        return NSOrderedDescending;
    } else  if (self.centX==pb.centX) {
        if (self.centY<pb.centY){
            return NSOrderedAscending;
        } else if (self.centY>pb.centY){
            return NSOrderedDescending;
        }
        else if (self.centY==pb.centY){
            return NSOrderedSame;
        }
        
    }
    return NSOrderedSame;
}

@end
