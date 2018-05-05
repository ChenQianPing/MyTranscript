//
//  TranscriptDetailViewController.m
//  MyTranscript
//
//  Created by ChenQianPing on 16/3/14.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

#import "TranscriptDetailViewController.h"
#import "AFNetworking.h"
#import "SBJson4.h"
#import "UrlDefine.h"
#import "QpHelper.h"
#import "SVProgressHUD.h"
#import "BOERExam.h"
#import "BOERExamCourse.h"

@interface TranscriptDetailViewController()
{
    NSDictionary *activitiesDict;
    NSString *userID;
    NSString *examGuid;
    NSString *examName;
    NSString *courseID;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic,strong)NSArray *exams;      // 考试名称
@property (nonatomic,strong)NSArray *examCourse; // 考试科目

// 弹出视图层
@property (nonatomic, retain) UIView * coverView;          // 黑色半透明遮盖层
@property (nonatomic, retain) UIImageView * popIMgview;    // 弹出列表背景
@property (nonatomic, retain) UITableView * popTableView;  // 弹出列表
@property (nonatomic, retain) UILabel * popLabel;          // 弹出视图标题
@property (nonatomic, retain) NSMutableArray * tabArray;   // 列表数组
@property (nonatomic, retain) NSString * popType;          // 弹出视图标识

@end

@implementation TranscriptDetailViewController
@synthesize name;

// 弹出视图层
@synthesize coverView,popIMgview,popTableView,popLabel;
@synthesize tabArray,popType;

#pragma mark - 懒加载数据
- (NSArray *)exams{
    if (_exams == nil) {
        // 加载数组
        NSUserDefaults *appDefault = [NSUserDefaults standardUserDefaults];
        // 读取NSUserDefaults中的数据
        NSArray *arraryDict = [appDefault arrayForKey:@"examListArray"];
        // 将arraryDict里面的所有字典转成模型对象,放到新的数组中
        NSMutableArray *arrayModels = [NSMutableArray array];
        
        for (NSDictionary *dict in arraryDict) {
            // 创建模型对象
            BOERExam *model = [[BOERExam alloc] init];
            model.examGuid = dict[@"EXAMGUID"];
            model.examName = dict[@"EXAMNAME"];
            // 添加模型对象到数组中
            [arrayModels addObject:model];
        }
        // 赋值
        _exams = arrayModels;
    }
    return _exams;
}

- (NSArray *)examCourse{
    if (_examCourse == nil) {
        // 加载数组
        NSUserDefaults *appDefault = [NSUserDefaults standardUserDefaults];
        // 读取NSUserDefaults中的数据
        NSArray *arraryDict = [appDefault arrayForKey:@"examCourseArray"];
        // 将arraryDict里面的所有字典转成模型对象,放到新的数组中
        NSMutableArray *arrayModels = [NSMutableArray array];
        for (NSDictionary *dict in arraryDict) {
            // 创建模型对象
            BOERExamCourse *model = [[BOERExamCourse alloc] init];  //必须写在for循环里面
            model.courseID = dict[@"EXAMID"];
            model.courseName = dict[@"COURSENAME"];
            // 添加模型对象到数组中
            [arrayModels addObject:model];
        }
        // 赋值
        _examCourse = arrayModels;
        
    }
    return _examCourse;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.name;
    
    NSUserDefaults *appDefault =[NSUserDefaults standardUserDefaults];
    courseID  =[appDefault stringForKey:@"courseID"];
    
    if (courseID==nil) {
        [self showAlert:@"无法取得考试科目数据!"];
        return;
    }
    else
    {
        userID = [QpHelper getUserID];
        examGuid = [QpHelper getExamID];
        examName = [QpHelper getExamName];
        courseID = [QpHelper getCourseID];
    }

    // 添加弹出视图层
    [self creatPopView];

    [self initRightButton];

    [self loadingData];

}

