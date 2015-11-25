//
//  IPSelectorViewController.h
//  IP
//
//  Created by IOS_HMX on 15/11/13.
//  Copyright (c) 2015年 humingxing. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol IPSelectorViewControllerDelegate <NSObject>
-(void)ipSelectorViewControllerdidSelectedIp:(NSDictionary *)selectedIp;
@end
@interface IPSelectorViewController : UIViewController
@property(nonatomic,assign)id<IPSelectorViewControllerDelegate>delegate;
-(instancetype)initWithIpList:(NSMutableArray *)ipList ipKeys:(NSArray *)ipKeys ipNames:(NSArray *)ipNames;
@end
