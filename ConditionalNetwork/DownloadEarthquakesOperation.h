//
//  DownloadEarthquakesOperation.h
//  ConditionalNetwork
//
//  Created by Michael Hanna on 2015-07-11.
//

#import "GroupOperation.h"

@interface DownloadEarthquakesOperation : GroupOperation
- (instancetype)initWithCacheFile:(NSURL __nonnull*)cacheFile;
- (void)downloadFinishedForURL:(NSURL __nonnull*)url response:(NSHTTPURLResponse __nullable*)response error:(NSError __nullable*)error;
@end
