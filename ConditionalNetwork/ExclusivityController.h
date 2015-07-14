//
//  ExclusivityController.h
//  AdvancedNSOperation
//
//  Created by Andrey K. on 01.07.15.
//  Copyright (c) 2015 Andrey K. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Operation;

/**
 `ExclusivityController` is a singleton to keep track of all the in-flight
 `Operation` instances that have declared themselves as requiring mutual exclusivity.
 We use a singleton because mutual exclusivity must be enforced across the entire
 app, regardless of the `OperationQueue` on which an `Operation` was executed.
 */

@interface ExclusivityController : NSObject
+(instancetype)sharedExclusivityController;

-(void)addOperation:(Operation __nonnull*)operation categories:(NSArray __nonnull*/*[String]*/)categories;
-(void)removeOperation:(Operation __nonnull*)operation categories:(NSArray __nonnull*/*[String]*/)categories;
@end
