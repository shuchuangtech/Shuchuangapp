//
//  AnimateLabel.h
//  ShuchuangClient
//
//  Created by 黄建 on 5/8/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimateLabel : UILabel
@property (nonatomic) NSInteger animaStep;
@property (copy, nonatomic) NSMutableAttributedString *nextText;
- (void)changeLabelText:(NSMutableAttributedString *)text;
@end
