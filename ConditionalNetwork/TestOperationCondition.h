//
//  TestOperationCondition.h
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-07-06.
//

#import <Foundation/Foundation.h>
#import "OperationCondition.h"

@interface TestOperationCondition : NSObject <OperationCondition>
@property (strong, nonatomic, readwrite, nonnull) NSString *name;
@property (nonatomic, readwrite) BOOL isMutuallyExclusive;
@end
