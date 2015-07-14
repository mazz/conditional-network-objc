//
//  BlockObserver.m
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-07-08.
//

#import "BlockObserver.h"

typedef void(^BlockObserverStartHandler)(Operation *operation);
typedef void(^BlockObserverProduceHandler)(Operation *operation, NSOperation *newOperation);
typedef void(^BlockObserverFinishHandler)(Operation *operation, NSArray *errors);

@implementation BlockObserver
{
    BlockObserverStartHandler _startHandler;
    BlockObserverProduceHandler _produceHandler;
    BlockObserverFinishHandler _finishHandler;
}

- (instancetype)initWithStartHandler:(void(^ __nullable)(Operation * __nonnull operation))startHandler produceHandler:(void(^ __nullable)(Operation *__nonnull operation, NSOperation * __nonnull newOperation))produceHandler finishHandler:(void(^ __nullable)(Operation * __nonnull operation, NSArray * __nonnull errors))finishHandler
{
    if ((self = [super init]))
    {
        _startHandler = startHandler;
        _produceHandler = produceHandler;
        _finishHandler = finishHandler;
    }
    return self;
}

- (void)operationDidStart:(Operation * __nonnull)operation
{
    if (_startHandler != nil)
    {
        _startHandler(operation);
    }
}

- (void)operation:(Operation * __nonnull)operation didProduceOperation:(NSOperation * __nonnull)newOperation
{
    if (_produceHandler != nil)
    {
        _produceHandler(operation, newOperation);
    }
}

- (void)operationDidFinish:(Operation * __nonnull)operation errors:(NSArray * __nonnull)errors
{
    if (_finishHandler != nil)
    {
        _finishHandler(operation, errors);
    }
}

@end

