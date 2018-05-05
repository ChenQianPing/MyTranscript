//
//  BOERExamCourse.h
//  MyTranscript
//
//  Created by ChenQianPing on 16/3/16.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOERExamCourse : NSObject

@property (nonatomic,copy) NSString *courseID;
@property (nonatomic,copy) NSString *courseName;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)courseWithDict:(NSDictionary *)dict;

@end
