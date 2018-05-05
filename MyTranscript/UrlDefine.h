//
//  UrlDefine.h
//  MyTranscript
//
//  Created by ChenQianPing on 16/3/14.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

// 0-1.登录
// eg:api/user/login?PASSWORD=123&USER_ID=1610117
#define BOER_LOGIN_URI @"http://120.76.100.138:8092/api/user/login"

// 0-2.获取考试列表
// eg:api/exam/1610117 学生学号
#define BOER_EXAM_LIST @"http://120.76.100.138:8092/api/exam/"

// 0-3.获取考试的科目
// eg:api/exam/course/A9093AE714AC47758A367B8813B99D1D
#define BOER_EXAM_COURSE @"http://120.76.100.138:8092/api/exam/course/"

// 1-1.获取成绩单
// eg:api/exam/chengjidan/1610118/?examGuid=A9093AE714AC47758A367B8813B99D1D&examName=[2016年01月06日] 高三2016高三第8次模拟考试(理科)
#define BOER_CHENGJI_DAN @"http://120.76.100.138:8092/api/exam/chengjidan/"

// 1-2.获取成绩组成
// eg:api/exam/chengjizucheng/1610118/?examGuid=A9093AE714AC47758A367B8813B99D1D&examName=[2016年01月06日] 高三2016高三第8次模拟考试(理科)
#define BOER_CHENJI_ZHUCHENG @"http://120.76.100.138:8092/api/exam/chengjizucheng/"

// 1-3.获取个人学业评价
// eg:api/exam/leveanalysis/1610118/?examGuid=A9093AE714AC47758A367B8813B99D1D
#define BOER_LEVE_ANALYSIS @"http://120.76.100.138:8092/api/exam/leveanalysis/"

// 1-4.学生水平分布分析
// eg:api/exam/dabiaofenbu/1610118/?examGuid=A9093AE714AC47758A367B8813B99D1D
#define BOER_DABIAO_FENBU @"http://120.76.100.138:8092/api/exam/dabiaofenbu/"

// 1-5.偏科分析
// eg:api/exam/pkd/1610118/?examGuid=A9093AE714AC47758A367B8813B99D1D
#define BOER_PKD @"http://120.76.100.138:8092/api/exam/pkd/"

// 1-6.获取某个科目的考试综合报表
// eg:api/exam/report/1610118/?examGuid=A9093AE714AC47758A367B8813B99D1D&courseId=10010001
#define BOER_REPROT @"http://120.76.100.138:8092/api/exam/report/"



