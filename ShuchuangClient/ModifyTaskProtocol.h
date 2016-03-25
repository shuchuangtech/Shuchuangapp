//
//  ModifyTaskProtocol.h
//  ShuchuangClient
//
//  Created by 黄建 on 3/3/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModifyTaskProtocol <NSObject>
- (void)setTask:(NSInteger)index active:(BOOL)active;
@end
