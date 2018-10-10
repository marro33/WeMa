//
//  DecodeUtils.m
//  InvisibleBarcodeIos
//
//  Created by W on 17/04/2017.
//  Copyright © 2017 W. All rights reserved.
//


#import "DecodeUtils.h"


#define KEYLEN 24

static const NSString *TAG = @"DecodeProcess";
static const int changePixelCenter[4][2] = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}};
static const double NOTHETA = 500;
static const double PAIRMIN = 0.97;
static const double PAIRMAX = 1/PAIRMIN;
static const double INTERVAL = 35.0;
static CGColorSpaceRef rgbcolorspace;
static const char KEY[KEYLEN]={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23};


static int _side;
static int _noofpoints;
static int _datasize;

typedef struct  {
    int x;
    int y;
} Imgpos;



@implementation DecodeUtils

- (DecodeUtils *) initWithSide : (int)side andDataSize : (int)datasize {
    self = [super init];
    _side = side;
    _datasize = datasize;
    _noofpoints = (int)round((side+1)*7.5);
    rgbcolorspace= CGColorSpaceCreateDeviceRGB();
    return self;
}

- (int *) getPixelsdata :(int) bitMapWidth : (int) bitMapHeight : (CGImageRef) grayMap :(int *)tempPixelsData {
    CGContextRef context = CGBitmapContextCreate(tempPixelsData, bitMapWidth, bitMapHeight, 8, bitMapWidth * 4, rgbcolorspace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, bitMapWidth, bitMapHeight), grayMap);
    int *contextPixelsData = CGBitmapContextGetData(context);
    CGContextRelease(context);
    return contextPixelsData;
}


-(NSMutableArray<MyPoint *> *) zipX : (float *)x andY: (float *)y forSize: (size_t) size  {
    NSMutableArray<MyPoint *> * points=[[NSMutableArray alloc] init];
    for (int i=0;i<size;i++){
        [points addObject:[[MyPoint alloc] initWithCentX:(double)x[i] andCentY:(double)y[i]]];
    }
    return points;
}



-(CGImageRef) getViewPointsImage :(NSMutableArray<MyPoint *> *) arrayValues
                         forWidth: (size_t) width
                        andHeight: (size_t) height{

    uint32_t *pixels=calloc(width*height,sizeof(uint32_t));

    for (int i=0;i<width*height;i++){
        pixels[i]=0xFF;
    }

    CGImageRef img= [MyImageChecker paintRegion:pixels bitmapWidth:width bitmapHeight:height forPoints:arrayValues withColor:UIColor.whiteColor.CGColor];

    free(pixels);
    return img;
}


- (void)saveZXbitmap:(ZXBinaryBitmap*)zxbitmap{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingString:@"bitmap"];

    //    ZXBinarizer *binerizer = [[ZXBinarizer alloc]initWithSource:<#(ZXLuminanceSource *)#>]
    //
    //    [ZXBinaryBitmap binaryBitmapWithBinarizer:<#(ZXBinarizer *)#>
}

