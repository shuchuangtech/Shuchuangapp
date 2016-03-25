//
//  UIButton+FillBackgroundImage.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/4/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "UIButton+FillBackgroundImage.h"

@implementation UIButton (FillBackgroundImage)
+ (UIImage*)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIColor *)getColorFromHex:(NSInteger)colorHex Alpha:(float)alpha{
    return [UIColor colorWithRed:((colorHex >> 16) & 0xFF) / 255.0 \
                    green:((colorHex >>  8) & 0xFF) / 255.0 \
                     blue:((colorHex >>  0) & 0xFF) / 255.0 \
                    alpha:alpha];
}
@end
