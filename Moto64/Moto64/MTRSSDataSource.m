//
//  MTRSSDataSource.m
//  Moto64
//
//  Created by AseR on 29.03.14.
//  Copyright (c) 2014 AseR. All rights reserved.
//

#import "MTRSSDataSource.h"
#import "RSSItem.h"
#import "RSSParser.h"

@implementation MTRSSDataSource

+ (MTRSSDataSource *)sharedInstance
{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (BOOL)hasCachedRssFeed
{
    return NO;
}

- (NSArray *)fetchCachedRssFeed
{
    NSMutableArray *results = [NSMutableArray array];
    return results;
}

- (void)fetchRssFeedCachedBlock:(MTRSSDataSourceSuccessBlock)cachedBlock successBlock:(MTRSSDataSourceSuccessBlock)successBlock failureBlock:(MTRSSDataSourceFailureBlock)failureBlock
{
    if (cachedBlock) {
        NSArray *cachedFeed = [self fetchCachedRssFeed];
        cachedBlock(cachedFeed);
    }
    
    NSURL *url = [NSURL URLWithString:@"http://moto64.ru/index.php?app=core&module=global&section=rss&type=forums&id=2"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [RSSParser parseRSSFeedForRequest:request success:^(NSArray *feedItems) {
        
        for (RSSItem *item in feedItems) {

//            NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//            NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
            
            NSManagedObjectContext *context = [self managedObjectContext];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
            
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
            
            // If appropriate, configure the new managed object.
            // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
            [newManagedObject setValue:item.pubDate forKey:@"pubDate"];
            [newManagedObject setValue:item.title forKey:@"title"];
            [newManagedObject setValue:[item.link absoluteString] forKey:@"link"];
            
            // Save the context.
            NSError *error = nil;
            if (![context save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        
        if (successBlock) {
            NSArray *cachedFeed = [self fetchCachedRssFeed];
            successBlock(cachedFeed);
        }
    } failure:failureBlock];
}

@end