- (NSString *) decodeBitMap : (ZXBinaryBitmap *) bitmap {

    /*
     Step 1: turn "bitmap" -> "graymap"
     */


    long times[10];
    times[0] = [[NSDate date] timeIntervalSince1970]*1000;
    NSLog(@"step1");

    ZXBitMatrix *binaryMatrix = [bitmap blackMatrixWithError: nil];


    [self saveZXbitmap:bitmap];

    int bitMapWidth = [binaryMatrix width];
    int bitMapHeight = [binaryMatrix height];

    NSLog(@"matrix wid %d hig %d",bitMapWidth,bitMapHeight);



    int *pixels=(int *)calloc(bitMapWidth * bitMapHeight,sizeof(int));
    for(int i=0;i<bitMapWidth * bitMapHeight; i++) {
        pixels[i] = 0;
    }

    /* set the pixels[] by "binary", then set the the "graymap"*/
    CGImageRef grayMap=[self setGrayMapByBinaryBitmap: binaryMatrix
                                                     : bitMapWidth
                                                     : bitMapHeight
                                                     : pixels];

    free(pixels);


    CGImageRef rotatedGraymap = NULL;

    size_t h = CGImageGetHeight(grayMap);
    size_t w = CGImageGetWidth(grayMap);

    int whetherChecked[h][w];

    //终于解决了这个问题不明白之前为什么用的很奇怪的二维数组
    int *whetherchecked=(int *)calloc(h*w,sizeof(int));
    for(int i=0;i<h*w; i++) {
        pixels[i] = 0;
    }

    //这里有内存问题
    //    memset(whetherChecked,0,h*w*sizeof(BOOL));
    //    for(int i = 0;i < h; i++){
    //        for(int j = 0; j < w; j++){
    //            whetherChecked[i][j] = 0;
    //        }
    //    }


    pixels=(int *)calloc(bitMapWidth * bitMapHeight,sizeof(int));
    int *temppixels=(int *)calloc(bitMapWidth * bitMapHeight,sizeof(int));
    [self getPixelsdata:bitMapWidth :bitMapHeight :grayMap :temppixels];
    memcpy(pixels, temppixels, bitMapWidth*bitMapHeight*sizeof(int));
    free(temppixels);

    /*
     step 2: get the precise center coodinate, and record in the pointsList
     */

    times[1] = [[NSDate date] timeIntervalSince1970]*1000;
    NSLog(@"step2");

    NSMutableArray<MyPoint*> *pointsList = [[NSMutableArray alloc] init];

    [self getPointsArrayByGravityCenter: whetherchecked: pointsList : pixels : bitMapWidth : bitMapHeight];

    free(whetherchecked);
    free(pixels);

    // if the number of points is less than the min of readable points num, return
    if([pointsList count] < (_side + 2) * (_side + 2)) {
        CGImageRelease(grayMap);
        CGColorSpaceRelease(rgbcolorspace);
        return @"no enough points";
    }

    //check the result
    CGImageRef showimg = [MyImageChecker locateCentres: grayMap forPoints: pointsList];


    /*
     step 3: find the theta by the pointsList
     */

    times[2] = [[NSDate date] timeIntervalSince1970]*1000;
    NSLog(@"step3");


    double theta = [self findRotateTheta:pointsList graymap: grayMap];

    if(theta == NOTHETA) {
        //free(pixels);
        CGImageRelease(grayMap);
        CGImageRelease(showimg);
        CGColorSpaceRelease(rgbcolorspace);
        return @ "rotate theta not found";
    }
    NSLog(@"rotate theta = %f", theta);

    /*
     we get the theta -- the angle between the standLine and the horizonLine
     but it's not the actual rotate theta we could use directly
     we still need some adjust
     */


    /*
     step 4: rotate the gaymap by "theta"
     */

    times[3] = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"step4");


    // 得到的角度范围（-180， 180）， 但是我们需要旋转的角度是standarLine与垂线的夹角
    // 顺时针旋转为正，逆时针旋转为负
    // 然后转化成弧度

    double radians = [self getRadiansBy: theta];
    NSLog(@"rotate radians = %f", radians);


    // 将整个图片旋转后的范围确定。（旋转后的原点和长宽均有变化），所以要根据此变化对旋转点后的变化做出调整
    // 扫描的区域在旋转的时候是以（rect.origin.x，rect.ortin.y）点为圆心旋转。弧度为正，顺时针旋转。
    // 旋转完成后, rect.origin.x, rect.origin.y. rect.width, rect.height 均会重新确定
    // 想要把（origin.x,origin.y） 重新转换回 （0，0）点，需要做平移操作
    CGRect rotatedRect=[self rotateRectangleOfWidth:bitMapWidth andHeight:bitMapHeight byAngle:radians];



    //用来检查是不是存在有点越界，其实没有必要，可以删去
    //    int failpointindex=[self firstPointNotInRectangleIndex:CGRectMake(0, 0, bitMapWidth, bitMapHeight) amongPoints:pointsList];
    //    if (failpointindex>=0){
    //            NSLog(@"fail origin i=%d x=%f,y=%f",failpointindex,pointsList[failpointindex].centX,pointsList[failpointindex].centY);
    //            return @"nothing";
    //    }


    //对点进行旋转操作，且要根据 “rotatedRect” 进行适当的位移操作，使之位于新的rect范围中
    NSMutableArray<MyPoint*> *rotatedPointsList;
    rotatedPointsList = [self rotatePoints : pointsList
                                 withAngle : radians
                             atRotatedRect : rotatedRect];

    //创建位移后的，以（0，0）为原点的新的窗口
    CGRect newRect = CGRectMake(0.0, 0.0, round(rotatedRect.size.width), round(rotatedRect.size.height));

    //  可以删去
    //    failpointindex=[self firstPointNotInRectangleIndex:rectafterrotate amongPoints:rotatedList];
    //
    //    if (failpointindex>=0){
    //        NSLog(@"fail after rotation i=%d x=%f,y=%f",failpointindex,rotatedList[failpointindex].centX,rotatedList[failpointindex].centY);
    //        return @"nothing";
    //
    //    }

    bitMapWidth = (int)round(newRect.size.width);
    bitMapHeight = (int)round(newRect.size.height);

    rotatedGraymap=[self getReducedImage:rotatedPointsList ofWidth:bitMapWidth andHeight:bitMapHeight];

    CGImageRelease(grayMap);

    /*
     step5: get the new rotated "pixels" from the rotated graymap
     */

    times[4] = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"step5");


    //  warning: could not execute support code to read Objective-C class data in the process. This may reduce the quality of type information available.


    int *rotatedPixels = (int *)calloc(bitMapWidth*bitMapHeight,sizeof(int));
    int *tempPixelData=(int *)calloc(bitMapWidth*bitMapHeight,sizeof(int));
    int *contextPixelsData = [self getPixelsdata:bitMapWidth:bitMapHeight:rotatedGraymap:tempPixelData];
    memcpy(rotatedPixels, contextPixelsData, bitMapWidth * bitMapHeight*sizeof(int));
    free(tempPixelData);


    /*
     step6: get the standardPoint and dataPoint
     */

    times[5] = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"step6");

    float linePointListX[2000],linePointListY[2000];
    memset(linePointListX,0,2000*sizeof(float));
    memset(linePointListY,0,2000*sizeof(float));


    float dataPointListX[120] = {0.0};
    float dataPointListY[120] = {0.0};



    //  这个排序是没有意义的，可以删去。但是越界情况又出现在了下面一句，说明问题是上面的内存分配问题上
    //  [rotatedPointsList sortUsingSelector:@selector(byxyvalues:)];

    float dataPointsMatrix[_noofpoints][_noofpoints][2];
    memset(dataPointsMatrix,0,_noofpoints*_noofpoints*2*sizeof(float));


    float standardPointsMatrix[_noofpoints][_noofpoints][2];
    memset(standardPointsMatrix,0,_noofpoints*_noofpoints*2*sizeof(float));


    //    BOOL whetherCheckedNew[bitMapHeight][bitMapWidth];
    //    memset(whetherCheckedNew,0,bitMapWidth*bitMapHeight*sizeof(BOOL));


    [self getStandardPointAndDataPoint: linePointListX
                                      : linePointListY
                                      : standardPointsMatrix
                                      : dataPointsMatrix
                                      : bitMapWidth
                                      : bitMapHeight
     //                                      : (BOOL *)whetherCheckedNew
                                      : rotatedPixels];
    free(rotatedPixels);
    //    ======================


    /*
     step7: check the first standardard line and the second
     */

    times[6] = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"step7");



    int indexOfFirstStandardPointsLine = [self findStartPoint:standardPointsMatrix];
    NSLog(@"point : start = %d", indexOfFirstStandardPointsLine);

    if (indexOfFirstStandardPointsLine == _noofpoints - (_side + 1)) {
        //free(pixels);
        CGImageRelease(rotatedGraymap);
        CGImageRelease(showimg);
        CGColorSpaceRelease(rgbcolorspace);
        NSLog(@"no proper start point");
        return @"no proper start point";
    }

    //  4.24 check the second line 出现了问题
    //  我认为检查第二行也是没有意义的，所以暂时决定删去
    //    if (![self checkSecondStandardLine: standardPoints
    //                                      : indexOfFirstStandardPointsLine]) {
    //
    //        CGImageRelease(rotatedGraymap);
    //        CGImageRelease(showimg);
    //        CGColorSpaceRelease(rgbcolorspace);
    //        NSLog(@"step6: can not verify the second standard line");
    //        return @"second standard line not verified";
    //    }


    // 标准点的坐标
    NSLog(@"points1: linepoints: \n");
    [self printAllPoints:standardPointsMatrix start:indexOfFirstStandardPointsLine end:indexOfFirstStandardPointsLine + _side + 1];
    // 数据点的坐标
    NSLog(@"points1: datapoints: \n");
    [self printAllPoints:dataPointsMatrix start:indexOfFirstStandardPointsLine end:indexOfFirstStandardPointsLine + _side + 1];

    //将数据点和线点转化为点Array然后呈现出来
    NSMutableArray<MyPoint *> *datatoarray=[self convertToArray:dataPointsMatrix];
    NSMutableArray<MyPoint *> *linetoarray=[self convertToArray:standardPointsMatrix];

    CGImageRef datashow;
    CGImageRef lineshow;
    //但是新的点坐标与原来的坐标呈上下镜像对称
    rotatedGraymap=[self mirrorConvert:rotatedPointsList ofWidth:bitMapWidth andHeight:bitMapHeight];
    datashow=[MyImageChecker locateCentres:rotatedGraymap forPoints:datatoarray ];
    lineshow=[MyImageChecker locateCentres:rotatedGraymap forPoints:linetoarray ];


    [self performPerspectiveTransform: standardPointsMatrix
                                     : dataPointsMatrix
                                     : indexOfFirstStandardPointsLine
                                     : linePointListX
                                     : linePointListY
                                     : dataPointListX
                                     : dataPointListY];


    // check the data coodinerate
    NSLog(@"points3: before arrangement: \n");
    [self printAllPoints:standardPointsMatrix start:indexOfFirstStandardPointsLine  end:indexOfFirstStandardPointsLine + _side + 1];
    [self printAllPoints:dataPointsMatrix start:indexOfFirstStandardPointsLine  end:indexOfFirstStandardPointsLine + _side + 1];

    // arrangement里面究竟做了些什么
    //  [self arrangePoints:xArrayValues : yArrayValues :points :foundStartPoint];

    // 把standardpoint 和 datapoint 合并
    [self arrangePoints0:standardPointsMatrix :dataPointsMatrix];

    //==========
    //debug: 检查所有点是否都转进了points
    NSLog(@"points3: after arrangement: \n");
    [self printAllPoints:standardPointsMatrix start:indexOfFirstStandardPointsLine  end:indexOfFirstStandardPointsLine + _side + 1];

    //将合并后用于decode的点阵转化成array然后显示在decodeshow中
    NSMutableArray<MyPoint *> *allPointsToArray=[self convertToArray:standardPointsMatrix];
    CGImageRef DecodeShowimg;
    //decodeshow 还需改进一下，但是经过transfer之后，点的坐标和形状都发生了改变，所以对不上
    DecodeShowimg = [MyImageChecker locateCentres:rotatedGraymap forPoints:allPointsToArray ];
    //=========


    /*
     Decode the PointsMatrix
     */

    NSString *retString = [self getRSDecodeResult:[self getDecodeResult:standardPointsMatrix :indexOfFirstStandardPointsLine]];

    /*
     step8: return
     */

    times[7] = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"step8");//end
    //    for(int i=0; i<8; i++) {
    //        NSLog(@"%@ time: %l", TAG, times[i]);
    //    }
    //free(pixels);


    CGImageRelease(rotatedGraymap);
    CGImageRelease(showimg);
    CGColorSpaceRelease(rgbcolorspace);
    CGImageRelease(datashow);
    CGImageRelease(lineshow);
    CGImageRelease(DecodeShowimg);


    if ([@"-3" isEqualToString:retString ]){
        NSLog(@"ECC error");
        return @"ECC error";
    }
    return retString;
}


-(double) getRadiansBy: (double) theta{
    if(theta > 0) theta = theta - 90;
    else theta = theta + 90;
    theta = -theta;
    NSLog(@"rotate angle = %f", theta);
    return theta * M_PI / 180;
}