#pragma mark - 弹出视图层
- (void)initRightButton
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 35, 35);
    [rightButton setImage:[UIImage imageNamed:@"nav_right_button_normal"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"nav_right_button_press"] forState:UIControlStateHighlighted];
    // 设置返回按钮的图片,跟系统自带的“<”符合保持一致
    [rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    // 图片居右
    [rightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

// 添加弹出视图层
- (void)creatPopView
{
    // 列表所需数组
    tabArray = [[NSMutableArray alloc]initWithCapacity:0];
    // 背景层
    coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    coverView.hidden = YES;
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0.3;
    [self.view addSubview:coverView];
    // 显示视图
    popIMgview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 304, 288)];
    popIMgview.hidden = YES;
    popIMgview.center = self.view.center;
    popIMgview.userInteractionEnabled = YES;
    popIMgview.image = [UIImage imageNamed:@"appear_03.png"];
    [self.view addSubview:popIMgview];
    // 添加列表
    popTableView = [[UITableView alloc] initWithFrame:CGRectMake(2, 41, 298, 198) style:UITableViewStylePlain];
    popTableView.delegate = self;
    popTableView.dataSource = self;
    [popIMgview addSubview:popTableView];
    // 标题栏
    popLabel = [[UILabel alloc]initWithFrame:CGRectMake(7, 5, 240, 30)];
    popLabel.backgroundColor = [UIColor clearColor];
    [popIMgview addSubview:popLabel];
    // 按钮
    // 控制按钮
    UIButton * quxiaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quxiaoBtn.frame = CGRectMake(5, 240, 143, 43);
    [quxiaoBtn setImage:[UIImage imageNamed:@"appear_05.png"] forState:UIControlStateNormal];
    [quxiaoBtn setImage:[UIImage imageNamed:@"appear_65.png"] forState:UIControlStateHighlighted];
    [quxiaoBtn addTarget:self action:@selector(fsalAction:) forControlEvents:UIControlEventTouchUpInside];
    [popIMgview addSubview:quxiaoBtn];
    
    UIButton * quedingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quedingBtn.frame = CGRectMake(152, 240, 143, 43);
    [quedingBtn setImage:[UIImage imageNamed:@"appear_08.png"] forState:UIControlStateNormal];
    [quedingBtn setImage:[UIImage imageNamed:@"appear_80.png"] forState:UIControlStateHighlighted];
    [quedingBtn addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
    [popIMgview addSubview:quedingBtn];
}

- (void)rightButtonAction:(UIBarButtonItem*)rightAction{
    if ([self.name isEqual:@"综合报告"])
    {
        popType = @"考试科目选择";
        popLabel.text = @"考试科目";
    }
    else
    {
        popType = @"考试名称选择";
        popLabel.text = @"考试名称";
    }
    
    [popTableView reloadData];
    
    popIMgview.hidden = NO;
    coverView.hidden = NO;
}

// 取消和确定按钮
- (void)fsalAction:(UIButton *)btn
{
    popIMgview.hidden = YES;
    coverView.hidden = YES;
}

- (void)sureAction:(UIButton *)btn
{
    popIMgview.hidden = YES;
    coverView.hidden = YES;
    
    if ([self.name isEqual:@"综合报告"])
    {
        NSUserDefaults *appDefault =[NSUserDefaults standardUserDefaults];
        [appDefault setObject:courseID forKey:@"courseID"];
    }
    else
    {
        NSUserDefaults *appDefault =[NSUserDefaults standardUserDefaults];
        [appDefault setObject:examGuid forKey:@"examGuid"];
        [appDefault setObject:examName forKey:@"examName"];
    }
    
    [self requestExamCourse];
    
    [self loadingData];
}

#pragma mark - UITableView代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.name isEqual:@"综合报告"])
    {
        return self.examCourse.count;
    } else
    {
        return self.exams.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellWithIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellWithIdentifier];
    }
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    
    if ([self.name isEqual:@"综合报告"])
    {
        BOERExamCourse *model = self.examCourse[indexPath.row];
        cell.textLabel.text = model.courseName;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
    } else
    {
        BOERExam *model = self.exams[indexPath.row];
        cell.textLabel.text = model.examName;
        cell.textLabel.font = [UIFont systemFontOfSize:10];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.name isEqual:@"综合报告"])
    {
        BOERExamCourse *examCourse = self.examCourse[indexPath.row];
        courseID = examCourse.courseID;

    } else
    {
        BOERExam *exam = self.exams[indexPath.row];
        examName = exam.examName;
        examGuid = exam.examGuid;
    }
}

