//
//  UIButton+applyGlassStyle.h
//  iOSCoreLibrary
//
//  Created by Iain McManus on 8/02/13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    egbsSmall = 0,
    egbsMedium,
    egbsLarge
} GlassButtonSize;

@interface UIButton (applyGlassStyle)

- (void) applyGlassStyle:(GlassButtonSize) inButtonSize colour:(UIColor*) inColour;

@end