-(int) firstPointNotInRectangleIndex : (CGRect) rect amongPoints :(NSMutableArray<MyPoint *> *) points{
    NSLog(@"pt cnt=%lu",(unsigned long)[points count]);
    for (int i=0;i<[points count];i++){
        MyPoint *thePoint=points[i];
        if (thePoint.centX<rect.origin.x || thePoint.centY < rect.origin.y)return i;
        if (thePoint.centX>=rect.origin.x+rect.size.width || thePoint.centY>=rect.origin.y+rect.size.height)return i;
    }
    return -1;
}


-(int) returnAnything :(int) yes{
    return yes;
}

-(NSMutableArray<MyPoint *> *) convertToArray :(float[_noofpoints][_noofpoints][2]) points {
    NSMutableArray<MyPoint *> *myarray=[[NSMutableArray alloc] init];
    for (int i=0;i<_noofpoints;i++){
        for(int j=0;j<_noofpoints;j++){
            if (points[i][j][0]==0.0 && points[i][j][1]==0.0){
                break;
            } else {
                [myarray addObject:[[MyPoint alloc] initWithCentX:points[i][j][0] andCentY:points[i][j][1]]];
            }
        }
    }
    return myarray;
}

-(NSMutableArray<MyPoint *> *) convertToArray0 :(double[5][2]) points {
    NSMutableArray<MyPoint *> *myarray=[[NSMutableArray alloc] init];

    for (int i=0;i<5;i++){
        [myarray addObject:[[MyPoint alloc] initWithCentX:points[i][0] andCentY:points[i][1]]];
    }
    return myarray;
}

-(void) printAllPoints :(float[_noofpoints][_noofpoints][2]) points
                  start:(int) startrow
                    end: (int) endrow{
    int flag = 0;
    for (int i= startrow; i<endrow+1 ;i++){
        printf("第%d列\n",i);
        for(int j=0;j<_noofpoints;j++){
            if(points[i][j][0] != 0 && points[i][j][1] != 0 ){
                printf("(%d,%d,%f,%f) ",i,j,points[i][j][0],points[i][j][1]);
                flag =1;
            }//增加了一个筛选
        }
        if(flag == 1){
            printf("\n");
        }
        flag = 0;
    }
}

- (CGImageRef) mirrorConvert : (NSMutableArray<MyPoint *> *) pointsList ofWidth: (int) width andHeight : (int) height  {

    const int WHITE = 0xFFFFFFFF;
    const int BLACK = 0x000000FF;

    uint32_t *pixels=calloc(width*height,sizeof(uint32_t));

    for(int i=0;i<width*height;i++){
        pixels[i]=BLACK;
    }
    for(int i=0;i<[pointsList count];i++){
        int x=(int)round(pointsList[i].centX);
        int y= height - (int)round(pointsList[i].centY);

        //为何会出现不够装的情况
        if(x <= width && y <= height){
            pixels[y*width+x]=WHITE;
        }
        //添加一个防止越界的条件，把超过的点裁减掉
        //这里估计又是写错了，这里是确实越界了  width和height 564*614， 但是这里的y等于617了
    }



    CGContextRef context = CGBitmapContextCreate( pixels, width, height, 8, width * sizeof(uint32_t), rgbcolorspace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast );

    // draw the image into the context

    // create a new CGImage from the context with modified pixels
    CGImageRef resultImage = CGBitmapContextCreateImage( context );

    // release resources to free up memory
    CGContextRelease( context );
    free(pixels);

    return resultImage;
}

- (CGImageRef) getReducedImage : (NSMutableArray<MyPoint *> *) pointsList ofWidth: (int) width andHeight : (int) height  {

    const int WHITE = 0xFFFFFFFF;
    const int BLACK = 0x000000FF;

    uint32_t *pixels=calloc(width*height,sizeof(uint32_t));

    for(int i=0;i<width*height;i++){
        pixels[i]=BLACK;
    }
    for(int i=0;i<[pointsList count];i++){
        int x=(int)round(pointsList[i].centX);
        int y=(int)round(pointsList[i].centY);

        //为何会出现不够装的情况
        if(x <= width && y <= height){
            pixels[y*width+x]=WHITE;
        }
        //添加一个防止越界的条件，把超过的点裁减掉
        //这里估计又是写错了，这里是确实越界了  width和height 564*614， 但是这里的y等于617了
    }

    CGContextRef context = CGBitmapContextCreate( pixels, width, height, 8, width * sizeof(uint32_t), rgbcolorspace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast );

    // draw the image into the context

    // create a new CGImage from the context with modified pixels
    CGImageRef resultImage = CGBitmapContextCreateImage( context );

    // release resources to free up memory
    CGContextRelease( context );
    free(pixels);

    return resultImage;
}




- (int) findLinePoint : (NSArray<MyPoint *> *) possiblePoints : (NSMutableArray<MyPoint *> *) pointsList {
    if(possiblePoints[0] != nil) {
        for(int j=0; j<[pointsList count]; j++) {
            [pointsList[j] setDistanceTo: possiblePoints[0]];
            [pointsList sortUsingSelector: @selector(distanceCompare:)];
            if([pointsList[0] distance] < 2) {
                for(int j=0; j<[pointsList count]; j++) {
                    [pointsList[j] setDistanceTo: possiblePoints[1]];
                }
                [pointsList sortUsingSelector: @selector(distanceCompare:)];
                if([possiblePoints[0] distance] < 2) {
                    return 0;
                }
            }
        }
    }

    return -1;
}





- (void) getPointsArray : (BOOL *) whetherChecked : (NSMutableArray<MyPoint *> *) pointsList : (int *) pixels
                        : (int) bitMapWidth : (int) bitMapHeight {
    for (int j = 0; j < bitMapWidth; j++) {
        for (int i = 0; i < bitMapHeight; i++) {
            if (!*(whetherChecked+i*bitMapWidth+j) && (0xF00 & pixels[(bitMapHeight - 1 - i) * bitMapWidth + j]) != 0) {
                int lastMove = 1;

                int originX, changeX, xs, xe;
                int originY, changeY, ys, ye;
                originX = changeX = xs = xe = j;
                originY = changeY = ys = ye = i;

                while (YES) {
                    for (int k = 0; k < 4; k++) {
                        int tempMoveDirection = (lastMove + k + 3) % 4;
                        int tempX = changeX + changePixelCenter[tempMoveDirection][0];
                        int tempY = changeY + changePixelCenter[tempMoveDirection][1];

                        if ((tempX > -1) && (tempY > -1) && (tempX < bitMapWidth)
                            && (tempY < bitMapHeight) && !*(whetherChecked+tempY*bitMapWidth+tempX)
                            && (((0xF & pixels[(bitMapHeight - 1 - tempY) * bitMapWidth + tempX])) != 0)) {
                            changeX = tempX;
                            changeY = tempY;
                            lastMove = tempMoveDirection;
                            break;
                        }
                    }

                    if (changeX > xe)
                        xe = changeX;

                    if (changeX < xs)
                        xs = changeX;

                    if (changeY > ye)
                        ye = changeY;

                    if (changeY < ys)
                        ys = changeY;

                    if (changeX == originX && changeY == originY)
                        break;
                }

                for (int setI = ys; setI <= ye; setI++) {
                    for (int setJ = xs; setJ <= xe; setJ++) {
                        *(whetherChecked+setI*bitMapWidth+setJ) = YES;
                    }
                }

                float centX = ((float) xs + xe) / 2;
                float centY = ((float) ys + ye) / 2;

                MyPoint *newPoint = [[MyPoint alloc] initWithCentX:centX andCentY:centY];
                [pointsList addObject:newPoint];
            }
        }
    }
}


