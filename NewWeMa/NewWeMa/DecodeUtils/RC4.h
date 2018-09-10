//
//  RC4.h
//  NewWeMa
//
//  Created by Gaojian on 2018/9/8.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RC4 : NSObject

void rc4_init(RC4 *rc4,unsigned char *key, size_t len_k);
//int rc4_next(RC4 *rc4);
void rc4_crypt(RC4 *rc4 ,unsigned char *dst,unsigned char *src, size_t len);


@end
