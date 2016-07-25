//
//  CurrentLocationView.m
//  GaoDeMapDemo
//
//  Created by zibin on 16/7/23.
//  Copyright © 2016年 zibin. All rights reserved.
//

#import "CurrentLocationView.h"

@interface CurrentLocationView ()
//修改地址按钮点击
- (IBAction)ModifyAdrBtnClicked:(UIButton *)sender;

@end


@implementation CurrentLocationView




//修改地址按钮点击
- (IBAction)ModifyAdrBtnClicked:(UIButton *)sender {
    //调用Block
    if (self.ModifyAdrBtnClick) {
        self.ModifyAdrBtnClick();
    }
    
}
@end
