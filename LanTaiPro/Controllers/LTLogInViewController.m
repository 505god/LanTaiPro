//
//  LTLogInViewController.m
//  LanTaiPro
//
//  Created by comdosoft on 14-5-13.
//  Copyright (c) 2014年 LanTaiPro. All rights reserved.
//

#import "LTLogInViewController.h"

@interface LTLogInViewController ()

@end

@implementation LTLogInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - 初始化

-(AppDelegate *)appDel {
    if (!_appDel) {
        _appDel = [AppDelegate shareIntance];
    }
    return _appDel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 数据库设置

@end