- (NSMutableArray<MyPoint *> *) rotatePoints : (NSMutableArray<MyPoint *> *) pointsList
                                   withAngle :(double) angle
                               atRotatedRect :(CGRect) rrect
{
    CGAffineTransform t1;
    // t1=CGAffineTransformMakeTranslation((CGFloat)width/2.0, (CGFloat)height/2.0);
    t1=CGAffineTransformMakeRotation(angle);

    CGFloat trx=0.0,try=0.0;  //x轴和y轴的位移量

    if (rrect.origin.x<0) trx = -rrect.origin.x;
    if (rrect.origin.y<0) try = -rrect.origin.y;

    //    t1 = CGAffineTransformTranslate(t1, trx, try); //在t1位移的基础上, 平移 t1, t2
    NSMutableArray<MyPoint *> * rotatedPointsList=[[NSMutableArray alloc] init];

    for (int i=0;i<[pointsList count];i++){
        MyPoint *mypoint=pointsList[i];
        CGPoint cgpoint=CGPointMake(mypoint.centX, mypoint.centY);
        CGPoint cgpointr=CGPointApplyAffineTransform(cgpoint, t1);

        MyPoint *mypointr=[[MyPoint alloc] initWithCentX:(double)cgpointr.x + trx andCentY:(double)cgpointr.y + try];
        [rotatedPointsList addObject:mypointr];
    }
    //    MyPoint *basePoint=[[MyPoint alloc] initWithCentX:0 andCentY:0];
    //    [rotatedPointsList addObject:basePoint];

    return rotatedPointsList;
}




- (CGRect) rotateRectangleOfWidth :(int)width andHeight:(int) height byAngle :(double) angle {
    CGRect imgRect = CGRectMake(0, 0, width, height);

    //该种方法的旋转都是按照rect的(orgin.x, origin.y)来旋转的，所以每次旋转的中心都会改变
    //CGAffineTransformRotate() 该种方法每次都是按照上次旋转之后的中心的进行旋转
    CGAffineTransform __transform = CGAffineTransformMakeRotation((CGFloat)angle);


    //可知旋转是按照原图的（0，0）点旋转的。 新图的边界均有变化

    CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, __transform);

    //    可以删去
    //    (CGAffineTransform) __transform = (a = 0.96656944077345242, b = 0.25640498466858158, c = -0.25640498466858158, d = 0.96656944077345242, tx = 0, ty = 0)
    //    (CGRect) rotatedRect = (origin = (x = -104.86963872944986, y = 0), size = (width = 467.33317901949454, height = 491.47877052706014))
    //make the rectangle larger
    //    CGFloat orx=rotatedRect.origin.x;
    //    CGFloat ory=rotatedRect.origin.y;
    //    CGFloat wid=rotatedRect.size.width;
    //    CGFloat hei=rotatedRect.size.height;
    //    if (orx<0)orx=1.3*orx;
    //    if (ory<0)ory=1.3*ory;
    //    wid=1.6*wid;
    //    hei=1.6*hei;
    return rotatedRect;
}




-(void)getPointsArrayByGravityCenter :(int *) whetherChecked : (NSMutableArray<MyPoint *> *) pointsList : (int *) pixels
                                     : (int) bitMapWidth: (int) bitMapHeight{

    NSMutableArray<NSValue *> *mine=[[NSMutableArray<NSValue *> alloc ] init];

    //    NSArray<int *> *checklist = [[NSMutableArray alloc] init];

    for (int j = 0; j < bitMapWidth; j++) {
        for (int i = 0; i < bitMapHeight; i++) {
            if (!*(whetherChecked+i*bitMapWidth+j) && (0xF00 & pixels[(i) * bitMapWidth + j]) != 0) {
                //Debug
                //   region=[[NSMutableArray<MyPoint *> alloc] init];

                //End
                Imgpos initpos;
                initpos.x=j;
                initpos.y=i;
                NSValue *initposVal=[NSValue valueWithBytes:&initpos objCType:@encode(Imgpos)];
                //Insert first pixel encountered into the queue
                *(whetherChecked+i*bitMapWidth+j)=YES;
                [mine addObject:initposVal];
                float totalX=0.0;
                float totalY=0.0;
                int pointcnt=0;
                //BFSearch with each black spot as graph
                while([mine count]>0){
                    Imgpos thepos;

                    NSValue *theposval=mine[0];
                    [mine removeObjectAtIndex:0];
                    [theposval getValue:&thepos];
                    //NSLog(@"point=(%d,%d)\n",thepos.x,thepos.y);
                    totalX+=(float)thepos.x;
                    totalY+=(float)thepos.y;
                    //Debug
                    //         [region addObject:[[MyPoint alloc] initWithCentX:(double)thepos.x andCentY:(double)thepos.y]];

                    //End
                    pointcnt++;

                    int setI=thepos.y;
                    int setJ=thepos.x;
                    //Set the point as processed

                    //Add all the unprocessed neighbours of the the point to the queue
                    for (int disi=-1;disi<=1;disi++){
                        for (int disj=-1;disj<=1;disj++){
                            if(disi!=0 || disj!=0){//not the same point
                                if(setI+disi>=0 && setJ+disj>=0 && setI+disi<bitMapHeight && setJ+disj<bitMapWidth){ //check range
                                    int i1=setI+disi;
                                    int j1=setJ+disj;
                                    if (!*(whetherChecked+i1*bitMapWidth+j1) && (0xF00 & pixels[(i1) * bitMapWidth + j1]) != 0) {
                                        //Add unchecked white neighbour
                                        Imgpos neighbor;
                                        neighbor.x=j1;
                                        neighbor.y=i1;
                                        NSValue *neighborVal=[NSValue valueWithBytes:&neighbor objCType:@encode(Imgpos)];
                                        *(whetherChecked+i1*bitMapWidth+j1)=YES;
                                        [mine addObject:neighborVal];


                                    }//if ongraph unprocessed

                                }// if in range
                            }//if not same
                        }// for -1<=disj<=1
                    }//for -1<=disi<=1

                }//until queue is empty
                float centX=(float)totalX/pointcnt;
                float centY=(float)totalY/pointcnt;


                //Debug

                //      CGImageRef regionview=[MyImageChecker paintRegion:pixels bitmapWidth:bitMapWidth bitmapHeight:bitMapWidth forPoints:region withColor: [UIColor yellowColor].CGColor]     ;           //End
                //     CGImageRelease(regionview);

                //End

                //NSLog(@"cnt=%d centre=(%.2f,%.2f)\n\n\n",pointcnt,centX,centY);


                if (pointcnt>2){  //If there are at least 3 points,initialize
                    MyPoint *newPoint = [[MyPoint alloc] initWithCentX:centX andCentY:centY];

                    [pointsList addObject:newPoint];
                }


            } //if the point is an unprocessed black pixel

        } //for j in width range
    } //for i in height range
}