#pragma mark - 解析数据
- (void)loadingData{
    if ([self.name  isEqual: @"个人成绩单"])
    {
        [self getHttp:BOER_CHENGJI_DAN];
    }
    else if ([self.name isEqual:@"成绩组成"])
    {
        [self getHttp:BOER_CHENJI_ZHUCHENG];
    }
    else if ([self.name isEqual:@"学业评价"])
    {
        [self getHttp:BOER_LEVE_ANALYSIS];
    }
    else if ([self.name isEqual:@"学习水平分布分析"])
    {
        [self getHttp:BOER_DABIAO_FENBU];
    }
    else if ([self.name isEqual:@"偏科分析"])
    {
        [self getHttp:BOER_PKD];
    }
    else if ([self.name isEqual:@"综合报告"])
    {
        [self getHttp:BOER_REPROT];
    }
    
}

- (void)getHttp:(NSString *)uri{
    [SVProgressHUD showWithStatus:@"正在加载数据..."];
    
    NSDictionary *dict = @{@"examGuid":examGuid,@"examName":examName,@"courseId":courseID};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *url = uri;
    url = [url stringByAppendingString:userID];
    url = [url stringByAppendingFormat:@"%s", "/"];

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
        
        [self generateHTML];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:@"网络繁忙"];
    }];
}

