//
//  IPSelectorViewController.m
//  IP
//
//  Created by IOS_HMX on 15/11/13.
//  Copyright (c) 2015年 humingxing. All rights reserved.
//

#import "IPSelectorViewController.h"
#import "IPSelector.h"
static const CGFloat kBarHeight = 64;


@interface IPSelectorViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property(nonatomic,strong)UITableView *tabelView;
@property(nonatomic,strong)NSMutableArray *ipList;
@property(nonatomic,strong)NSArray *ipNames;
@property(nonatomic,strong)NSArray *ipKes;
@property(nonatomic,strong)NSMutableDictionary *selectIpDictionary;
@property(nonatomic,strong)NSMutableDictionary *selectIndexPath;

@end

@implementation IPSelectorViewController
-(instancetype)initWithIpList:(NSMutableArray *)ipList ipKeys:(NSArray *)ipKeys ipNames:(NSArray *)ipNames
{
    if (self = [super init]) {
        self.ipKes = ipKeys;
        self.ipList = ipList;
        self.ipNames = ipNames;
        self.selectIpDictionary = [[NSMutableDictionary alloc]init];
        self.selectIndexPath = [[NSMutableDictionary alloc]init];
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //初始化导航标题及保存按钮
    UILabel *labelBar = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kBarHeight)];
    labelBar.backgroundColor = [UIColor whiteColor];
    labelBar.textAlignment = NSTextAlignmentCenter;
    labelBar.font = [UIFont boldSystemFontOfSize:18];
    labelBar.text = @"IP 选择列表";
    [self.view addSubview:labelBar];
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(CGRectGetWidth(self.view.frame)-60, 0, 60, kBarHeight);
    [saveButton setTitle:@"确认" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:saveButton];
    [saveButton addTarget:self action:@selector(saveIPSelector) forControlEvents:UIControlEventTouchUpInside];
    
    //初始化tableview
    _tabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, kBarHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-kBarHeight) style:UITableViewStylePlain];
    _tabelView.delegate = self;
    _tabelView.dataSource = self;
    [self.view addSubview:_tabelView];
}

-(void)saveIPSelector
{
    UIAlertView *alertView;
    //判断是否全部选择
    if (self.selectIpDictionary.count<self.ipKes.count) {
        alertView = [[UIAlertView alloc]initWithTitle:@"每一个服务器必须都选择一个IP" message:@"" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(ipSelectorViewControllerdidSelectedIp:)]) {
        [self.delegate  ipSelectorViewControllerdidSelectedIp:self.selectIpDictionary];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //生产＋测试
    NSDictionary *ip = [self.ipList objectAtIndex:section];
    __block NSInteger ipCount = 0;
    [ip.allValues enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL *stop) {
        ipCount += obj.count;
    }];
    return ipCount;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.ipList.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.ipNames[section];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row >[self.ipList[indexPath.section][IPSelectorEnvironmentProductKey] count]-1) {
        NSInteger index = indexPath.row - [self.ipList[indexPath.section][IPSelectorEnvironmentProductKey] count];
        if(index == 0)
        {
            cell.textLabel.text = @"测试";
        }else
        {
            cell.textLabel.text = @"";
        }
        NSString *ip = self.ipList[indexPath.section][IPSelectorEnvironmentTestKey][index];
        cell.detailTextLabel.text = ip;
        NSString *selectedIp = self.selectIpDictionary[self.ipKes[indexPath.section]][0];
        if ([selectedIp isEqualToString:ip]&&NSOrderedSame==[indexPath compare:self.selectIndexPath[self.ipKes[indexPath.section]]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else
    {
        NSInteger index = index = indexPath.row;
        if(index == 0)
        {
            cell.textLabel.text = @"生产";
        }else
        {
            cell.textLabel.text = @"";
        }
        NSString *ip = self.ipList[indexPath.section][IPSelectorEnvironmentProductKey][index];
        cell.detailTextLabel.text = ip;
        NSString *selectedIp = self.selectIpDictionary[self.ipKes[indexPath.section]][0];
        if ([selectedIp isEqualToString:ip]&&NSOrderedSame==[indexPath compare:self.selectIndexPath[self.ipKes[indexPath.section]]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *selectedIpArray;
    NSInteger index;
    NSString *ip;
    if (indexPath.row >[self.ipList[indexPath.section][IPSelectorEnvironmentProductKey] count]-1) {
        index = indexPath.row - [self.ipList[indexPath.section][IPSelectorEnvironmentProductKey] count];
        selectedIpArray = [[NSMutableArray alloc]initWithArray:self.ipList[indexPath.section][IPSelectorEnvironmentTestKey]];
    }else
    {
        index = indexPath.row;
        selectedIpArray = [[NSMutableArray alloc]initWithArray:self.ipList[indexPath.section][IPSelectorEnvironmentProductKey]];
    }
    //把当前选择的调到数组的第一位
    ip = [selectedIpArray objectAtIndex:index];
    [selectedIpArray removeObjectAtIndex:index];
    [selectedIpArray insertObject:ip atIndex:0];
    [self.selectIpDictionary setObject:selectedIpArray forKey:self.ipKes[indexPath.section]];
    [self.selectIndexPath setObject:indexPath forKey:self.ipKes[indexPath.section]];
    [tableView reloadData];
}

@end
