//
//  BOERExam.m
//  MyTranscript
//
//  Created by ChenQianPing on 16/3/16.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

#import "BOERExam.h"

@implementation BOERExam

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]){
        BOERExam *model = [[BOERExam alloc] init];
        model.examGuid = dict[@"EXAMGUID"];
        model.examName = dict[@"EXAMNAME"];
    }
    return self;
}

+ (instancetype)examWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

@end