- (CGImageRef) setGrayMapByBinaryBitmap : (ZXBitMatrix *) binaryMatrix
                                        : (int) bitMapWidth : (int) bitMapHeight : (int *) pixels {
    const int WHITE = 0xFFFFFFFF;
    const int BLACK = 0x000000FF;


    for (int y = 0; y < bitMapHeight; y++) {
        int offset = y * bitMapWidth;
        for (int x = 0; x < bitMapWidth; x++) {
            pixels[offset + x] = [binaryMatrix getX:x y:y] ? WHITE : BLACK;
        }
    }
    //create color object
    //create a context with ARGB pixels
    CGContextRef context = CGBitmapContextCreate(pixels, bitMapWidth, bitMapHeight, 8, bitMapWidth * 4, rgbcolorspace,(CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    //paint the bitmap to our context which will fill in the pixels array
    CGImageRef grayMap = CGBitmapContextCreateImage(context);
    //release objects
    CGContextRelease(context);
    return grayMap;
}



- (void) swapPoints : (int) i1 : (int) j1 : (int) i2 : (int) j2 : (float[_noofpoints][_noofpoints][2]) points {
    float tempX = points[i1][j1][0];
    float tempY = points[i1][j1][1];
    points[i1][j1][0] = points[i2][j2][0];
    points[i1][j1][1] = points[i2][j2][1];
    points[i2][j2][0] = tempX;
    points[i2][j2][1] = tempY;
}


- (void) sortPoints : (float[_noofpoints][_noofpoints][2]) points {
    int length = _noofpoints;

    for(int i=0; i<length; i++) {
        for(int j=0; j<length; j++) {
            if(points[i][j][1] == 0.0 && points[i][j][0] == 0.0) {
                break;
            }

            for(int k=j+1; k<length; k++) {
                if(points[i][k][1] == 0.0 && points[i][k][0] == 0.0) {
                    break;
                }
                if(points[i][j][1] > points[i][k][1]) {
                    [self swapPoints:i:j:i:k:points];
                }
            }

        }
    }
}


-(double) findRotateTheta0 : (NSMutableArray<MyPoint *> *) pointsList {
    const int config[6][2] = {{1, 2}, {1, 3}, {2, 4}, {2, 3}, {2, 4}, {3, 4}};
    double foundTheta = 500;
    BOOL isFound = NO;
    int indexOfSelectingPoint = 0;
    while( !isFound && indexOfSelectingPoint < [pointsList count]){
        MyPoint *selectingPoint = pointsList[indexOfSelectingPoint++];


        NSMutableArray<MyPoint *> * sortedPointsList = pointsList;
        for (int i = 0; i < [pointsList count] ; i++){
            [sortedPointsList[i] setDistanceTo: selectingPoint];
        }
        [sortedPointsList sortUsingSelector:@selector(compare:)];

        for(int i = 0; i < 6; i++){
            MyPoint *point1 = sortedPointsList[config[i][0]];
            MyPoint *point2 = sortedPointsList[config[i][1]];
            MyPoint *midPointOfTwoPoints = [[MyPoint alloc] initWithCentX:(point1.centX + point2.centX)/2 andCentY:(point1.centY + point2.centY)];
            [midPointOfTwoPoints setDistanceTo:selectingPoint];
            if( midPointOfTwoPoints.distance < 2.0){
                MyPoint *preditctPoint1 = [[MyPoint alloc] initWithCentX:(2*point1.centX - selectingPoint.centX) andCentY:(2*point1.centY - selectingPoint.centY)];
                MyPoint *preditctPoint2 = [[MyPoint alloc] initWithCentX:(2*point2.centX - selectingPoint.centX) andCentY:(2*point2.centY - selectingPoint.centY)];
                NSArray<MyPoint *> *possiblePoints = @[preditctPoint1, preditctPoint2];
                if([self findLinePoint:possiblePoints :pointsList]){
                    isFound = YES;
                    foundTheta = atan(point1.centY - point2.centY) / (point1.centX - point2.centX) / M_PI * 180;
                    break;
                }
            }
        }
    }
    return foundTheta;
}




- (double) findRotateTheta : (NSMutableArray<MyPoint *> *) pointsList
                   graymap : (CGImageRef) graymap {
    const int config[6][2] = {{0, 1}, {0, 2}, {0, 3}, {1, 2}, {1, 3}, {2, 3}};
    double foundTheta = 500;
    BOOL whetherFound = NO;
    int countSelectingPoint = 0;

    NSMutableArray<MyPoint *> * pointsListcopy = pointsList;

    //    NSMutableArray<MyPoint*> *pointsListcopy = [[NSMutableArray alloc] init];
    //    for(int i = 0; i < len; i++){
    //        pointsListcopy[i] = pointsList[i];
    //     }


    int len = pointsList.count;

    while (!whetherFound && countSelectingPoint < len) {

        MyPoint *midPoint = pointsList[countSelectingPoint];

        //        NSLog(@"rotate at %d: (%f, %f)", countSelectingPoint, midPoint.centX, midPoint.centY);
        //指针走的是没有问题的，但是后面排布之后就有问题了

        countSelectingPoint ++;

        for(int i=0; i<len; i++) {
            [pointsListcopy[i] setDistanceTo: midPoint];
        }

        [pointsListcopy sortUsingSelector: @selector(distanceCompare:)];

        //        NSLog(@"rotate sort at %d: (%f, %f) with distance = %f", countSelectingPoint, pointsListcopy[0].centX, pointsListcopy[0].centY, pointsListcopy[0].distance);

        double fivePoints[5][2];
        for(int i=0; i<5; i++) {
            fivePoints[i][0] = [pointsListcopy[i] centX];
            fivePoints[i][1] = [pointsListcopy[i] centY];
        }

        //        NSLog(@"rotate center (%f, %f)", fivePoints[0][0], fivePoints[0][1]);


        int m = 0;
        int n = 0;

        for(int i=0; i<6; i++) {
            m = config[i][0];
            n = config[i][1];

            double disPair = [pointsListcopy[m+1] distance] + [pointsListcopy[n+1] distance];
            double ratePair = [pointsListcopy[m+1] distance] / [pointsListcopy[n+1] distance];

            if(PAIRMAX > ratePair && ratePair > PAIRMIN &&
               hypot((fivePoints[m][1] - fivePoints[n][1]), (fivePoints[m][0] - fivePoints[n][0])) / disPair > PAIRMIN) {
                MyPoint *point0 = [[MyPoint alloc] initWithCentX:(2 * [pointsListcopy[m+1] centX] - [midPoint centX])
                                                        andCentY:(2 * [pointsListcopy[m+1] centY] - [midPoint centY])];
                MyPoint *point1 = [[MyPoint alloc] initWithCentX:(2 * [pointsListcopy[n+1] centX] - [midPoint centX])
                                                        andCentY:(2 * [pointsListcopy[n+1] centY] - [midPoint centY])];
                NSArray<MyPoint *> *possiblePoints = @[point0, point1];

                int findResult = [self findLinePoint: possiblePoints : pointsListcopy];
                if(findResult != -1) {
                    whetherFound = YES;
                    foundTheta = atan2((fivePoints[m][1] - fivePoints[n][1]), (fivePoints[m][0] - fivePoints[n][0])) / M_PI * 180;

                    NSMutableArray<MyPoint *> *twoPointToArray=[self convertToArray0:fivePoints];
                    CGImageRef rotatePointshow;
                    rotatePointshow =[MyImageChecker locateCentres:graymap forPoints:twoPointToArray];

                    NSLog(@"rotate center (%f, %f)", midPoint.centX, midPoint.centY);
                    NSLog(@"rotate (%f, %f)(%f,%f)",fivePoints[m][0],fivePoints[m][1],fivePoints[n][0],fivePoints[n][1]);

                    CGImageRelease(rotatePointshow);
                    break;
                }
            }
        }

    }
    return foundTheta;
}


- (CGImageRef) rotateBitmapWithDegree : (double) degree bitMap: (CGImageRef) grayMap {
    if (degree == 0.0f) {
        CGImageRetain(grayMap);
        return grayMap;
    }

    double radians = degree * M_PI / 180;

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
    radians = -1*radians;
#endif

    size_t width = CGImageGetWidth(grayMap);
    size_t height = CGImageGetHeight(grayMap);

    CGRect imgRect = CGRectMake(0, 0, width, height);
    CGAffineTransform __transform = CGAffineTransformMakeRotation(radians);
    CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, __transform);

    ;
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 rotatedRect.size.width,
                                                 rotatedRect.size.height,
                                                 CGImageGetBitsPerComponent(grayMap),
                                                 0,
                                                 rgbcolorspace,
                                                 kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
    //    CGContextRef context = CGBitmapContextCreate(NULL,
    //                                                     rotatedRect.size.width,
    //                                                     rotatedRect.size.height,
    //                                                     CGImageGetBitsPerComponent(grayMap),
    //                                                     0,
    //                                                     colorSpace,
    //                                                     kCGBitmapAlphaInfoMask & kCGImageAlphaFirst);
    CGContextSetAllowsAntialiasing(context, FALSE);
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);


    CGContextTranslateCTM(context,
                          +(rotatedRect.size.width/2),
                          +(rotatedRect.size.height/2));
    CGContextRotateCTM(context, radians);

    CGContextDrawImage(context, CGRectMake(-imgRect.size.width/2,
                                           -imgRect.size.height/2,
                                           imgRect.size.width,
                                           imgRect.size.height),
                       grayMap);

    CGImageRef rotatedImage = CGBitmapContextCreateImage(context);
    CFRelease(context);

    return rotatedImage;
}

