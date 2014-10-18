//
//  STRoutine.m
//  stacktimer
//
//  Created by Niket Shah on 18/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//

#import "STRoutine.h"
#import "Routine.h"
#import "Timer.h"

@interface STRoutine()

@end

@implementation STRoutine

- (void)addNewRoutineWithName:(NSString *)name withCompletionBlock:(void (^)(BOOL success))completionBlock {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Routine *routine = [Routine MR_createInContext:localContext];
        routine.nameForRoutine = name;
    } completion:^(BOOL success, NSError *error) {
        completionBlock(success);
    }];
}

- (void)addTimer:(Timer *)timer toRoutineWithName:(NSString *)routineName withCompletionBlock:(void (^)(BOOL success))completionBlock {
    Routine *routine = [Routine MR_findFirstByAttribute:@"nameForRoutine" withValue:routineName];
    if (routine) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            Routine *localRoutine = [routine MR_inContext:localContext];
            Timer *localTimer = [timer MR_inContext:localContext];
            [localRoutine addTimersObject:localTimer];
        } completion:^(BOOL success, NSError *error) {
            completionBlock(success);
        }];
    } else {
        completionBlock(NO);
    }
}

@end
