//
//  OperationQueue.m
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-06-30.
//

#import "OperationQueue.h"
#import "Operation.h"
#import "BlockObserver.h"
#import "ExclusivityController.h"

@implementation OperationQueue

- (void)addOperation:(NSOperation __nonnull*)operation
{
    if ([operation isKindOfClass:[Operation class]]){
        Operation * op = (Operation *)operation;
        __weak typeof(self) weakSelf = self;
        // Set up a `BlockObserver` to invoke the `OperationQueueDelegate` method.
        BlockObserver * delegate = [[BlockObserver alloc]
                                    initWithStartHandler:nil
                                    
                                    produceHandler:^(Operation * __nonnull operation, NSOperation * __nonnull newOperation) {
                                        [weakSelf addOperation:newOperation];
                                       } finishHandler:^(Operation * __nonnull operation, NSArray * __nonnull errors) {
                                           [weakSelf.delegate operationQueue:weakSelf operationDidFinishOperation:operation withErrors:errors];
                                       }];

        [op addObserver:delegate];
        // Extract any dependencies needed by this operation.
        NSMutableArray * dependencies = [NSMutableArray arrayWithCapacity:op.conditions.count];
        [op.conditions enumerateObjectsUsingBlock:^(NSObject <OperationCondition> * condition, NSUInteger idx, BOOL *stop)
         {
             [dependencies addObject:[condition dependencyForOperation:op]];
         }];
        
        [dependencies enumerateObjectsUsingBlock:^(NSOperation * dependency, NSUInteger idx, BOOL *stop)
         {
             [op addDependency:dependency];
             [self addOperation:dependency];
         }];
        
        /*
         With condition dependencies added, we can now see if this needs
         dependencies to enforce mutual exclusivity.
         */
        
        NSMutableArray * concurrencyCategories = [NSMutableArray array];
        
        [op.conditions enumerateObjectsUsingBlock:^(NSObject <OperationCondition> *condition, NSUInteger idx, BOOL *stop){
            if ([condition isMutuallyExclusive]){
                return;
            }
            [concurrencyCategories addObject:condition.name];
        }];
        
        if (concurrencyCategories.count)
        {
            // Set up the mutual exclusivity dependencies.
            ExclusivityController * exclusivityController = [ExclusivityController sharedExclusivityController];
            
            [exclusivityController addOperation:op categories:concurrencyCategories];

            
            BlockObserver * obs = [[BlockObserver alloc] initWithStartHandler:nil
                                                               produceHandler:nil
                                                                finishHandler:^(Operation * __nonnull operation, NSArray * __nonnull errors) {
            }];
            
            [op addObserver:obs];
        
        }
    }
}
@end
