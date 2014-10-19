//
//  STTimerTableViewCell.h
//  stacktimer
//
//  Created by Niket Shah on 18/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZTimerLabel.h"

@interface STTimerTableViewCell : UITableViewCell

@property (nonatomic) NSTimeInterval time;

@property (strong, nonatomic) IBOutlet MZTimerLabel *timerLabel;

@end
