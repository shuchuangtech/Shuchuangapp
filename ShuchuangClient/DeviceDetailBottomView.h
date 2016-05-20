//
//  DeviceDetailBottomView.h
//  ShuchuangClient
//
//  Created by 黄建 on 5/8/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceDetailBottomView : UIControl
@property (nonatomic) BOOL topLine;
@property (nonatomic) BOOL bottomLine;
@property (nonatomic) BOOL leftLine;
@property (nonatomic) BOOL rightLine;
- (void)setTopLine:(BOOL)topLine bottomLine:(BOOL)bottomLine leftLine:(BOOL)leftLine rightLine:(BOOL)rightLine;
- (void)setViewHighlighted:(BOOL)highlighted;
@end
