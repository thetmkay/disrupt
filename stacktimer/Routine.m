//
//  Routine.m
//  stacktimer
//
//  Created by Niket Shah on 18/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//

#import "Routine.h"
#import "Timer.h"


@implementation Routine

@dynamic nameForRoutine;
@dynamic timers;

- (void)addTimersObject:(Timer *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.timers];
    [tempSet addObject:value];
    self.timers = tempSet;
}

@end
