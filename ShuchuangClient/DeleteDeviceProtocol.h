//
//  DeleteDeviceProtocol.h
//  ShuchuangClient
//
//  Created by 黄建 on 4/21/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DeleteDeviceProtocol <NSObject>
- (void)onDeleteDevice:(NSString *)uuid;
@end
