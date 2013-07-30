//
//  AppDelegate.h
//  MapNavigationDemo
//
//  Created by laudmankimo on 12-11-26.
//  Copyright (c) 2012年 laudmankimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

#if __has_feature(objc_arc)
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) ViewController *viewController;
#else
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) ViewController *viewController;
#endif

@end
