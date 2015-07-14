//
//  GroupOperation.h
//  AdvancedNSOperation
//
//  Created by Andrey K. on 05.07.15.
//  Copyright (c) 2015 Andrey K. All rights reserved.
//

#import "Operation.h"

@interface GroupOperation : Operation

-(instancetype)initWithOperations:(NSArray /*NSOperations*/ __nonnull*)operations;
-(void)addOperation:(NSOperation __nonnull*)operation;
-(void)aggregateError:(NSError __nonnull*)error;
-(void)operationDidFinish:(NSOperation __nonnull*)operation withErrors:(NSArray __nonnull*)errors;
@end
