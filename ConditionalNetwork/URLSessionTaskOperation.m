//
//  URLSessionTaskOperation.m
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-07-13.
//
//  Abstract:
//  Shows how to lift operation-like objects in to the NSOperation world.

#import "URLSessionTaskOperation.h"
#import "Operation.h"

static void *URLSessionTaksOperationKVOContext = (void*)&URLSessionTaksOperationKVOContext;

/**
 `URLSessionTaskOperation` is an `Operation` that lifts an `NSURLSessionTask`
 into an operation.
 
 Note that this operation does not participate in any of the delegate callbacks \
 of an `NSURLSession`, but instead uses Key-Value-Observing to know when the
 task has been completed. It also does not get notified about any errors that
 occurred during execution of the task.
 
 An example usage of `URLSessionTaskOperation` can be seen in the `DownloadEarthquakesOperation`.
 */

@interface URLSessionTaskOperation()
NS_ASSUME_NONNULL_BEGIN
@property (strong, nonatomic) NSURLSessionTask *task;
NS_ASSUME_NONNULL_END
@end

@implementation URLSessionTaskOperation
- (instancetype)initWithTask:(NSURLSessionTask __nonnull*)task
{
    if ((self = [super init]))
    {
        self.task = task;
    }
    return self;
}

- (void)execute
{
    NSAssert((self.task.state == NSURLSessionTaskStateSuspended), @"Task was resumed by something other than self");
    
    [self.task addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:&URLSessionTaksOperationKVOContext];
}

-(void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context
{
    if (context == URLSessionTaksOperationKVOContext)
    {
        if (object == self.task && [keyPath isEqualToString:@"state"] && self.task.state == NSURLSessionTaskStateCompleted)
        {
            [self.task removeObserver:self forKeyPath:@"state"];
        }
    }
}

- (void)cancel
{
    [self.task cancel];
    [super cancel];
}
@end
