//
//  OperationConditionResult.h
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-07-06.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OperationConditionResultState)
{
    OperationConditionResultStateSatisfied,
    OperationConditionResultStateFailed
};
NS_ASSUME_NONNULL_BEGIN
@interface OperationConditionResult : NSObject
@property (nonatomic) OperationConditionResultState conditionResultState;
@property (strong, nonatomic, nullable) NSError *error;
+ (instancetype)operationConditionResultWithState:(OperationConditionResultState)state;
NS_ASSUME_NONNULL_END
@end