- (void)requestExamCourse{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *url = BOER_EXAM_COURSE;
    
    //    NSLog(@"getExamID---%@",[QpHelper getExamID]);
    
    url = [url stringByAppendingString:[QpHelper getExamID]];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"Success: %@", responseObject);
        
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
        //        NSLog(@"activitiesDict---%@",activitiesDict);
        
        NSArray *arrayData = [activitiesDict objectForKey:@"Result"];
        NSString *courseID = [arrayData firstObject][@"EXAMID"];
        
        NSUserDefaults *appDefault =[NSUserDefaults standardUserDefaults];
        [appDefault setObject:courseID forKey:@"courseID"];
        [appDefault setObject:arrayData forKey:@"examCourseArray"];
        
        NSLog(@"Get examCourseArray");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)generateHTML
{
    NSArray *arrayData = [activitiesDict objectForKey:@"Result"];
    
    NSString * html_table_tr_td = @"";
    
    if ([self.name  isEqual: @"个人成绩单"])
    {
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<h2>%@</h2> \n", examName];
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<table class='bordered'>\n"];
        for (NSDictionary *dict in arrayData) {
            NSString * C1 = dict[@"C1"];
            NSString * C2 = dict[@"C2"];
            NSString * C3 = dict[@"C3"];
            NSString * C4 = dict[@"C4"];
            NSString * C5 = dict[@"C5"];
            NSString * C6 = dict[@"C6"];
            NSString * C7 = dict[@"C7"];
            NSString * C8 = dict[@"C8"];
            NSString * C9 = dict[@"C9"];
            
            NSString * C0 = dict[@"C0"];
            if(![QpHelper isBlankString:C1])
            {
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<tr>\n"];
                if(![QpHelper isBlankString:C0]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C0];
                }
                if(![QpHelper isBlankString:C1]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C1];
                }
                if(![QpHelper isBlankString:C2]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C2];
                }
                if(![QpHelper isBlankString:C3]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C3];
                }
                if(![QpHelper isBlankString:C4]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C4];
                }
                if(![QpHelper isBlankString:C5]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C5];
                }
                if(![QpHelper isBlankString:C6]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C6];
                }
                if(![QpHelper isBlankString:C7]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C7];
                }
                if(![QpHelper isBlankString:C8]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C8];
                }
                if(![QpHelper isBlankString:C9]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C9];
                }
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</tr>\n"];
            }
            
        }
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</table>\n"];
    }
    else if ([self.name isEqual:@"成绩组成"])
    {
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<h2>%@</h2> \n", examName];
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<table class='bordered'>\n"];
        
        for (NSDictionary *dict in arrayData) {
            NSString *C0 = dict[@"CourseName"];
            NSString *C1 = dict[@"Score"];
            NSString *C2 = dict[@"Scale"];
            
            if(![QpHelper isBlankString:C1]){
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<tr>\n"];
                if(![QpHelper isBlankString:C0]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C0];
                }
                if(![QpHelper isBlankString:C1]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C1];
                }
                if(![QpHelper isBlankString:C2]){
                    html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C2];
                }
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</tr>\n"];
            }
        }
        
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</table>\n"];

    }
    else if ([self.name isEqual:@"学业评价"])
    {
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<h2>%@</h2> \n", examName];
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<table class='bordered'>\n"];
        
        for (NSDictionary *dict in arrayData) {
            NSString * C1 = dict[@"C1"];
            NSString * C2 = dict[@"C2"];
            NSString * C3 = dict[@"C3"];
            NSString * C4 = dict[@"C4"];
            NSString * C5 = dict[@"C5"];
            NSString * C6 = dict[@"C6"];
            NSString * C7 = dict[@"C7"];
            NSString * C8 = dict[@"C8"];
            
            NSString * C0 = dict[@"C0"];
            if(![QpHelper isBlankString:C1])
            {
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<tr>\n"];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C0];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C1];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C2];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C3];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C4];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C5];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C6];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C7];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C8];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</tr>\n"];
            }
        }
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</table>\n"];
    }
    else if ([self.name isEqual:@"学习水平分布分析"])
    {
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<h2>%@</h2> \n", examName];
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<table class='bordered'>\n"];
        for (NSDictionary *dict in arrayData) {
            NSString * C0 = dict[@"ProjectName"];
            NSString * C1 = dict[@"Score"];
            
            if(![QpHelper isBlankString:C1])
            {
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<tr>\n"];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C0];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C1];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</tr>\n"];
            }
        }
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</table>\n"];
    }
    else if ([self.name isEqual:@"偏科分析"])
    {
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<h2>%@</h2> \n", examName];
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<table class='bordered'>\n"];
        for (NSDictionary *dict in arrayData) {
            NSString * C0 = dict[@"C0"];
            NSString * C1 = dict[@"C1"];
            NSString * C2 = dict[@"C2"];
            NSString * C3 = dict[@"C3"];
            NSString * C4 = dict[@"C4"];
            NSString * C5 = dict[@"C5"];
            NSString * C6 = dict[@"C6"];
            NSString * C7 = dict[@"C7"];
            NSString * C8 = dict[@"C8"];
            if(![QpHelper isBlankString:C1])
            {
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<tr>\n"];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C0];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C1];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C2];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C3];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C4];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C5];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C6];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C7];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C8];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</tr>\n"];
            }
        }
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</table>\n"];
    }
    else if ([self.name isEqual:@"综合报告"])
    {
        // 解析数据
        NSDictionary *dict = [activitiesDict objectForKey:@"Result"];;

        // 1.基础成绩
        NSDictionary *data1dict =[dict valueForKey:@"Data1"];
        html_table_tr_td = @"<h2>1.基础成绩</h2> \n"
        "<table class='bordered'>\n";
        for (NSDictionary *data1_dict in data1dict)
        {
            NSString * C0 = data1_dict[@"C0"];
            NSString * C1 = data1_dict[@"C1"];
            NSString * C2 = data1_dict[@"C2"];
            NSString * C3 = data1_dict[@"C3"];
            NSString * C4 = data1_dict[@"C4"];
            NSString * C5 = data1_dict[@"C5"];
            NSString * C6 = data1_dict[@"C6"];
            
            if(![QpHelper isBlankString:C1])
            {
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<tr>\n"];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C0];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C1];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C2];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C3];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C4];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C5];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C6];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</tr>\n"];
            }
        }
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</table>\n"];
        
        // 2.各小题分析
        NSDictionary *data2dict =[dict valueForKey:@"Data2"];
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%@", @"<h2>2.各小题分析</h2> \n"];
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<table class='bordered'>\n"];
        
        for (NSDictionary *data2_dict in data2dict)
        {
            NSString * C0 = data2_dict[@"C0"];
            NSString * C1 = data2_dict[@"C1"];
            NSString * C2 = data2_dict[@"C2"];
            NSString * C3 = data2_dict[@"C3"];
            NSString * C4 = data2_dict[@"C4"];
            NSString * C5 = data2_dict[@"C5"];
            if(![QpHelper isBlankString:C1])
            {
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<tr>\n"];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C0];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C1];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C2];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C3];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C4];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C5];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</tr>\n"];
            }
        }
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</table>\n"];
        
        // 3.知识点明细
        NSDictionary *data3dict =[dict valueForKey:@"Data3"];
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%@", @"<h2>3.知识点明细</h2> \n"];
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<table class='bordered'>\n"];
        
        for (NSDictionary *data3_dict in data3dict)
        {
            NSString * C0 = data3_dict[@"C0"];
            NSString * C1 = data3_dict[@"C1"];
            NSString * C2 = data3_dict[@"C2"];
            NSString * C3 = data3_dict[@"C3"];
            NSString * C4 = data3_dict[@"C4"];
            NSString * C5 = data3_dict[@"C5"];
            NSString * C6 = data3_dict[@"C6"];
            if(![QpHelper isBlankString:C1])
            {
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<tr>\n"];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C0];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C1];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C2];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C3];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C4];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C5];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C6];
                html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</tr>\n"];
            }
        }
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</table>\n"];
        
        
        // 4.任课教师评价
        NSDictionary *data4dict =[dict valueForKey:@"Data4"];
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%@", @"<h2>4.任课教师评价</h2> \n"];
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<table class='bordered'>\n"];
        
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "<tr>\n"];
        
        for (NSDictionary *data4_dict in data4dict)
        {
            NSString * C0 = data4_dict[@"C0"];
            html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", @"教师评价"];
            html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"<td>%@</td>\n", C0];
        }
        
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</tr>\n"];
        
        html_table_tr_td = [html_table_tr_td stringByAppendingFormat:@"%s", "</table>\n"];

    }

    NSString * html_str_header = @"<!DOCTYPE html> \n"
    "<html> \n"
    "<head> \n"
    "<title>Practical CSS3 tables with rounded corners - demo</title>\n"
    
    "<style> \n"
    "body { \n"
    "width: 100%; \n"
    "text-align:center; \n"
    "margin: 40px auto; \n"
    "  font-family: 'trebuchet MS', 'Lucida sans', Arial; \n"
    " font-size: 12px; \n"
    "color: #444; \n"
    "} \n"
    
    "table { \n"
    "    *border-collapse: collapse; /* IE7 and lower */ \n"
    "    border-spacing: 0; \n"
    "    margin:0px auto; \n"
    "width: 90%; \n"
    "} \n"
    
    ".bordered { \n"
    "border: solid #ccc 1px; \n"
    "    -moz-border-radius: 6px; \n"
    "    -webkit-border-radius: 6px; \n"
    "    border-radius: 6px; \n"
    "    -webkit-box-shadow: 0 1px 1px #ccc; \n"
    "    -moz-box-shadow: 0 1px 1px #ccc; \n"
    "    box-shadow: 0 1px 1px #ccc; \n"
    "} \n"
    
    ".bordered tr:hover { \n"
    "background: #fbf8e9; \n"
    "    -o-transition: all 0.1s ease-in-out; \n"
    "    -webkit-transition: all 0.1s ease-in-out; \n"
    "    -moz-transition: all 0.1s ease-in-out; \n"
    "    -ms-transition: all 0.1s ease-in-out; \n"
    "transition: all 0.1s ease-in-out; \n"
    "} \n"
    
    ".bordered td, .bordered th { \n"
    "    border-left: 1px solid #ccc; \n"
    "    border-top: 1px solid #ccc; \n"
    "padding: 10px; \n"
    "    text-align: left; \n"
    "} \n"
    
    ".bordered th { \n"
    "    background-color: #dce9f9; \n"
    "    background-image: -webkit-gradient(linear, left top, left bottom, from(#ebf3fc), to(#dce9f9)); \n"
    "    background-image: -webkit-linear-gradient(top, #ebf3fc, #dce9f9); \n"
    "    background-image:    -moz-linear-gradient(top, #ebf3fc, #dce9f9); \n"
    "    background-image:     -ms-linear-gradient(top, #ebf3fc, #dce9f9); \n"
    "    background-image:      -o-linear-gradient(top, #ebf3fc, #dce9f9); \n"
    "    background-image:         linear-gradient(top, #ebf3fc, #dce9f9); \n"
    "    -webkit-box-shadow: 0 1px 0 rgba(255,255,255,.8) inset; \n"
    "    -moz-box-shadow:0 1px 0 rgba(255,255,255,.8) inset; \n"
    "    box-shadow: 0 1px 0 rgba(255,255,255,.8) inset; \n"
    "    border-top: none; \n"
    "    text-shadow: 0 1px 0 rgba(255,255,255,.5); \n"
    " } \n"
    
    ".bordered td:first-child, .bordered th:first-child { \n"
    "    border-left: none; \n"
    "} \n"
    
    ".bordered th:first-child { \n"
    "    -moz-border-radius: 6px 0 0 0; \n"
    "    -webkit-border-radius: 6px 0 0 0; \n"
    "    border-radius: 6px 0 0 0; \n"
    "} \n"
    
    ".bordered th:last-child { \n"
    "    -moz-border-radius: 0 6px 0 0; \n"
    "    -webkit-border-radius: 0 6px 0 0; \n"
    "    border-radius: 0 6px 0 0; \n"
    "} \n"
    
    ".bordered th:only-child{ \n"
    "    -moz-border-radius: 6px 6px 0 0; \n"
    "    -webkit-border-radius: 6px 6px 0 0; \n"
    "    border-radius: 6px 6px 0 0; \n"
    "} \n"
    
    ".bordered tr:last-child td:first-child { \n"
    "    -moz-border-radius: 0 0 0 6px; \n"
    "    -webkit-border-radius: 0 0 0 6px; \n"
    "    border-radius: 0 0 0 6px; \n"
    "} \n"
    
    ".bordered tr:last-child td:last-child { \n"
    "    -moz-border-radius: 0 0 6px 0; \n"
    "    -webkit-border-radius: 0 0 6px 0; \n"
    "    border-radius: 0 0 6px 0; \n"
    "} \n"
    
    "</style> \n"
    "</head> \n"
    "<body> \n";
    
    NSString * html_str_footer =
    @"</body>\n"
    "</html>\n";
    
    NSString *html_str = @"";
    
    html_str = [html_str stringByAppendingFormat:@"%@%@%@", html_str_header, html_table_tr_td,html_str_footer];
    
//    NSLog(@"html_str---%@",html_str);
    // 自动对页面进行缩放以适应屏幕
    self.webView.scalesPageToFit = NO;
    
    [SVProgressHUD dismiss];
    
    [self.webView loadHTMLString:html_str baseURL:nil];
}

@end
