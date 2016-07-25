//
//  ViewController.h
//  GaoDeMapDemo
//
//  Created by zibin on 16/7/22.
//  Copyright © 2016年 zibin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
@interface SendRangeVC : UIViewController
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapLocationManager *locationManager;


@end

