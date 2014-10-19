//
//  AppDelegate.h
//  stacktimer
//
//  Created by Niket Shah on 18/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLoginController.h"

@class STAPIController;
@class YMLoginController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) STAPIController *apiController;

@end

