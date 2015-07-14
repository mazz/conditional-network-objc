//
//  Operation.m
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-06-30.
//

#import "Operation.h"

NS_ASSUME_NONNULL_BEGIN
@interface Operation ()
@property (nonatomic) BOOL hasFinishedAlready;
@property (strong, nonatomic) NSArray *internalErrors;
@property (strong, nonatomic) NSArray *observers;
@end
NS_ASSUME_NONNULL_END

@implementation Operation

- (instancetype)init
{
    if ((self = [super init]))
    {
        self.internalErrors = [NSArray new];
        self.observers = [NSArray new];
    }
    return self;
}

- (void)setState:(OperationState)newState
{
    [self willChangeValueForKey:@"state"];
    
    switch (newState)
    {
        case OperationStateCancelled:
            break;
        case OperationStateFinished:
            break;
        default:
            NSAssert(_state != newState, @"Performing invalid cyclic state transition.");
            _state = newState;
            break;
    }
    [self didChangeValueForKey:@"state"];
}

- (BOOL)isReady
{
    if (_state == OperationStatePending)
    {
        if ([super isReady])
        {
            [self evaluateConditions];
        }
        return NO;
    }
    else if (_state == OperationStateReady)
    {
        return [super isReady];
    }
    else
    {
        return NO;
    }
}

- (void)evaluateConditions
{
    NSAssert(_state == OperationStatePending, @"-evaluateConditions was called out-of-order");
    _state = OperationStateEvaluationConditions;
    
    NSArray *failures = [self _evaluate];
    if (failures.count == 0)
    {
        _state = OperationStateReady;
    }
    else
    {
        _state = OperationStateCancelled;
        [self finish:failures];
    }
}

- (NSArray * __nonnull)_evaluate
{
    dispatch_group_t conditionGroup = dispatch_group_create();
    
    NSMutableArray *results = [NSMutableArray array];
    NSMutableArray *failures = [NSMutableArray array];
    
    for (id <OperationCondition> oc in self.conditions)
    {
        dispatch_group_enter(conditionGroup);
        [oc evaluateForOperation:self withCompletion:^(OperationConditionResult * __nonnull result) {
            [results addObject:result];
            dispatch_group_leave(conditionGroup);
        }];
    }
    
    dispatch_group_notify(conditionGroup, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        for (OperationConditionResult *ocr in results)
        {
            if (ocr.error != nil)
            {
                [failures addObject:ocr.error];
            }
        }
        
        if (self.cancelled)
        {
            [failures addObject:[NSError errorWithDomain:@"Operation" code:1 userInfo:nil]];
        }
    });
    return failures;
}

- (void)addCondition:(id <OperationCondition>)condition
{
    NSAssert(_state < OperationStateEvaluationConditions, @"Cannot modify conditions after execution has begun.");
    
    NSMutableArray *mutConditions = [self.conditions mutableCopy];
    [mutConditions addObject:condition];
    self.conditions = [mutConditions copy];
}

- (void)start
{
    NSAssert(_state == OperationStateReady, @"This operation must be performed on an operation queue.");
    [super start];
}

- (void)execute
{
    [self finish:@[]];
}

- (void)cancel
{
    [self cancelWithError:nil];
}

- (void)cancelWithError:(NSError * __nullable)error
{
    if (error != nil)
    {
        NSMutableArray *mutErrors = [self.internalErrors mutableCopy];
        [mutErrors addObject:error];
    }
    
    _state = OperationStateCancelled;
}

- (void)addObserver:(id <OperationObserver>)observer
{
    NSAssert(_state < OperationStateExecuting, @"Cannot modify observers after execution has begun.");
    
    NSMutableArray *mutObservers = [self.observers mutableCopy];
    [mutObservers addObject:observer];
    self.observers = [mutObservers copy];
}

- (void)addDependency:(nonnull NSOperation *)op
{
    NSAssert(_state < OperationStateExecuting, @"Dependencies cannot be modified after execution has begun.");
    [super addDependency:op];
}

- (void)produceOperation:(NSOperation *)operation
{
    for (id <OperationObserver> observer in self.observers)
    {
        [observer operation:self didProduceOperation:operation];
    }
}

- (void)finish:(NSArray * __nonnull)failures
{
    if (!_hasFinishedAlready)
    {
        _hasFinishedAlready = YES;
        _state = OperationStateFinishing;
        
        NSMutableArray *combinedErrors = [NSMutableArray arrayWithArray:self.internalErrors];
        [combinedErrors arrayByAddingObjectsFromArray:failures];
        [self finished:combinedErrors];
        
        for (id<OperationObserver> observer in self.observers)
        {
            [observer operationDidFinish:self errors:combinedErrors];
        }
        
        _state = OperationStateFinished;
    }
}

- (void)finished:(NSArray * __nonnull)errors
{
    // no op
}

@end
