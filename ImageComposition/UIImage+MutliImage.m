//
//  UIImage+MutliImage.m
//  ImageComposition
//
//  Created by ATH on 2019/12/16.
//  Copyright © 2019 ath. All rights reserved.
//

#import "UIImage+MutliImage.h"


@implementation UIImage (MutliImage)


+(UIImage *)getMultiImage:(UIImage *)targetImage multiImageSize:(CGSize)size fromImages:(NSArray*)images interval:(int)interval unitImageClearValue:(CGFloat)value{
    // 得到图片绘制上下文，指定绘制区域
    UIGraphicsBeginImageContext(size);
    unsigned char *imageData = [UIImage convertUIImageToData:targetImage];
    CGFloat w = targetImage.size.width;
    CGFloat h = targetImage.size.height;
    CGFloat targetImageLen =w * h * 4 * sizeof(unsigned char);
    unsigned char *targetImageData = malloc(targetImageLen);
    memset(targetImageData, 0,targetImageLen);
    CGFloat lastX = 0;
    CGFloat lastY = 0;
    CGFloat singleImageW = size.width/(w/interval);
    CGFloat singleImageH = size.height/(h/interval);
    CGFloat alpha = 1-value;
    if(alpha<0||alpha>1){
        alpha = 0.8;
    }
    if(interval<1||interval>targetImage.size.width/2){
        interval = 10;
    }
    for(int i=0;i<h;i=i+interval){
        lastX = 0;
        for(int j=0;j<w;j=j+interval){
           int totalR = 0;
           int totalG = 0;
           int totalB = 0;
            for(int m= i;m<i+interval;m++){
                for(int n= j;n<j+interval;n++){
                    int index = m*w+n;
                    unsigned char tempR = *(imageData + index*4+0);
                    unsigned char tempG = *(imageData + index*4+1);
                    unsigned char tempB = *(imageData + index*4+2);
                    totalR += tempR;
                    totalG += tempG;
                    totalB += tempB;
                }
            }
            unsigned char r = totalR/(interval*interval);
            unsigned char g = totalG/(interval*interval);
            unsigned char b = totalB/(interval*interval);
            NSInteger index = arc4random()%images.count;
            UIImage *colorImage = [UIImage setImage:[images objectAtIndex:index] withR:r g:g b:b a:alpha];
            if(!colorImage){
                NSLog(@"r:%d,g:%d,b:%d",r,g,b);
            }
            [colorImage drawInRect:CGRectMake(lastX,lastY, singleImageW, singleImageH)];
            lastX += singleImageW;
        }
        lastY += singleImageH;
    }
    free(imageData);
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    free(targetImageData);
    UIGraphicsEndImageContext();
    return retImage;
}

+(UIImage *)setImage:(UIImage *)image withR:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue a:(CGFloat)alpha{
    if(image){
        unsigned char *imageData = [UIImage convertUIImageToData:image];
        CGFloat w = image.size.width;
        CGFloat h = image.size.height;
        CGFloat targetImageLen =w * h * 4 * sizeof(unsigned char);
        unsigned char *targetImageData = malloc(targetImageLen);
        memset(targetImageData, 0,targetImageLen);
        for(int i=0;i<h;i++){//高
           for(int j=0;j<w;j++){//宽
               int index = i*w+j;
               unsigned char r = *(imageData + index*4+0);
               unsigned char g = *(imageData + index*4+1);
               unsigned char b = *(imageData + index*4+2);
               r =(unsigned char)(red   * alpha + r*(1-alpha));
               g =(unsigned char)(green * alpha + g*(1-alpha));
               b =(unsigned char)(blue  * alpha + b*(1-alpha));
              
              memset(targetImageData+index*4,r, 1);
              memset(targetImageData+index*4+1,g, 1);
              memset(targetImageData+index*4+2,b, 1);
              memset(targetImageData+index*4+3,255, 1);
           }
        }
        UIImage *retImage = [UIImage convertDataToUIImage:targetImageData imageSize:image.size];
        free(imageData);
        return retImage;
    }
    return nil;
}


/// 将图片UIImage转成unsigned char *数据类型，
/// 即
/// @param image 要转化的image
/// return ret 返回值为unsigned char *数据类型，每四个代表一个像素点（比如ret[0]、ret[1],ret[2],ret[3]代表第一个像素点）顺序为RGBA
+(unsigned char *)convertUIImageToData:(UIImage *)image{
    CGImageRef imageref = [image CGImage];
    CGSize imageSize = image.size;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *data = malloc(imageSize.width*imageSize.height*4);
    memset(data, 0,imageSize.width*imageSize.height*4);
    CGContextRef context = CGBitmapContextCreate(data, imageSize.width, imageSize.height,8,4*imageSize.width, colorSpace,kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width, imageSize.height), imageref);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return (unsigned char *)data;
}


/// 将unsigned char *数据类型转成UIImage类型
/// @param imageData 原数据
/// @param size 转成的图片的宽和高
+(UIImage *)convertDataToUIImage:(unsigned char *)imageData imageSize:(CGSize)size{
    CGFloat width = size.width;
    CGFloat height = size.height;
    NSInteger dataLength = width*height *4;
    CGDataProviderRef provide = CGDataProviderCreateWithData(NULL,
                                                             imageData,
                                                             dataLength,
                                                             NULL);
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageref = CGImageCreate(width,
                                        height,
                                        8,
                                        32,
                                        4*width,colorSpace,
                                        kCGImageAlphaPremultipliedLast
                                        |kCGBitmapByteOrderDefault,
                                        provide,
                                        NULL,
                                        NO,
                                        renderingIntent);
    UIImage *retImage = [UIImage imageWithCGImage:imageref];
    CFRelease(imageref);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provide);
    return retImage;
    
}
@end
