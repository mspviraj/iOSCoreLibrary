//
//  Pet+Extensions.m
//  iOSCoreLibrarySampleApp
//
//  Created by Iain McManus on 10/07/2014.
//  Copyright (c) 2014 Injaia. All rights reserved.
//

#import "Pet+Extensions.h"

#import <iOSCoreLibrary/ICLCoreDataManager.h>

@implementation Pet (Extensions)

- (void) awakeFromInsert {
    [super awakeFromInsert];
    
    self.creationDate = [NSDate date];
}

+ (NSArray*) allObjects {
    NSManagedObjectContext* context = [[ICLCoreDataManager Instance] managedObjectContext];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    __block NSArray* results = nil;
    [context performBlockAndWait:^{
        results = [context executeFetchRequest:fetchRequest error:nil];
    }];
    
    return results;
}

@end