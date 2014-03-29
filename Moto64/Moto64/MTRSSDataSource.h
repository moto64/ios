//
//  MTRSSDataSource.h
//  Moto64
//
//  Created by AseR on 29.03.14.
//  Copyright (c) 2014 AseR. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MTRSSDataSourceSuccessBlock)(NSArray *result);
typedef void(^MTRSSDataSourceFailureBlock)(NSError *error);

@interface MTRSSDataSource : NSObject

//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (MTRSSDataSource *)sharedInstance;

- (BOOL)hasCachedRssFeed;

- (void)fetchRssFeedCachedBlock:(MTRSSDataSourceSuccessBlock)cachedBlock successBlock:(MTRSSDataSourceSuccessBlock)successBlock failureBlock:(MTRSSDataSourceFailureBlock)failureBlock;

@end
