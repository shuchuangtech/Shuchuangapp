//
//  DeviceDetailBottomView.m
//  ShuchuangClient
//
//  Created by 黄建 on 5/8/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DeviceDetailBottomView.h"

@implementation DeviceDetailBottomView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)awakeFromNib {
    [self addTarget:self action:@selector(onTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(onTouchDown) forControlEvents:UIControlEventTouchDown];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:50.0 / 255.0 green:63.0 / 255.0 blue:76.0 / 255.0 alpha:0.6] CGColor]);
    if (self.topLine) {
        CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, 0.5));
    }
    if (self.bottomLine) {
        CGContextFillRect(context, CGRectMake(0, self.frame.size.height - 0.5, self.frame.size.width, 0.5));
    }
    if (self.leftLine) {
        CGContextFillRect(context, CGRectMake(0, 0, 0.5, self.frame.size.height));
    }
    if (self.rightLine) {
        CGContextFillRect(context, CGRectMake(self.frame.size.width - 0.5, 0, 0.5, self.frame.size.height));
    }
}

- (void)onTouchUpOutside {
    [self setViewHighlighted:NO];
}

- (void)onTouchDown {
    [self setViewHighlighted:YES];
}

- (void)setTopLine:(BOOL)topLine bottomLine:(BOOL)bottomLine leftLine:(BOOL)leftLine rightLine:(BOOL)rightLine {
    self.topLine = topLine;
    self.bottomLine = bottomLine;
    self.leftLine = leftLine;
    self.rightLine = rightLine;
}

- (void)setViewHighlighted:(BOOL)highlighted {
    if (highlighted) {
        [self setBackgroundColor:[UIColor colorWithRed:220.0 / 255.0 green:220.0 / 255.0 blue:220.0 / 255.0 alpha:1.0]];
    }
    else {
        [self setBackgroundColor:[UIColor colorWithRed:250.0 / 255.0 green:250.0 / 255.0 blue:250.0 / 255.0 alpha:1.0]];
    }
}

@end
