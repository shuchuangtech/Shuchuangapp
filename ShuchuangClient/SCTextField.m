//
//  SCTextField.m
//  ShuchuangClient
//
//  Created by 黄建 on 4/27/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "SCTextField.h"

@implementation SCTextField


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.lineColor == nil) {
        self.lineColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self.lineColor CGColor]);
    CGContextFillRect(context, CGRectMake(0, self.frame.size.height - 0.5, self.frame.size.width, 0.5));
}

/*
- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 10;
    return iconRect;
}
 */

@end
