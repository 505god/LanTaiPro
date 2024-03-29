//
//  LTInterfaceBase.h
//  LanTaiPro
//
//  Created by comdosoft on 14-5-6.
//  Copyright (c) 2014年 LanTaiPro. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 请求
 * 结合ARC，Blocks和GCD 来实现了一个网络请求的封装
 */

/*
 * typedef Block 类型变量
 * 提高源代码的可读性
 */

typedef void(^CompleteBlock_t)(NSDictionary *dictionary);
typedef void(^ErrorBlock_t)(NSError *error);

@interface LTInterfaceBase : NSURLConnection<NSURLConnectionDataDelegate>
{
    NSMutableData *data_;
    CompleteBlock_t completeBlock_;
    ErrorBlock_t errorBlock_;
}

+ (id)request:(NSMutableDictionary *)params requestUrl:(NSString *)requestUrl completeBlock:(CompleteBlock_t)compleBlock errorBlock:(ErrorBlock_t)errorBlock;

- (id)initWithRequest:(NSMutableDictionary *)params requestUrl:(NSString *)requestUrl completeBlock:(CompleteBlock_t)compleBlock errorBlock:(ErrorBlock_t)errorBlock;

@end
