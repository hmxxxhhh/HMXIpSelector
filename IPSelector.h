//
//  IPSelector.h
//  IP
//
//  Created by IOS_HMX on 15/11/13.
//  Copyright (c) 2015年 humingxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern NSString *const IPSelectorEnvironmentTestKey ;
extern NSString *const IPSelectorEnvironmentProductKey ;
extern NSString *const IPSelectorDefaultIpKey ;
@protocol IPSelectorDelegate <NSObject>

@optional
-(void)ipSelectorDidConfigerIp;

@end

@interface IPSelector : NSObject
@property(nonatomic,weak)UIViewController *viewController;
@property(nonatomic,strong)NSData *ipData;
/**
 *  默认IP，格式：@{@"zhongtai":@[@"10.10.10.1",@"10.10.10.2"],@"market":@[@"10.10.10.3"]}
 */
@property(nonatomic,strong)NSMutableDictionary *defaultIpList;
@property(nonatomic,copy)NSArray *ipKeys;
@property(nonatomic,copy)NSArray *ipNames;
@property(nonatomic,assign)BOOL isTest;
@property(nonatomic,assign)id<IPSelectorDelegate>delegate;

+(IPSelector *)defaultSelector;
-(void)parseIpData;


-(NSString *)getIpForKey:(NSString*)ipKey;
-(NSString *)getNextIpForKey:(NSString*)ipKey;
@end
