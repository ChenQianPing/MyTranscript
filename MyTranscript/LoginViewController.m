//
//  LoginViewController.m
//  MyTranscript
//
//  Created by ChenQianPing on 16/3/14.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

#import "LoginViewController.h"
#import "AFNetworking.h"
#import "SBJson4.h"
#import "UrlDefine.h"
#import "QpHelper.h"

@interface LoginViewController ()
{
    NSDictionary *activitiesDict;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginBt:(id)sender {
    if (![self.uName.text isEqual:@""] && ![self.uPwd.text isEqual:@""]) {
        [self httpRequest];
    }else{
        [self showAlert:@"账号或者密码不能为空"];
    }

}

- (void)httpRequest{
    NSString *userID = self.uName.text;
    NSString *password = self.uPwd.text;
    
    NSDictionary *dict = @{@"USER_ID":userID,@"PASSWORD":password};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *url = BOER_LOGIN_URI;
    // 设置相应内容类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        
        SBJson4Parser *parser = [SBJson4Parser parserWithBlock:^(id item, BOOL *stop) {
            NSObject *itemObject = item;
            
            if ([item isKindOfClass:[NSDictionary class]]) {
                
                activitiesDict = (NSDictionary*)itemObject;
            }
        }
                                                allowMultiRoot:NO
                                               unwrapRootArray:NO
                                                  errorHandler:^(NSError *error) {
                                                      NSLog(@"%@", error);
                                                  }];
        [parser parse:resData];
        NSLog(@"activitiesDict---%@",activitiesDict);
        
        NSDictionary *userInfo = [activitiesDict objectForKey:@"Result"];
        
        NSString *userName = [userInfo objectForKey:@"USER_NAME"];
        
        if(![QpHelper isBlankString:userName])
        {
            [self setUser];
            [self performSegueWithIdentifier:@"login2main" sender:self];
        }
        else
        {
            [self showAlert:@"账号或者密码错误"];
        }


    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self showAlert:@"网络连接失败！建议到信号好的地方或者WiFi。"];
    }];
}

- (void)showAlert:(NSString*)mes{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示！"
                                                                   message:mes
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setUser
{
    // 通过KEY找到value
    NSDictionary *userInfo = [activitiesDict objectForKey:@"Result"];
    
    NSString *userName = [userInfo objectForKey:@"USER_NAME"];
    NSString *departName = [userInfo objectForKey:@"DEPART_NAME"];
    NSString *userID = [userInfo objectForKey:@"USER_ID"];

    NSUserDefaults *appDefault =[NSUserDefaults standardUserDefaults];
    [appDefault setObject:userName forKey:@"userName"];
    [appDefault setObject:departName forKey:@"departName"];
    [appDefault setObject:userID forKey:@"userID"];
}

@end
