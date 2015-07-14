//
//  ExclusivityController.m
//  AdvancedNSOperation
//
//  Created by Andrey K. on 01.07.15.
//  Copyright (c) 2015 Andrey K. All rights reserved.
//

#import "ExclusivityController.h"
#import "Operation.h"

static id _sharedInstance = nil;
@interface ExclusivityController ()
{
    dispatch_queue_t _serialQueue;
    NSMutableDictionary * _operations; // [String: [Operation]]
}
@end

@implementation ExclusivityController
+(instancetype)sharedExclusivityController
{
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}
-(instancetype)init
{
    if (_sharedInstance) {
        return nil;
    }
    if (self = [super init]){
        _serialQueue = dispatch_queue_create("Operations.ExclusivityController",DISPATCH_QUEUE_SERIAL);
        _operations = [NSMutableDictionary dictionary];
    }
    return self;
}
/// Registers an operation as being mutually exclusive
-(void)addOperation:(Operation __nonnull*)operation categories:(NSArray __nonnull*/*[String]*/)categories
{
    /*
     This needs to be a synchronous operation.
     If this were async, then we might not get around to adding dependencies
     until after the operation had already begun, which would be incorrect.
     */
    dispatch_sync(_serialQueue, ^{
        for (NSString * category in categories) {
            [self noqueue_addOperation:operation category:category];
        }
    });
}

/// Unregisters an operation from being mutually exclusive.
-(void)removeOperation:(Operation __nonnull*)operation categories:(NSArray __nonnull*/*[String]*/)categories
{
    dispatch_async(_serialQueue, ^{
        for (NSString * category in categories) {
            [self noqueue_removeOperation:operation category:category];
        }
    });
}

#pragma mark - Operation Management
-(void)noqueue_addOperation:(Operation __nonnull*)operation category:(NSString __nonnull*)category
{
    NSMutableArray * operationsWithThisCategory = _operations[category] ?: @[].mutableCopy;
    
    Operation * last = operationsWithThisCategory.lastObject;
    if (last) {
        [operation addDependency:last];
    }
    
    [operationsWithThisCategory addObject:operation];
    
    _operations[category] = operationsWithThisCategory;
}

-(void)noqueue_removeOperation:(Operation __nonnull*)operation category:(NSString __nonnull*)category
{
    NSMutableArray * matchingOperations = _operations[category];
    if (matchingOperations){
        [matchingOperations removeObject:operation];
        _operations[category] = matchingOperations;
    }
}
@end