-(CGImageRef) enlargeImage :(CGImageRef) image withratio:(double) ratio {
    if (ratio == 1.0) {
        CGImageRetain(image);
        return image;
    }
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    CGRect imgRect = CGRectMake(0, 0, width, height);


    CGAffineTransform __transform=CGAffineTransformMakeScale(ratio, ratio);
    CGRect scaleRect = CGRectApplyAffineTransform(imgRect, __transform);
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 scaleRect.size.width,
                                                 scaleRect.size.height,
                                                 CGImageGetBitsPerComponent(image),
                                                 0,
                                                 rgbcolorspace,
                                                 kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);

    CGContextSetAllowsAntialiasing(context, FALSE);
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, ratio, ratio);
    CGContextDrawImage(context, imgRect,
                       image);
    CGImageRef scaleImg=CGBitmapContextCreateImage(context);
    CFRelease(context);

    return scaleImg;




}



- (NSMutableArray<MyPoint*> *)getSecondLinePoints :(NSMutableArray<MyPoint*> *)sortedPoints forIndex :(int)index {

    return nil;

}


- (void) getStandardPointAndDataPoint : (float *) xArrayValues : (float *) yArrayValues
                                      : (float[_noofpoints][_noofpoints][2]) linePoints
                                      : (float[_noofpoints][_noofpoints][2]) dataPoints
                                      : (int) bitMapWidth
                                      : (int) bitMapHeight
//                                      : (BOOL *) whetherChecked
                                      : (int *) pixels {
    BOOL alreadyOne = NO;
    BOOL lineChange = NO;
    int countXYValues = 0;
    BOOL firstRound = YES;
    double interval = 0;
    int indexI = 0;
    int indexJ = 0;

    // 为什么另一处类似的用法就没有问题？？我觉得可能是whetherChecked这个指针没有释放，产生了野指针
    //    BOOL whetherCheckednew[bitMapHeight][bitMapWidth];
    //    memset(whetherCheckednew,0,bitMapWidth*bitMapHeight*sizeof(BOOL));

    //    for(int i = 0; i < bitMapHeight; i++){
    //        for(int j = 0; j < bitMapWidth; j++){
    //            whetherCheckednew[i][j] = NO;
    //        }
    //    }
    //    BOOL *whetherChecked = &whetherCheckednew[0][0];

    // const int WHITE = 0xFFFFFFFF;
    // const int BLACK = 0x000000FF;
    // pixels 是一个对bitmap横向扫描的数组, 其坐标等于 y * bitmapwidth + x
    // 该部分已知信息，是从下往上逐行扫描的

    //    whetherChecked <--> pixels 两者相对应

    for (int j = 0; j < bitMapWidth; j++) {
        for (int i = 0; i < bitMapHeight; i++) {
            if ((0xFF00 & pixels[(bitMapHeight - 1 - i) * bitMapWidth + j]) >= 0x8000 && (0xFF & pixels[(bitMapHeight - 1 - i) * bitMapWidth + j])==0xFF) {
                // 检查条件： 第一部分： pixels[(bitMapHeight - 1 - i) * bitMapWidth + j] is white

                //whether 是正常顺序

                //Check to see white points in the neighbourhood
                //Due to inbuilt errors in rotation

                float centX = (float)j;

                //changed
                //                float centY = (float)(bitMapHeight - 1 - i);
                float centY = (float)i;

                //centX和centY代表的是检查点的坐标
                //the second half check is to make segment line into one
                if (firstRound || (centX - linePoints[0][0][0] < 0.1 * interval)) {
                    linePoints[indexI][indexJ][0] = centX;
                    linePoints[indexI][indexJ][1] = centY;
                    if (indexJ < _noofpoints-1) {
                        indexJ++;
                    }

                }else {
                    for (int m = 0; m < (_noofpoints-1); m++) {
                        if (linePoints[0][m + 1][1] == linePoints[_noofpoints-1][_noofpoints-1][1] &&
                            (fabsf(centY - linePoints[0][m][1]) > 0.5 * interval)) {
                            break;
                        }
                        if (fabsf(centY - linePoints[0][m][1]) < fabsf(centY - linePoints[0][m + 1][1]) &&
                            (fabsf(centY - linePoints[0][m][1]) < 0.5 * interval)) {


                            double tempIndexI = (centX - linePoints[0][m][0]) / interval;
                            double floorIndexI = floor(tempIndexI);
                            if (tempIndexI - floorIndexI > 0.5) {
                                indexI = (int) floorIndexI + 1;
                            } else {
                                indexI = (int) floorIndexI;
                            }

                            if (indexI < _noofpoints && ((linePoints[indexI][m][0] == linePoints[_noofpoints-1][_noofpoints-1][0] &&
                                                          linePoints[indexI][m][1] == linePoints[_noofpoints-1][_noofpoints-1][1])
                                                         || (m == 0 && centY > linePoints[indexI][m][1])) && indexI == _side+1) {
                                //                                NSLog(@"at Line m=%d indexI=%d x,y= %f,%f",m,indexI,centX,centY);
                                linePoints[indexI][m][0] = centX;
                                linePoints[indexI][m][1] = centY;
                            } else {
                                //NSLog(@"At Data m=%d indexI=%d x,y= %f,%f",m,indexI,centX,centY);
                                xArrayValues[countXYValues] = centX;
                                yArrayValues[countXYValues] = centY;
                                dataPoints[indexI][m][0] = centX;
                                dataPoints[indexI][m][1] = centY;
                                countXYValues++;
                            }
                            break;
                        }
                        //end if
                    }
                }

                lineChange = YES;
                alreadyOne = YES;
            }
        }

        if (!lineChange && alreadyOne && firstRound) {
            firstRound = NO;
            [self sortPoints: linePoints];
            for(int i=0; i<_noofpoints; i++) {
                if (linePoints[0][i][0] == linePoints[_noofpoints-1][_noofpoints-1][0] && linePoints[0][i][1] == linePoints[_noofpoints-1][_noofpoints-1][1] && i > 0) {
                    interval = (linePoints[0][i - 1][1] - linePoints[0][0][1]) / (double) (i - 1);
                    if (i < _side+2) {
                        indexI = 0;
                        indexJ = 0;
                        firstRound = YES;
                        [self fillArrayZero:linePoints];
                        break;
                    }

                    for(int k=1; k<i-1; k++) {
                        if (fabsf(2 * linePoints[0][k][1] - linePoints[0][k - 1][1] - linePoints[0][k + 1][1]) > 3 ||
                            hypot(fabsf(linePoints[0][k + 1][1] - linePoints[0][k - 1][1]),
                                  fabsf(linePoints[0][k + 1][0] - linePoints[0][k - 1][0])) /
                            (hypot(fabsf(linePoints[0][k + 1][1] - linePoints[0][k][1]),
                                   fabsf(linePoints[0][k + 1][0] - linePoints[0][k][0])) +
                             hypot(fabsf(linePoints[0][k][1] - linePoints[0][k - 1][1]),
                                   fabsf(linePoints[0][k][0] - linePoints[0][k - 1][0]))) < PAIRMIN){
                                 indexI = 0;
                                 indexJ = 0;
                                 firstRound = YES;
                                 [self fillArrayZero:linePoints];
                                 break;
                             }
                    }
                    break;
                }
            }

            alreadyOne = NO;
        }

        lineChange = NO;
    }
    //    NSLog(@"countXY=%d",countXYValues);
}




- (void) fillArrayZero : (float[_noofpoints][_noofpoints][2]) points {
    for(int i=0; i<_noofpoints; i++) {
        points[0][i][0] = 0;
        points[0][i][1] = 0;
    }
}


- (int) findStartPoint : (float[_noofpoints][_noofpoints][2]) points {
    int foundStartPoint = 0;

    for(int i=0; i<_noofpoints-(_side+1); i++) {
        if((points[_side+1][i][0] != 0.0 || points[_side+1][i][1] != 0.0)
           && (points[_side+1][i+_side+1][0] != 0.0 || points[_side+1][i+_side+1][1] != 0.0)) {
            break;
        } else {
            foundStartPoint ++;
        }
    }
    return foundStartPoint;
}


