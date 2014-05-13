//
//  LTDataShare.h
//  LanTaiPro
//
//  Created by comdosoft on 14-5-6.
//  Copyright (c) 2014年 LanTaiPro. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 单列模式
 */
@interface LTDataShare : NSObject

///数据库地址
@property (nonatomic, strong) NSString *kHost;

+ (LTDataShare *)sharedService;

@end
