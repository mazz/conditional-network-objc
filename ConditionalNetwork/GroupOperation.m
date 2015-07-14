//
//  GroupOperation.m
//  AdvancedNSOperation
//
//  Created by Andrey K. on 05.07.15.
//  Copyright (c) 2015 Andrey K. All rights reserved.
//

#import "GroupOperation.h"
#import "OperationQueue.h"

/**
 A subclass of `Operation` that executes zero or more operations as part of its
 own execution. This class of operation is very useful for abstracting several
 smaller operations into a larger operation. As an example, the `GetEarthquakesOperation`
 is composed of both a `DownloadEarthquakesOperation` and a `ParseEarthquakesOperation`.
 
 Additionally, `GroupOperation`s are useful if you establish a chain of dependencies,
 but part of the chain may "loop". For example, if you have an operation that
 requires the user to be authenticated, you may consider putting the "login"
 operation inside a group operation. That way, the "login" operation may produce
 subsequent operations (still within the outer `GroupOperation`) that will all
 be executed before the rest of the operations in the initial chain of operations.
 */

@interface GroupOperation () <OperationQueueDelegate>
NS_ASSUME_NONNULL_BEGIN
@property (nonatomic, strong) OperationQueue * internalQueue;
@property (nonatomic, copy) NSBlockOperation * finishingOperation;
@property (nonatomic, strong) NSMutableArray /*NSError*/* aggregatedErrors;
NS_ASSUME_NONNULL_END
@end

@implementation GroupOperation
-(instancetype)initWithOperations:(NSArray /*NSOperations*/*)operations
{
    if (self = [super init]){
        _internalQueue = [OperationQueue new];
        _internalQueue.suspended = YES;
        _internalQueue.delegate = self;
        
        for (NSOperation * op in operations){
            [_internalQueue addOperation:op];
        }
    }
    return self;
}

-(void)cancel
{
    [self.internalQueue cancelAllOperations];
    [super cancel];
}
-(void)execute
{
    self.internalQueue.suspended = NO;
    [self.internalQueue addOperation:self.finishingOperation];
}
-(void)addOperation:(NSOperation *)operation
{
    [self.internalQueue addOperation:operation];
}

/**
 Note that some part of execution has produced an error.
 Errors aggregated through this method will be included in the final array
 of errors reported to observers and to the `finished(_:)` method.
 */
-(void)aggregateError:(NSError __nonnull*)error
{
    [self.aggregatedErrors addObject:error];
}

-(void)operationDidFinish:(NSOperation __nonnull*)operation withErrors:(NSArray __nonnull*)errors
{
    // For use by subclassers.
}

#pragma mark - OperationQueueDelegate
-(void)operationQueue:(OperationQueue __nonnull*)operationQueue willAddOperation:(NSOperation __nonnull*)operation
{
    NSAssert(!self.finishingOperation.finished && !self.finishingOperation.executing, @"cannot add new operations to a group after the group has completed");

    /*
     Some operation in this group has produced a new operation to execute.
     We want to allow that operation to execute before the group completes,
     so we'll make the finishing operation dependent on this newly-produced operation.
     */
    if (operation != self.finishingOperation) {
        [self.finishingOperation addDependency:operation];
    }

}
-(void)operationQueue:(OperationQueue __nonnull*)operationQueue operationDidFinish:(NSOperation __nonnull*)operation withErrors:(NSArray __nonnull*)errors
{
    [self.aggregatedErrors addObjectsFromArray:errors];
    
    if (operation == self.finishingOperation){
        self.internalQueue.suspended = YES;
        [self finish:self.aggregatedErrors.copy];
    } else {
        [self operationDidFinish:operation withErrors:errors];
    }
}
@end
