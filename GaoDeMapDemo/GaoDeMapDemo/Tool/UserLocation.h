//
//  UserLocation.h
//  GaoDeMapDemo
//
//  Created by zibin on 16/7/26.
//  Copyright © 2016年 zibin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
@interface UserLocation : NSObject


/**
 *  获取用户位置位置管理者
 *
 *  @return 返回管理者
 */
+ (UserLocation *)sharedUserLocationManager;

/**
 *  获取用户当前位置
 *
 *  @param userAddress 用户当前地址
 *  @param error       获取失败
 */
-(void)getUserLocationSuccess:(void(^)(NSString *userAddress))userAddress faild:(void(^)(NSError *error))error;
@end
