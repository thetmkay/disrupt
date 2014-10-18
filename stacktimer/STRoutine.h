//
//  STRoutine.h
//  stacktimer
//
//  Created by Niket Shah on 18/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//

@class Timer;

#import <Foundation/Foundation.h>

@interface STRoutine : NSObject

- (void)addNewRoutineWithName:(NSString *)name withCompletionBlock:(void (^)(BOOL success))completionBlock;

// adds timer to the end of the routine
- (void)addTimer:(Timer *)timer toRoutineWithName:(NSString *)routineName  withCompletionBlock:(void (^)(BOOL success))completionBlock;

@end
