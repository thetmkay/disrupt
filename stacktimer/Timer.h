//
//  Timer.h
//  stacktimer
//
//  Created by Niket Shah on 18/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Timer : NSManagedObject

@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * actionOnCompletion;
@property (nonatomic, retain) NSManagedObject *routine;

@end
