//
//  OperationObserver.h
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-07-07.
//

#import <Foundation/Foundation.h>
@class Operation;

@protocol OperationObserver <NSObject>
- (void)operationDidStart:(Operation* __nonnull )operation;
- (void)operation:(Operation * __nonnull)operation didProduceOperation:(NSOperation * __nonnull)newOperation;
- (void)operationDidFinish:(Operation* __nonnull )operation errors:(NSArray * __nonnull)errors;
@end