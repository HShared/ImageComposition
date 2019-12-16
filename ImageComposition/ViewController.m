//
//  ViewController.m
//  ImageComposition
//
//  Created by ATH on 2019/12/16.
//  Copyright © 2019 ath. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+MutliImage.h"
@interface ViewController ()
@property(nonatomic,strong)UIButton *btn;
@property(nonatomic,strong)UIImageView *sourceIV;
@property(nonatomic,strong)UIImageView *generateIV;
@end

@implementation ViewController
-(UIImageView *)sourceIV{
    if(!_sourceIV){
        _sourceIV= [[UIImageView alloc]initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 200)];
        UIImage *image = [UIImage imageNamed:@"image1.jpg"];
        [_sourceIV setImage:image];
        [_sourceIV setContentMode:UIViewContentModeScaleAspectFit];
        [self.view addSubview:_sourceIV];
    }
    return _sourceIV;
}
-(UIImageView *)generateIV{
    if(!_generateIV){
        _generateIV= [[UIImageView alloc]initWithFrame:CGRectMake(0, 350,  CGRectGetWidth(self.view.frame), 200)];
        [_generateIV setContentMode:UIViewContentModeScaleAspectFit];
        [self.view addSubview:_generateIV];
    }
    return _generateIV;
}
-(UIButton*)btn{
    if(!_btn){
        _btn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2-100, 600, 200, 50)];
        [_btn setBackgroundColor:[UIColor redColor]];
        [_btn addTarget:self action:@selector(generate) forControlEvents:UIControlEventTouchUpInside];
        [_btn setTitle:@"生成" forState:UIControlStateNormal];
        [self.view addSubview:_btn];
    }
    
    return _btn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self sourceIV];
    [self generateIV];
    [self btn];
}
-(void)generate{
    CGFloat w = 100;
    UIImage *image = [UIImage imageNamed:@"image1.jpg"];
    //拼接的图不用太大，需要压缩
    UIImage *image1 = [self compressImage:[UIImage imageNamed:@"image1.jpg"] toWidth:w];
    UIImage *image2 = [self compressImage:[UIImage imageNamed:@"image2.jpg"] toWidth:w];
    UIImage *image3 = [self compressImage:[UIImage imageNamed:@"image3.jpg"] toWidth:w];
    NSArray *images = @[image1,image2,image3];
    [self.btn setTitle:@"生成中..." forState:UIControlStateNormal];
    [self.btn setEnabled:NO];
   //该操作有些耗时，需要异步执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         UIImage *multiImage = [UIImage getMultiImage:image multiImageSize:CGSizeMake(image.size.width*8, image.size.height*8) fromImages:images interval:15 unitImageClearValue:0.3];
            if(multiImage){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.generateIV setImage:multiImage];
                });
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
                [UIImagePNGRepresentation(multiImage) writeToFile:filePath atomically:YES];
                NSLog(@"filePath:%@",filePath);
            }else{
                NSLog(@"生成失败 ");
            }
            [self.btn setTitle:@"生成" forState:UIControlStateNormal];
            [self.btn setEnabled:YES];
         
    });
}
-(UIImage *)compressImage:(UIImage *)image toWidth:(CGFloat)width
{
    CGSize imageSize = image.size;
    CGFloat w = imageSize.width;
    CGFloat h = imageSize.height;
    CGFloat height = h / w * width;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image drawInRect:CGRectMake(0,0,width,  height)];
    UIImage* retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}

@end
