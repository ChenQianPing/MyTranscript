//
//  MyViewController.m
//  MyTranscript
//
//  Created by ChenQianPing on 16/3/14.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

#import "MyViewController.h"
#import "LoginViewController.h"

@interface MyViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *arrList;
    NSDictionary *activitiesDict;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSUserDefaults *appDefault =[NSUserDefaults standardUserDefaults];
    // 读取NSUserDefaults中的数据
    NSString *username = [appDefault stringForKey:@"userName"];
    NSString *userid = [appDefault stringForKey:@"userID"];
    NSString *departName = [appDefault stringForKey:@"departName"];
    
    username = [NSString stringWithFormat:@"%@  %@",username,departName];
    userid = [NSString stringWithFormat:@"我的帐号  %@",userid];
    
    // 初始化我的信息
    arrList =
    @[
      @[
          [NSMutableDictionary dictionaryWithObjectsAndKeys:username,@"title",@"menu_icons_male",@"image",@"1",@"isshow",nil],
          [NSMutableDictionary dictionaryWithObjectsAndKeys:userid,@"title",@"menu_icons_account",@"image",@"1",@"isshow",nil]
          ],@[
          [NSMutableDictionary dictionaryWithObjectsAndKeys:@"退出登录",@"title",@"menu_icons_logout",@"image",@"1",@"isshow",nil],
          ]
      ];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 46.0f;
}

#pragma mark - tableview的委托方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return arrList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arrSection = arrList[section];
    return arrSection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // 1.获取模型数据
    NSArray *arrSection = arrList[indexPath.section];
    NSDictionary *dictData = arrSection[indexPath.row];
    
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
    cell.imageView.image = [UIImage imageNamed:[dictData objectForKey:@"image"]];;
    // 设置名称
    cell.textLabel.text = [dictData objectForKey:@"title"];
    
    // 要在单元格的最右边显示一个小箭头,所以要设置单元格对象的某个属性
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([cell.textLabel.text isEqual:@"退出登录"] ) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.section==0)
    {
        if (indexPath.row==0) {
            // 我的姓名
        }else if (indexPath.row==1)
        {
            // 我的帐号
        }
        
    }else if(indexPath.section==1)
    {
        if (indexPath.row==0) {
            // 退出登录
            LoginViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
            [self presentViewController:view animated:YES completion:nil];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
