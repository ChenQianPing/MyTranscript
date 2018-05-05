//
//  QpHelper.m
//  MyTranscript
//
//  Created by ChenQianPing on 16/3/14.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

#import "QpHelper.h"

@implementation QpHelper

// 判断字符串是否为空
+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+ (NSString *)getUserID
{
    NSUserDefaults *appDefault =[NSUserDefaults standardUserDefaults];
    NSString *userid = [appDefault stringForKey:@"userID"];
    return userid;
}

// appDefault
// examListArray examGuild examName
// examCourseArray courseID
// userID userName departName

+ (NSString *)getExamID
{
    NSUserDefaults *appDefault =[NSUserDefaults standardUserDefaults];
    NSString *examGuild = [appDefault stringForKey:@"examGuid"];
    return examGuild;
}

+ (NSString *)getExamName
{
    NSUserDefaults *appDefault =[NSUserDefaults standardUserDefaults];
    NSString *examName = [appDefault stringForKey:@"examName"];
    return examName;
}

+ (NSString *)getCourseID
{
    NSUserDefaults *appDefault =[NSUserDefaults standardUserDefaults];
    NSString *courseID  =[appDefault stringForKey:@"courseID"];
    return courseID;
}

@end
