//
//  OperationQueue.h
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-06-30.
//

#import <Foundation/Foundation.h>
@class OperationQueue;

@protocol OperationQueueDelegate <NSObject>
@optional
- (void)operationQueue:(OperationQueue __nonnull*)operationQueue willAddOperation:(NSOperation __nonnull*)operation;
- (void)operationQueue:(OperationQueue __nonnull*)operationQueue operationDidFinishOperation:(NSOperation __nonnull*)operation withErrors:(NSArray __nonnull*)errors;
@end

@interface OperationQueue : NSOperationQueue
@property (weak, nonatomic, nullable) id <OperationQueueDelegate> delegate;
@end

