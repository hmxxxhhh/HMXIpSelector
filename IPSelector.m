//
//  IPSelector.m
//  IP
//
//  Created by IOS_HMX on 15/11/13.
//  Copyright (c) 2015年 humingxing. All rights reserved.
//

#import "IPSelector.h"
#import "IPSelectorViewController.h"

NSString *const IPSelectorEnvironmentTestKey = @"test";
NSString *const IPSelectorEnvironmentProductKey = @"product";
NSString *const IPSelectorDefaultIpKey = @"IPSelectorDefaultIpKey";

@interface IPSelector()<UIAlertViewDelegate,IPSelectorViewControllerDelegate>
/**
 *  保存当前使用的IP地址,其值来自于 self.selectIpList
 */
@property(nonatomic ,strong)NSMutableDictionary *ipDictionary;
/**
 *  保存当前IP地址的迭代器
 */
@property(nonatomic ,strong)NSMutableDictionary *enumeratorDictionary;
/**
 *  保存所有的IP的地址，格式：@[@{@"test":@[@"10.10.10.1",@"10.10.10.2"],@"product":@[@"10.10.10.3"]},{...},...]
 *  
 */
@property(nonatomic,strong)NSMutableArray *ipList;
/**
 *  保存用户选择的IP，格式：@{@"zhongtai":@[@"10.10.10.1",@"10.10.10.2"],@"market":@[@"10.10.10.3"]}
 */
@property(nonatomic,strong)NSMutableDictionary *selectIpList;
@end;
@implementation IPSelector
+(IPSelector *)defaultSelector
{
    static IPSelector *selector = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        selector = [[IPSelector alloc]init];
    });
    return selector;
}
-(void)parseIpData
{
    
    self.ipList  = [[NSMutableArray alloc]init];
    self.selectIpList = [[NSMutableDictionary alloc]init];
    self.enumeratorDictionary = [[NSMutableDictionary alloc]init];
    self.ipDictionary = [[NSMutableDictionary alloc]init];
    
    NSDictionary *tempDictonary;
    //如果获取到了IP，否则使用默认IP
    if (self.ipData && self.ipData.length>0) {
        tempDictonary = [NSJSONSerialization JSONObjectWithData:self.ipData options:NSJSONReadingMutableLeaves error:nil];
        if (!tempDictonary) {
            //如果本地有保存的  就取本地的
            tempDictonary = [[NSUserDefaults standardUserDefaults] objectForKey:IPSelectorDefaultIpKey];
            if(tempDictonary == nil)
            {
                tempDictonary = self.defaultIpList;
            }
        }
    }else
    {
        tempDictonary = [[NSUserDefaults standardUserDefaults] objectForKey:IPSelectorDefaultIpKey];
        if(tempDictonary == nil)
        {
            tempDictonary = self.defaultIpList;
        }
    }
    [[NSUserDefaults standardUserDefaults]setObject:tempDictonary forKey:IPSelectorDefaultIpKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
    //解析数据
    //测试
    NSDictionary *allTestIps = [tempDictonary objectForKey:IPSelectorEnvironmentTestKey];
    //生产
    NSDictionary *allProductIps = [tempDictonary objectForKey:IPSelectorEnvironmentProductKey];
    for (int i=0; i<self.ipKeys.count; i++) {
        NSMutableDictionary *ips = [[NSMutableDictionary alloc]init];
        NSString *ipKey = self.ipKeys[i];
        if (allProductIps && [allProductIps objectForKey:ipKey]) {
            [ips setObject:[allProductIps objectForKey:ipKey] forKey:[NSString stringWithFormat:@"%@",IPSelectorEnvironmentProductKey]];
        }
        if (allTestIps && [allTestIps objectForKey:ipKey]) {
            [ips setObject:[allTestIps objectForKey:ipKey] forKey:[NSString stringWithFormat:@"%@",IPSelectorEnvironmentTestKey]];
        }
        [self.ipList addObject:ips];
    }
    
    /**
     *  如果是test用户选择IP的页面
     */
    if (self.isTest) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请选择服务器" delegate:self cancelButtonTitle:@"生产" otherButtonTitles:@"测试", nil];
        [alertView show];
        
    }else
    {
        //如果是生产，自动配置IP
        [self configProductIP];
    }

    
}
//配置生产用的IP到selectIpList
-(void)configProductIP
{
    for (int keyCount = 0; keyCount<self.ipList.count; keyCount++) {
        NSDictionary *ipDic = self.ipList[keyCount];
        NSString *ipKey = self.ipKeys[keyCount];
        NSArray *ips = ipDic[IPSelectorEnvironmentProductKey];
        [self.selectIpList setObject:ips forKey:ipKey];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(ipSelectorDidConfigerIp)]) {
        [self.delegate ipSelectorDidConfigerIp];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //如果是生产，自动配置IP
        [self configProductIP];
    }else
    {
        IPSelectorViewController *vc = [[IPSelectorViewController alloc]initWithIpList:[self.ipList mutableCopy] ipKeys:[self.ipKeys copy] ipNames:self.ipNames];
        vc.delegate = self;
        [self.viewController presentViewController:vc animated:YES completion:nil];
    }
    
}
-(NSString *)getIpForKey:(NSString *)ipKey
{
    if (self.selectIpList.count==0) {
        return nil;
    }
    NSString *ip = [self.ipDictionary objectForKey:ipKey];
    if (ip==nil) {
        NSArray *array = [self.selectIpList objectForKey:ipKey];
        NSEnumerator *ipEnumerator = [array objectEnumerator];
        [self.enumeratorDictionary setObject:ipEnumerator forKey:ipKey];
        ip = [ipEnumerator nextObject];
        if (ip) {
            [self.ipDictionary setObject:ip forKey:ipKey];
        }
    }
    return ip;
    
}
-(NSString *)getNextIpForKey:(NSString *)ipKey
{
    if (self.selectIpList.count==0) {
        return nil;
    }
    NSEnumerator *ipEnumerator = [self.enumeratorDictionary objectForKey:ipKey];
    NSString* ip = [ipEnumerator nextObject];
    if (ip) {
        [self.ipDictionary setObject:ip forKey:ipKey];
    }
    return ip;
}
-(void)ipSelectorViewControllerdidSelectedIp:(NSMutableDictionary *)selectedIp
{
    self.selectIpList = selectedIp;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ipSelectorDidConfigerIp)]) {
        [self.delegate ipSelectorDidConfigerIp];
    }
}


@end
