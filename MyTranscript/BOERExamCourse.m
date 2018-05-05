//
//  BOERExamCourse.m
//  MyTranscript
//
//  Created by ChenQianPing on 16/3/16.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

#import "BOERExamCourse.h"

@implementation BOERExamCourse

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]){
        BOERExamCourse *model = [[BOERExamCourse alloc] init];
        model.courseID = dict[@"EXAMID"];
        model.courseName = dict[@"COURSENAME"];
    }
    return self;
}

+ (instancetype)courseWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}


@end
