//
//  UserModel.h
//  LanTai
//
//  Created by comdosoft on 13-12-16.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 用户
 * 功能－－数据模型
 */
@interface UserModel : NSObject

///用户id
@property (nonatomic, strong) NSString *user_id;
///用户姓名
@property (nonatomic, strong) NSString *userName;
///用户头像
@property (nonatomic, strong) NSString *userImg;

@property (nonatomic, strong) NSString *userPost;
@property (nonatomic, strong) NSString *userPartment;
@property (nonatomic, strong) NSString *name;

///用户对应门店id
@property (nonatomic, strong) NSString *store_id;
///用户对应门店名称
@property (nonatomic, strong) NSString *store_name;
@end
