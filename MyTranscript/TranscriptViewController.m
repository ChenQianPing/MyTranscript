//
//  TranscriptViewController.m
//  MyTranscript
//
//  Created by ChenQianPing on 16/3/14.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

#import "TranscriptViewController.h"
#import "TranscriptDetailViewController.h"
#import "AFNetworking.h"
#import "SBJson4.h"
#import "UrlDefine.h"
#import "QpHelper.h"

@interface TranscriptViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *arrList;
    NSDictionary *activitiesDict;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TranscriptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化我的信息
    arrList =
    @[
      [NSMutableDictionary dictionaryWithObjectsAndKeys:@"menu_icons_1_01.png",@"icon",@"总分-个人成绩单",@"intro",@"个人成绩单",@"name",nil],
      [NSMutableDictionary dictionaryWithObjectsAndKeys:@"menu_icons_1_02.png",@"icon",@"个人成绩组成",@"intro",@"成绩组成",@"name",nil],
      [NSMutableDictionary dictionaryWithObjectsAndKeys:@"menu_icons_1_03.png",@"icon",@"个人学业评价",@"intro",@"学业评价",@"name",nil],
      [NSMutableDictionary dictionaryWithObjectsAndKeys:@"menu_icons_1_04.png",@"icon",@"学习水平分布分析",@"intro",@"学习水平分布分析",@"name",nil],
      [NSMutableDictionary dictionaryWithObjectsAndKeys:@"menu_icons_1_05.png",@"icon",@"偏科分析",@"intro",@"偏科分析",@"name",nil],
      [NSMutableDictionary dictionaryWithObjectsAndKeys:@"menu_icons_1_06.png",@"icon",@"综合报告",@"intro",@"综合报告",@"name",nil],
      ];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 46.0f;

    [self requestExamList];
}

#pragma mark - tableview的委托方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // 1.获取模型数据
    NSDictionary *dictData = arrList[indexPath.row];
    
    // 2. 创建单元格
    // 声明一个重用ID
    static NSString *ID = @"menu_cell";
    
    // 根据这个重用ID去"缓存池"中查找对应的Cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 判断,如果没有手到可用的cell,那么重新创建一个
    if (cell == nil){
        // 创建一个新的单元格
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    // 3. 把模型数据设置给单元格
    
    // 设置图标
    cell.imageView.image = [UIImage imageNamed:[dictData objectForKey:@"icon"]];
    // 设置名称
    NSString *name = [dictData objectForKey:@"name"];
    
    cell.textLabel.text = name;
    cell.detailTextLabel.text = [dictData objectForKey:@"intro"];
    
    // 要在单元格的最右边显示一个小箭头,所以要设置单元格对象的某个属性
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // 4.返回单元格
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取出数据模型
    NSDictionary *dictData = arrList[indexPath.row];
//    NSLog(@"%@",dictData);
    NSString *name = [dictData objectForKey:@"name"];
    NSLog(@"%@",name);
    
    TranscriptDetailViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"detailView"];
    view.name = name;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestExamList{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *url = BOER_EXAM_LIST;
    url = [url stringByAppendingString:[QpHelper getUserID]];
    
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
        
        //        NSLog(@"arrayData---%@",arrayData);
        
        NSUserDefaults *appDefault =[NSUserDefaults standardUserDefaults];
        [appDefault setObject:arrayData forKey:@"examListArray"];
        
        NSArray *examListArray  = [appDefault arrayForKey:@"examListArray"];
        NSString * examGuild = [examListArray lastObject][@"EXAMGUID"];
        NSString * examName = [examListArray lastObject][@"EXAMNAME"];

        [appDefault setObject:examGuild forKey:@"examGuid"];
        [appDefault setObject:examName forKey:@"examName"];
        
        //        NSArray *examListArray  = [appDefault arrayForKey:@"examListArray"];
        //        NSString *examGuid = [examListArray lastObject][@"EXAMGUID"];
        //        NSLog(@"examGuid---%@",examGuid);
        
        [self requestExamCourse];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
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
        
        NSLog(@"数据同步完成!");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