- (BOOL) checkSecondStandardLine : (float [_noofpoints][_noofpoints][2]) point1
                                 : (int) foundStartPoint {
    float points[_noofpoints][_noofpoints][2];
    memcpy(points, point1, _noofpoints*_noofpoints*2*sizeof(float));
    for(int i=0; i<_side; i++) {
        double disFtoS = hypot((points[_side+1][foundStartPoint + i][0]     - points[_side+1][foundStartPoint + i + 1][0]),
                               (points[_side+1][foundStartPoint + i][1]     - points[_side+1][foundStartPoint + i + 1][1]));
        double disStoT = hypot((points[_side+1][foundStartPoint + i + 1][0] - points[_side+1][foundStartPoint + i + 2][0]),
                               (points[_side+1][foundStartPoint + i + 1][1] - points[_side+1][foundStartPoint + i + 2][1]));
        double disFtoT = hypot((points[_side+1][foundStartPoint + i][0]     - points[_side+1][foundStartPoint + i + 2][0]),
                               (points[_side+1][foundStartPoint + i][1]     - points[_side+1][foundStartPoint + i + 2][1]));

        //        NSLog(@"FS=%f ST=%f FT=%f",disFtoS,disStoT,disFtoT);

        double tempRate = disFtoS / disStoT;
        //        NSLog(@"dis ratio=%f curve ratio=%f",tempRate,(disFtoT / (disFtoS + disStoT)));
        if (PAIRMAX < tempRate || tempRate < PAIRMIN || (disFtoT / (disFtoS + disStoT)) < PAIRMIN) {
            return NO;
        }
    }

    printf("check the secondline is ok \n");
    return YES;
}


- (void) performPerspectiveTransform : (float [_noofpoints][_noofpoints][2]) point1
                                     : (float [_noofpoints][_noofpoints][2]) point2
                                     : (int) foundStartPoint
                                     : (float *) xArrayValues
                                     : (float *) yArrayValues
                                     : (float *) xValues
                                     : (float *) yValues {

    float points[_noofpoints][_noofpoints][2];
    memcpy(points, point1, _noofpoints*_noofpoints*2);
    float datapoints[_noofpoints][_noofpoints][2];
    memcpy(datapoints, point2, _noofpoints*_noofpoints*2);

    int start = 50;
    int end = (int)(start+INTERVAL*(_side+1));

    ZXPerspectiveTransform *perspectiveTransform =
    [ZXPerspectiveTransform quadrilateralToQuadrilateral: points[0] [foundStartPoint][0]
                                                      y0: points[0][foundStartPoint][1]
                                                      x1:points[0][foundStartPoint+_side+1][0]
                                                      y1:points[0][foundStartPoint+_side+1][1]
                                                      x2:points[_side+1][foundStartPoint][0]
                                                      y2:points[_side+1][foundStartPoint][1]
                                                      x3:points[_side+1][foundStartPoint+_side+1][0]
                                                      y3:points[_side+1][foundStartPoint+_side+1][1]
                                                     x0p:start y0p:start
                                                     x1p:start y1p:end
                                                     x2p:end y2p:start
                                                     x3p:end y3p:end];
    for (int j=0; j<_noofpoints; j++) {
        if(points[0][j][0] != 0 && points[0][j][1] != 0){
            xValues[j] = points[0][j][0];
            yValues[j] = points[0][j][1];
            xValues[_noofpoints + j] = points[_side+1][j][0];
            yValues[_noofpoints + j] = points[_side+1][j][1];
        }
    }//转化linePoints到array

    for(int i = foundStartPoint + 1; i < foundStartPoint + _side + 1; i++ ){
        for (int j=0; j<_noofpoints; j++) {
            xArrayValues[(i-1) * _noofpoints + j] = datapoints[i][j][0];
            yArrayValues[(i-1) * _noofpoints + j] = datapoints[i][j][1];
        }
    }//转化datapoint到array

    //xValues, yValues 是所有标准点的坐标
    //xArrayValues, yArrayValues 是所有datapoint的坐标

    //uncertain
    [perspectiveTransform transformPoints:xValues yValues:yValues pointsLen:90];
    [perspectiveTransform transformPoints:xArrayValues yValues:yArrayValues pointsLen:225];

    //    把转换完成的值返回
    for (int j=0; j <_noofpoints; j++) {
        points[0][j][0] = xValues[j];
        points[0][j][1] = yValues[j];
        points[_side + 1][j][0] = xValues[_noofpoints + j];
        points[_side + 1][j][1] = yValues[_noofpoints + j];
    }

    for(int i = foundStartPoint + 1; i < foundStartPoint + _side + 1; i++ ){
        for (int j=0; j<_noofpoints; j++) {
            datapoints[i][j][0] = xArrayValues[(i-1) * _noofpoints + j];
            datapoints[i][j][1] = yArrayValues[(i-1) * _noofpoints + j] ;
        }
    }

    //    是不是有点问题在于把坐标总原本没有点的（0，0）也给转换了坐标导致出现错误
    //    UNDO 可以在这个位置看一下转换坐标的标准点是否有问题
    //    NSMutableArray<MyPoint *> *toarray=[self convertToArray:points];
    //    CGImageRef newshowimg;
    //    newshowimg=[MyImageChecker locateCentres:grayMap1 forPoints:toarray ];
    //
    memcpy(point1,points, _noofpoints*_noofpoints*2);
    memcpy(point2,datapoints, _noofpoints*_noofpoints*2);
}



//该算法用来合并经过转化后的linepoints以及datapoints
//并且要求修剪掉不合格的点，并设为（0，0）
- (void) arrangePoints0 : (float [_noofpoints][_noofpoints][2]) linePoints
                        : (float [_noofpoints][_noofpoints][2]) dataPoints{
    float points[_noofpoints][_noofpoints][2];
    memset(points, 0, _noofpoints*_noofpoints*2);

    for(int i = 0; i < 7; i++){
        for (int j = 0; j < _noofpoints; j++){
            if(linePoints[i][j][0]>0 && linePoints[i][j][1]>0){
                points[i][j][0] = linePoints[i][j][0];
                points[i][j][1] = linePoints[i][j][1];
            }else if (dataPoints[i][j][0] > 0 && dataPoints[i][j][1] > 0){
                points[i][j][0] = dataPoints[i][j][0];
                points[i][j][1] = dataPoints[i][j][1];
            }
        }
    }
    memcpy(linePoints, points, _noofpoints*_noofpoints*2);
}


- (void) arrangePoints : (float *)xArrayValues
                       : (float *)yArrayValues
                       : (float *) point1
                       : (int) foundStartPoint {
    float points[_noofpoints][_noofpoints][2];
    memcpy(points, point1, _noofpoints*_noofpoints*2);

    double interval = INTERVAL;
    int indexI = 0;
    for(int i=0; i<2000; i++) {

        if (xArrayValues[i] == 0.0 && yArrayValues[i] == 0.0) {
            break;
        }
        for (int m = foundStartPoint; m < (_noofpoints - 1); m++) {
            if (points[0][m + 1][1] == points[_noofpoints-1][_noofpoints-1][1] &&
                (fabsf(yArrayValues[i] - points[0][m][1]) > 0.5 * interval))  {
                break;
            }

            if (fabsf(yArrayValues[i] - points[0][m][1]) < fabsf(yArrayValues[i] - points[0][m + 1][1]) && (fabsf(yArrayValues[i] - points[0][m][1]) < 0.5 * interval)) {
                double tempIndexI = (xArrayValues[i] - points[0][m][0]) / interval;
                double floorIndexI = floor(tempIndexI);
                if (tempIndexI - floorIndexI > 0.5) {
                    indexI = (int) floorIndexI + 1;
                } else {
                    indexI = (int) floorIndexI;
                }

                BOOL pointEqual=(points[indexI][m][0] == points[_noofpoints-1][_noofpoints-1][0] &&
                                 points[indexI][m][1] == points[_noofpoints-1][_noofpoints-1][1]);

                if(indexI <= 0) {
                    NSLog(@"bad data point, %d | %f | %f",  indexI, xArrayValues[i], points[0][m][0]);
                } else if (indexI < _noofpoints && (pointEqual || (m == 0 && yArrayValues[i] > points[indexI][m][1]))){
                    printf("good points (%f, %f)\n", xArrayValues[i], yArrayValues[i]);
                    //                    NSLog(@"good data point: m=%d xarr=%f |yarr= %f | tempIndexI=%f  | p[m,0]=%f | p[m,1]=%f| lap[0]=%f| lap[1]=%f",m, xArrayValues[i], yArrayValues[i],tempIndexI, points[indexI][m][0], points[indexI][m][1],points[_noofpoints-1][_noofpoints-1][0],points[_noofpoints-1][_noofpoints-1][0]);
                    points[indexI][m][0] = xArrayValues[i];
                    points[indexI][m][1] = yArrayValues[i];
                } else {
                    //                    NSLog(@"not proper points: %f | %f | %f | %f | %f |m=%d | equal=%d", xArrayValues[i], yArrayValues[i], tempIndexI, points[indexI][m][0], points[indexI][m][1],m,pointEqual);
                }
                break;
            }
        }
    }
    memcpy(point1, points, _noofpoints*_noofpoints*2);
}


