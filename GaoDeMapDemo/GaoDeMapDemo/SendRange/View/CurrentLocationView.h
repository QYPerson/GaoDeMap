//
//  CurrentLocationView.h
//  GaoDeMapDemo
//
//  Created by zibin on 16/7/23.
//  Copyright © 2016年 zibin. All rights reserved.
//

#import <UIKit/UIKit.h>

//自定义派送范围视图
@interface CurrentLocationView : UIView
//用户位置
@property (weak, nonatomic) IBOutlet UILabel *userLocation;
//点击修改位置按钮调用
@property (nonatomic,copy) void (^ModifyAdrBtnClick)();

@end
