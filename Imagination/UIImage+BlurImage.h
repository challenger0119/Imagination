//
//  UIImage+BlurImage.h
//  Imagination
//
//  Created by Star on 2017/4/24.
//  Copyright © 2017年 Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BlurImage)
+(UIImage *)blurImageOfView:(UIView *)view withBlurNumber:(CGFloat)blurNumber;
//截屏
+(UIImage *)imageOfView:(UIView *)view;
+(UIImage *)boxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur;
@end
