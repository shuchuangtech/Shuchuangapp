//
//  DetailBottomView.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/20/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DetailBottomView.h"
@interface DetailBottomView ()

@property (strong, nonatomic) UILabel *label;
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
    CGContextSetRGBStrokeColor(context, 1.0, 129.0 / 255.0, 0, 1.0);
    CGFloat lineTop = self.frame.size.height / 6;
    CGFloat lineBottom = 5 * self.frame.size.height / 6;
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
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)img labelText:(NSString *)text leftLine:(BOOL)leftLine rightLine:(BOOL)rightLine{
    self = [super initWithFrame:frame];
    CGFloat buttonWidth = frame.size.width / 2;
    CGFloat buttonHeight = buttonWidth;
    CGFloat buttonTop = 3 * frame.size.height / 16;
    CGFloat buttonLeft = frame.size.width / 4;
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(buttonLeft, buttonTop, buttonWidth, buttonHeight)];
    [self.button setImage:img forState:UIControlStateNormal];

    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, buttonTop + buttonHeight, frame.size.width, frame.size.height/ 8)];
    self.label.text = text;
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.label setFont:[UIFont systemFontOfSize:12.0]];
    [self.label setTextColor:[UIColor colorWithRed:1.0 green:129.0 / 255.0 blue:0 alpha:1.0]];
    self.leftLine = leftLine;
    self.rightLine = rightLine;
    [self addSubview:self.button];
    [self addSubview:self.label];
    return self;
}

- (void)drawLineBegin:(CGPoint)begin end:(CGPoint)end {
    
}
@end
