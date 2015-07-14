//
//  URLSessionTaskOperation.h
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-07-13.
//

#import "Operation.h"

@interface URLSessionTaskOperation : Operation
- (instancetype)initWithTask:(NSURLSessionTask __nonnull*)task;
@end
