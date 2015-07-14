//
//  ViewController.m
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-06-30.
//

#import "ViewController.h"
#import "OperationQueue.h"
#import "DownloadEarthquakesOperation.h"

@interface ViewController ()
@property (strong, nonatomic, nonnull) OperationQueue *operationQueue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.operationQueue = [[OperationQueue alloc] init];
    
    NSURL *cacheFolder = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *cacheFile = [cacheFolder URLByAppendingPathComponent:@"earthquakes.json"];
    
    DownloadEarthquakesOperation *downloadOperation = [[DownloadEarthquakesOperation alloc] initWithCacheFile:cacheFile];
    /*
     This operation is made of three child operations:
     1. The operation to download the JSON feed
     2. The operation to parse the JSON feed and insert the elements into the Core Data store
     3. The operation to invoke the completion handler
     */
    
    [self.operationQueue addOperation:downloadOperation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
//    [UIView animateKeyframesWithDuration:<#(NSTimeInterval)#> delay:<#(NSTimeInterval)#> options:<#(UIViewKeyframeAnimationOptions)#> animations:<#^(void)animations#> completion:^(BOOL finished) {
        // (void (^ __nullable)(BOOL finished))completion
//    }];
    
//    OperationConditionResult *ocr = [OperationConditionResult operationConditionResultWithState:OperationConditionResultStateSatisfied];
}


@end
