//
//  DetailBottomView.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/20/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DetailBottomView.h"
@interface DetailBottomView ()

@property (nonatomic) BOOL leftLine;
@property (nonatomic) BOOL rightLine;

@end
@implementation DetailBottomView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetAllowsAntialiasing(context, true);
    UIColor *lineColor = [UIColor darkGrayColor];
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    [lineColor getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBStrokeColor(context, red, blue, green, alpha);
//    CGFloat lineTop = self.frame.size.height / 6;
//    CGFloat lineBottom = 5 * self.frame.size.height / 6;
    CGFloat lineTop = 0;
    CGFloat lineBottom = self.frame.size.height;
    if (self.leftLine) {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, lineTop);
        CGContextAddLineToPoint(context, 0, lineBottom);
        CGContextStrokePath(context);
    }
    if (self.rightLine) {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, self.frame.size.width, lineTop);
        CGContextAddLineToPoint(context, self.frame.size.width, lineBottom);
        CGContextStrokePath(context);
    }
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.frame.size.width, 0);
    CGContextStrokePath(context);
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)img activeImage:(UIImage *)activeImg leftLine:(BOOL)leftLine rightLine:(BOOL)rightLine{
    self = [super initWithFrame:frame];
    CGFloat buttonWidth = frame.size.width / 2;
    CGFloat buttonHeight = 1.36 * buttonWidth;
    CGFloat buttonTop = 0;
    CGFloat buttonLeft = frame.size.width / 4;
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(buttonLeft, buttonTop, buttonWidth, buttonHeight)];
    [self.button setImage:img forState:UIControlStateNormal];
    [self.button setImage:activeImg forState:UIControlStateHighlighted];
    self.leftLine = leftLine;
    self.rightLine = rightLine;
    [self addSubview:self.button];
    return self;
}

- (void)drawLineBegin:(CGPoint)begin end:(CGPoint)end {
    
}
@end
