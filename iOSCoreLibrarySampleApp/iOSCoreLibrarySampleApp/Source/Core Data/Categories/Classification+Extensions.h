//
//  Classification+Extensions.h
//  iOSCoreLibrarySampleApp
//
//  Created by Iain McManus on 10/07/2014.
//  Copyright (c) 2014 Injaia. All rights reserved.
//

#import "Classification.h"

@interface Classification (Extensions)

+ (NSArray*) allObjects;

- (NSNumber*) fingerprint;
- (void) remapAllReferencesTo:(Classification*) primeObject;

@end
