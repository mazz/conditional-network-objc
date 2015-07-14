//
//  OperationConditionResult.m
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-07-06.
//

#import "OperationConditionResult.h"

@implementation OperationConditionResult

+ (instancetype)operationConditionResultWithState:(OperationConditionResultState)state
{
    OperationConditionResult *result = [[self class] init];
    result.conditionResultState = state;
    
    return result;
}
@end
