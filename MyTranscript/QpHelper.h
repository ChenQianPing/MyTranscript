//
//  QpHelper.h
//  MyTranscript
//
//  Created by ChenQianPing on 16/3/14.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QpHelper : NSObject

// 判断字符串是否为空
+ (BOOL) isBlankString:(NSString *)string;

+ (NSString *)getUserID;
+ (NSString *)getExamID;
+ (NSString *)getExamName;
+ (NSString *)getCourseID;

@end
