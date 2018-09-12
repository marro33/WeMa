//
// Created by Manish Adhikari on 20/04/2017.
//


#include "rc4.h"


void rc4_init(RC4 *rc4,unsigned char *key, size_t len_k){
    int i;
    for ( i = 0; i < RC_SSIZE; i++)
        rc4->s[i] = i;
    int j = 0;
    for ( i = 0; i < RC_SSIZE; i++)
    {
        j = (j + rc4->s[i] + key[i%len_k]) % RC_SSIZE;
        char tmp=rc4->s[i];
        rc4->s[i]=rc4->s[j];
        rc4->s[j]=tmp;
    }
    rc4->i=0;
    rc4->j=0;

}

/*Return next char of rc4 stream as int*/

int rc4_next(RC4 *rc4){
    int i=rc4->i;
    int j=rc4->j;
    i = (i + 1) % RC_SSIZE;
    j = (j + rc4->s[i])% RC_SSIZE;
    char tmp=rc4->s[i];
    rc4->s[i]=rc4->s[j];
    rc4->s[j]=tmp;
    int t=(rc4->s[i]+rc4->s[j])%RC_SSIZE;
    unsigned char k=rc4->s[t];
    rc4->i=i;
    rc4->j=j;
    return (int)k;

}
/*Encrypt or decrypt data of different length in different location*/
void rc4_crypt(RC4 *rc4 ,unsigned char *dst,unsigned char *src, size_t len){
    int i;
    for (i=0;i<len;i++){
        dst[i]=src[i]^rc4_next(rc4);
    }

}