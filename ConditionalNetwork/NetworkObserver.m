//
//  NetworkObserver.m
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-07-13.
//
// Abstract:
// Contains the code to manage the visibility of the network activity indicator

#import "NetworkObserver.h"

/// Essentially a cancellable `dispatch_after`.
@interface Timer : NSObject
@property (nonatomic) BOOL isCancelled;
- (void)cancel;
@end
@implementation Timer

- (instancetype)initWithInterval:(NSTimeInterval)interval handler:(dispatch_block_t)handler
{
    if ((self = [super init]))
    {
        self.isCancelled = NO;
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, interval * (double)NSEC_PER_SEC);
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_after(when, dispatch_get_main_queue(), ^{
            if (weakSelf.isCancelled)
            {
                handler();
            }
        });
        
    }
    return self;
}

- (void)cancel
{
    self.isCancelled = YES;
}

@end

@interface NetworkIndicatorController : NSObject
@end

static id _sharedIndicatorInstance = nil;

@implementation NetworkIndicatorController
{
    NSUInteger _activityCount;
    Timer *_visibilityTimer;
}

+(instancetype)sharedIndicatorController
{
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedIndicatorInstance = [[self alloc] init];
    });
    return _sharedIndicatorInstance;
}

-(instancetype)init
{
    if (_sharedIndicatorInstance)
    {
        return nil;
    }
    
    if (self = [super init])
    {
        _activityCount = 0;
        _visibilityTimer = [Timer new];
    }
    return self;
}

- (void)networkActivityDidStart
{
    NSAssert([NSThread isMainThread], @"Altering network activity indicator state can only be done on the main thread.");
    _activityCount++;
}

- (void)networkActivityDidEnd
{
    NSAssert([NSThread isMainThread], @"Altering network activity indicator state can only be done on the main thread.");
    _activityCount--;
    
}

- (void)updateIndicatorVisibility
{
    if (_activityCount > 0)
    {
        [self showIndicator];
    }
    else
    {
        /*
         To prevent the indicator from flickering on and off, we delay the
         hiding of the indicator by one second. This provides the chance
         to come in and invalidate the timer before it fires.
         */
        
        _visibilityTimer = [[Timer alloc] initWithInterval:1.0 handler:^{
            [self hideIndicator];
        }];
    }
}

- (void)showIndicator
{
    [_visibilityTimer cancel];
    _visibilityTimer = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)hideIndicator
{
    [_visibilityTimer cancel];
    _visibilityTimer = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end


/**
 An `OperationObserver` that will cause the network activity indicator to appear
 as long as the `Operation` to which it is attached is executing.
 */
@implementation NetworkObserver

- (void)operationDidStart:(Operation * __nonnull)operation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // increment the network indicator's "retain count"
        [[NetworkIndicatorController sharedIndicatorController] networkActivityDidStart];
    });
}

- (void)operation:(Operation * __nonnull)operation didProduceOperation:(NSOperation * __nonnull)newOperation
{
}

- (void)operationDidFinish:(Operation * __nonnull)operation errors:(NSArray * __nonnull)errors
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Decrement the network indicator's "reference count".
        [[NetworkIndicatorController sharedIndicatorController] networkActivityDidEnd];
    });
}
@end

