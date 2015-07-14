//
//  BlockObserver.h
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-07-08.
//

#import <Foundation/Foundation.h>
#import "OperationObserver.h"


@interface BlockObserver : NSObject <OperationObserver>

- (instancetype)initWithStartHandler:(void(^ __nullable)(Operation * __nonnull operation))startHandler produceHandler:(void(^ __nullable)(Operation *__nonnull operation, NSOperation * __nonnull newOperation))produceHandler finishHandler:(void(^ __nullable)(Operation * __nonnull operation, NSArray * __nonnull errors))finishHandler;
@end
