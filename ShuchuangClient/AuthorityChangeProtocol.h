//
//  AuthorityChangeProtocol.h
//  ShuchuangClient
//
//  Created by 黄建 on 4/28/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AuthorityChangeProtocol <NSObject>
- (void)authChangedTo:(NSInteger)auth;
@end
