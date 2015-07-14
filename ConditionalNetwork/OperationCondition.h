//
//  OperationCondition.h
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-07-06.
//

#import <Foundation/Foundation.h>
@class Operation;
//#import "Operation.h"
#import "OperationConditionResult.h"

@protocol OperationCondition <NSObject>

-(NSString __nonnull*)name;
-(BOOL)isMutuallyExclusive;
- (NSOperation * __nullable)dependencyForOperation:(Operation* __nonnull )operation;
- (void)evaluateForOperation:(Operation * __nonnull)operation withCompletion:(void (^ __nullable)(OperationConditionResult * __nonnull result))completion;
@end