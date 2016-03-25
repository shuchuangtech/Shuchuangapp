//
//  UIButton+FillBackgroundImage.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/4/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (FillBackgroundImage)
+ (UIImage*)imageWithColor:(UIColor*)color;
+ (UIColor *)getColorFromHex:(NSInteger) colorHex Alpha:(float)alpha;
@end
