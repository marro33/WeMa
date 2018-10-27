//
// Created by Manish Adhikari on 20/04/2017.
//

#ifndef SCREENDECODE_RC4_H
#define SCREENDECODE_RC4_H

#endif //SCREENDECODE_RC4_H

#define RC_SSIZE 256
#include<stdlib.h>

typedef struct {
    int i;
    int j;
    unsigned char s[RC_SSIZE];
} RC4;

void rc4_init(RC4 *rc4,unsigned char *key, size_t len_k);
//int rc4_next(RC4 *rc4);
void rc4_crypt(RC4 *rc4 ,unsigned char *dst,unsigned char *src, size_t len);


