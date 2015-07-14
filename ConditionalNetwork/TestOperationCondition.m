//
//  TestOperationCondition.m
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-07-06.
//

#import "TestOperationCondition.h"
#import "OperationConditionResult.h"

@implementation TestOperationCondition
@dynamic name;
@dynamic isMutuallyExclusive;
-(instancetype)init
{
    if ((self = [super init]))
    {
        self.name = @"test";
        self.isMutuallyExclusive = NO;
    }
    return self;
}

- (NSOperation * __nullable)dependencyForOperation:(Operation * __nonnull)operation
{
    return nil;
}

-(void)evaluateForOperation:(Operation * __nonnull)operation withCompletion:(void (^ __nullable)(OperationConditionResult * __nonnull))completion
{
    //return a bogus success result for now
    OperationConditionResult *ocr = [OperationConditionResult operationConditionResultWithState:OperationConditionResultStateSatisfied];
    completion(ocr);
}

@end
