//
//  Operation.h
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-06-30.
//

#import <Foundation/Foundation.h>
#import "OperationCondition.h"
#import "OperationObserver.h"

typedef NS_ENUM(NSInteger, OperationState)
{
    OperationStateInitialized,
    OperationStatePending,
    OperationStateEvaluationConditions,
    OperationStateReady,
    OperationStateExecuting,
    OperationStateFinishing,
    OperationStateFinished,
    OperationStateCancelled
};

NS_ASSUME_NONNULL_BEGIN
@interface Operation : NSOperation
@property (nonatomic) OperationState state;
@property (strong, nonatomic) NSArray *conditions;
- (void)execute;
- (void)cancel;
- (void)cancelWithError:(NSError * __nullable)error;
- (void)addCondition:(id <OperationCondition>)condition;
- (void)addObserver:(id <OperationObserver>)observer;
- (void)addDependency:(nonnull NSOperation *)op;
- (void)produceOperation:(NSOperation *)operation;
- (void)finish:(NSArray * __nonnull)failures;
@end
NS_ASSUME_NONNULL_END