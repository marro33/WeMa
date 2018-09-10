//
//  MyImageChecker.m
//  InvisibleBarcodeIos
//
//  Created by Manish Adhikari on 10/07/2017.
//  Copyright © 2017 W. All rights reserved.
//

#import "MyImageChecker.h"

#define ADDPOINT(pixel,num,value) (((uint8_t *)pixel)[num]=value)




@import MobileCoreServices; // or `@import CoreServices;` on Mac
@import ImageIO;




@implementation MyImageChecker

+ (BOOL) writeCGImageToFile:(CGImageRef) image andPath: (NSString *)path
{
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    if (!destination) {
        NSLog(@"Failed to create CGImageDestination for %@", path);
        return NO;
    }
    
    CGImageDestinationAddImage(destination, image, nil);
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Failed to write image to %@", path);
        CFRelease(destination);
        return NO;
    }
    
    CFRelease(destination);
    return YES;
}


+ (CGImageRef) paintRegion:(uint32_t *)pixel
              bitmapWidth : (size_t) width
             bitmapHeight : (size_t) height
                 forPoints: (NSMutableArray<MyPoint *> *) pointsList
                 withColor: (CGColorRef) color {
    
    
    // allocate memory for pixels
    uint32_t *pixels = calloc( width * height, sizeof(uint32_t) );
    memcpy(pixels, pixel, width*height*sizeof(uint32_t));
    
    
    
    int i;
    for (i=0;i<[pointsList count];i++){
        MyPoint *point=pointsList[i];
        int xl=round([point centX]);
        int yl=round([point centY]);
        uint32_t *thepixel=pixels+(yl*width+xl);
        uint32_t *endpixel=pixels+width*height;
        const CGFloat *components = CGColorGetComponents(color);
        uint8_t red,blue,green,alpha;
        if (CGColorGetNumberOfComponents(color)<4){
            red=components[0];
            blue=components[0];
            green=components[0];
            alpha=components[1];
            
        } else  {
            red=(uint8_t)(components[0]*255.0);
            blue=(uint8_t)(components[2]*255.0);
            green=(uint8_t)(components[1]*255.0);
            alpha=(uint8_t)(components[3]*255.0);
            
        }
        
        if (thepixel>=pixels && thepixel<endpixel)ADDPOINT(thepixel,RED, red);
        if (thepixel>=pixels && thepixel<endpixel)ADDPOINT(thepixel,GREEN, green);
        if (thepixel>=pixels && thepixel<endpixel)ADDPOINT(thepixel,BLUE, blue);
        if (thepixel>=pixels && thepixel<endpixel)ADDPOINT(thepixel,ALPHA, alpha);
        
        
    }
    // create a context with RGBA pixels
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate( pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast );
    
    // draw the image into the context
    
    // create a new CGImage from the context with modified pixels
    CGImageRef resultImage = CGBitmapContextCreateImage( context );
    
    // release resources to free up memory
    CGContextRelease( context );
    CGColorSpaceRelease( colorSpace );
    free( pixels );
    
    return( resultImage );
}




+ (CGImageRef) locateCentres: (CGImageRef) image forPoints: (NSMutableArray<MyPoint *> *) pointsList
{
    
    
    
    int width  = (int)CGImageGetWidth( image );
    int height = (int)CGImageGetHeight( image );
    
    // allocate memory for pixels
    uint32_t *pixels = calloc( width * height, sizeof(uint32_t) );
    
    // create a context with RGBA pixels
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate( pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast );
    
    // draw the image into the context
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image );
    
    //put a red plus at each centre
    int i;
    
    
    for (i=0;i<[pointsList count];i++){
        MyPoint *point=pointsList[i];
        int xl=round([point centX]);
        int yl=round([point centY]);
        uint32_t *thepixel=pixels+(yl*width+xl);
        uint32_t *uppixel=pixels+((yl-1)*width+xl);
        uint32_t *downpixel=pixels+((yl+1)*width+xl);
        uint32_t *leftpixel=pixels+(yl*width+(xl-1));
        uint32_t *rightpixel=pixels+(yl*width+(xl+1));
        uint32_t *endpixel=pixels+width*height;
        if( thepixel>=pixels && thepixel<endpixel)*thepixel=0xff;
        if (uppixel>=pixels && uppixel<endpixel)*uppixel=0xff;
        if(downpixel>=pixels && downpixel<endpixel)*downpixel=0xff;
        if (leftpixel>=pixels && leftpixel<endpixel)*leftpixel=0xff;
        if(rightpixel>=pixels && rightpixel<endpixel)*rightpixel=0xff;
        if (thepixel>=pixels && thepixel<endpixel)ADDPOINT(thepixel,RED, 255);
        if (uppixel>=pixels && uppixel<endpixel)ADDPOINT(uppixel,RED, 255);
        if (leftpixel>=pixels && leftpixel<endpixel)ADDPOINT(leftpixel,RED, 255);
        if(downpixel>=pixels && downpixel<endpixel)ADDPOINT(downpixel,RED, 255);
        if(rightpixel>=pixels && rightpixel<endpixel)ADDPOINT(rightpixel,RED, 255);
        
    }
    
    
    // create a new CGImage from the context with modified pixels
    CGImageRef resultImage = CGBitmapContextCreateImage( context );
    
    // release resources to free up memory
    CGContextRelease( context );
    CGColorSpaceRelease( colorSpace );
    free( pixels );
    
    return( resultImage );
}

@end
