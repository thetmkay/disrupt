//
//  Routine.h
//  stacktimer
//
//  Created by Niket Shah on 18/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Timer;

@interface Routine : NSManagedObject

@property (nonatomic, retain) NSString * nameForRoutine;
@property (nonatomic, retain) NSOrderedSet *timers;
@end

@interface Routine (CoreDataGeneratedAccessors)

- (void)insertObject:(Timer *)value inTimersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTimersAtIndex:(NSUInteger)idx;
- (void)insertTimers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTimersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTimersAtIndex:(NSUInteger)idx withObject:(Timer *)value;
- (void)replaceTimersAtIndexes:(NSIndexSet *)indexes withTimers:(NSArray *)values;
- (void)addTimersObject:(Timer *)value;
- (void)removeTimersObject:(Timer *)value;
- (void)addTimers:(NSOrderedSet *)values;
- (void)removeTimers:(NSOrderedSet *)values;
@end