- (NSString *) getDecodeResult : (float[_noofpoints][_noofpoints][2]) points : (int) foundStartPoint {
    NSString *retString = @"";

    printf("getDecodeResult/n");
    [self printAllPoints:points start:0 end:6];
    for(int i=0; i<_side+1; i++) {
        for (int j = foundStartPoint; j < foundStartPoint + _side + 1; j++) {
            float expectX = (points[_side+1][j][0] - points[0][j][0]) * i / (_side+1) + points[0][j][0];
            float expectY = (points[_side+1][j][1] - points[0][j][1]) * i / (_side+1) + points[0][j][1];
            if ((points[i][j][0] == points[_noofpoints-1][_noofpoints-1][0]
                 && points[i][j][1] == points[_noofpoints-1][_noofpoints-1][1])
                ||(points[_side+1][j][0] == points[_noofpoints-1][_noofpoints-1][0]
                   && points[_side+1][j][1] == points[_noofpoints-1][_noofpoints-1][1])) {
                    retString = [retString stringByAppendingString: @"*"];
                    continue;
                }

            //from experience
            double threshold = 3.88;
            if (points[i][j][0] < expectX - threshold / 2) {
                if (points[i][j][1] < expectY) {
                    retString = [retString stringByAppendingString: @"0"];
                } else {
                    retString = [retString stringByAppendingString: @"1"];
                }
            } else if (points[i][j][0] > expectX + threshold / 2) {
                if(points[i][j][1] < expectY) {
                    retString = [retString stringByAppendingString: @"2"];
                } else {
                    retString = [retString stringByAppendingString: @"3"];
                }
            } else {
                if (points[i][j][1] == expectY) {
                    retString = [retString stringByAppendingString: @"M"];
                } else if(points[i][j][1] < expectY) {
                    retString = [retString stringByAppendingString: @"a"];
                } else {
                    retString = [retString stringByAppendingString: @"b"];
                }
            }
        }
        retString = [retString stringByAppendingString: @"\n"];
    }
    return retString;
}


- (NSString *) getSequence {
    NSString *ret = @"";
    for(int i=0; i<_side; i++) {
        NSString *append = (i % 2) == 0? @"a" : @"b";
        ret = [ret stringByAppendingString:append];
    }
    return ret;
}


- (NSString *) getRSDecodeResult : (NSString *) retString {
    NSString *findTwoOnePattern = @"";

    for(int i=0; i<_side+1; i++) {
        for(int j=0; j<_side+1; j++) {
            findTwoOnePattern = [findTwoOnePattern stringByAppendingString:[NSString stringWithFormat:@"%c", [retString characterAtIndex:(j*(_side+2)+i)]]];
        }
    }

    if([findTwoOnePattern containsString:@"Mb"] || [findTwoOnePattern containsString:@"bM"]) {

        findTwoOnePattern = [[[[[[[[[findTwoOnePattern stringByReplacingOccurrencesOfString:@"1" withString:@"q"] stringByReplacingOccurrencesOfString:@"a" withString:@"e"]
                                   stringByReplacingOccurrencesOfString:@"0" withString:@"w"]
                                  stringByReplacingOccurrencesOfString:@"2" withString:@"1"]
                                 stringByReplacingOccurrencesOfString:@"b" withString:@"a"]
                                stringByReplacingOccurrencesOfString:@"3" withString:@"0"]
                               stringByReplacingOccurrencesOfString:@"q" withString:@"2"]
                              stringByReplacingOccurrencesOfString:@"e" withString:@"b"]
                             stringByReplacingOccurrencesOfString:@"w" withString:@"3"];
        //reverse string
        findTwoOnePattern = [self reverseString:findTwoOnePattern];
    }

    NSRange range = [findTwoOnePattern rangeOfString:@"Ma"];
    int findMA = (int)range.location;
    if(findMA == NSNotFound || findMA < 0) {
        return @"MA not found";
    }




    NSString *tempSuffix = [findTwoOnePattern substringFromIndex: findMA];
    NSString *tempPrefix = [findTwoOnePattern substringToIndex: findMA];


    //即将前缀移到后面
    findTwoOnePattern = [tempSuffix stringByAppendingString:tempPrefix];

    NSLog(@"Pattern: oringinal %@", findTwoOnePattern);

    NSString *sequence = [self getSequence];


    //guess
    findTwoOnePattern=[[findTwoOnePattern
                        stringByReplacingOccurrencesOfString:sequence withString:@""]
                       stringByReplacingOccurrencesOfString:@"M" withString: @""];

    //    findTwoOnePattern=[[[findTwoOnePattern  stringByReplacingOccurrencesOfString:@"a" withString: @"3"] stringByReplacingOccurrencesOfString:@"b" withString:@"2"] stringByReplacingOccurrencesOfString:@"*" withString:@"1"];
    //
    //
    //    findTwoOnePattern=[[findTwoOnePattern  stringByReplacingOccurrencesOfString:@"a" withString: @"3"] stringByReplacingOccurrencesOfString:@"b" withString:@"2"];

    //    NSLog(@"Pattern: guessed %@", findTwoOnePattern);

    if ([findTwoOnePattern containsString:@"a"] || [findTwoOnePattern containsString:@"b"] || [findTwoOnePattern containsString:@"*"]){
        return @"Error reading codes";
    }
    NSString *tempFindTwoOne = @"";
    for(int i=0; i<_side; i++) {
        for(int j=0; j<_side; j++) {
            tempFindTwoOne = [tempFindTwoOne stringByAppendingString:
                              [NSString stringWithFormat:@"%c",
                               [findTwoOnePattern characterAtIndex:(j * _side + i)]]];
        }
    }

    findTwoOnePattern = tempFindTwoOne;
    int input[_side * _side];
    for(int i=0; i < _side * _side; i++) {
        input[i] = [findTwoOnePattern characterAtIndex:i] - '0';
    }

    int result[_datasize];

    int type = com_example_testdecode_RSDecoder_decodeRS(input, result);
    if(type != 0) {
        return @"-3";
    }

    return [self getRC4Decode:result withKey:KEY];
}

- (NSString *) getRC4Decode : (int[_datasize]) data withKey: (char[KEYLEN]) key{
    int srclen=_datasize;
    char src[srclen];
    int i;
    for (i=0;i<srclen;i++){
        src[i]=(char)data[i];
    }
    int bytes[srclen*MM/8+1];
    int bytelen= transfer_bits_per_pos((unsigned char *)src, srclen,MM, bytes, 8);

    char bytechar[bytelen];

    for (i=0;i<bytelen;i++){
        bytechar[i]=(char)bytes[i];
    }

    unsigned char result[bytelen];

    RC4 rc4;
    rc4_init(&rc4,key,KEYLEN);
    rc4_crypt(&rc4, result, bytechar, bytelen);

    int bits[bytelen*8];
    int bitlen=transfer_bits_per_pos((unsigned char *)result, bytelen,8, bits, 1);
    long long ret=bin2lldec(bits,bitlen);




    return [NSString stringWithFormat:@"result: %lld",ret];

}

long long bin2lldec(int *bin, int len){
    long long result = 0;
    int i;
    for (i = 0;i < len;i++){
        result += ((long long)(bin[i])) << ((long long)i);
    }
    return result;
}


- (NSString *) reverseString : (NSString *) input {
    NSMutableString *result = [[NSMutableString alloc] init];
    int length = (int)[input length];
    for(int i=length-1; i>=0; i--){
        [result appendFormat:@"%c", [input characterAtIndex:i]];
    }

    return result;
}


@end
