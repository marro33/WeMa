//
//  ImageBufferHandler.h
//  NewWeMa
//
//  Created by Gaojian on 2018/9/12.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ImageBufferHandler : NSObject

+(NSString*) handleTheBuffer:(CVImageBufferRef) imageBuffer :(CGRect) rect;

@end
