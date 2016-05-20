//
//  EditTaskProtocol.h
//  ShuchuangClient
//
//  Created by 黄建 on 5/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EditTaskProtocol <NSObject>
- (void)optionChangedTo:(NSInteger)option;
- (void)repeatChangedTo:(NSInteger)repeat;
@end
