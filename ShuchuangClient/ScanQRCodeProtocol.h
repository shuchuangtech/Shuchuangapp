//
//  ScanQRCodePtorocol.h
//  ShuchuangClient
//
//  Created by 黄建 on 4/1/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScanQRCodeProtocol <NSObject>
- (void)getQRCodeStringValue:(NSString *)stringValue;
@end
