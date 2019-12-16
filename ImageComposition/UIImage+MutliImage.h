//
//  UIImage+MutliImage.h
//  ImageComposition
//
//  Created by ATH on 2019/12/16.
//  Copyright © 2019 ath. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MutliImage)

/// 将多张图images拼接成参照targetImage的图
/// @param targetImage 参照图：要拼接成的图对应的参照图
/// @param size 拼接成的图的尺寸，一般不能小于拼接图的原图
/// @param images 拼接图：由images中的图拼接成目标图
/// @param interval 一张拼接图占用参照图的几个像素点，interval越低拼接成的图越清晰
/// @param value 拼接图的清晰度（0到1），越大拼接图越清晰，目标图越不明显
/// return 目标图
+(UIImage *)getMultiImage:(UIImage *)targetImage multiImageSize:(CGSize)size fromImages:(NSArray*)images interval:(int)interval unitImageClearValue:(CGFloat)value;

+(UIImage *)setImage:(UIImage *)image withR:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue a:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
