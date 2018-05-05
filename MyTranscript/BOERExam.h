//
//  BOERExam.h
//  MyTranscript
//
//  Created by ChenQianPing on 16/3/16.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOERExam : NSObject

@property (nonatomic,copy) NSString *examGuid;
@property (nonatomic,copy) NSString *examName;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)examWithDict:(NSDictionary *)dict;

@end
