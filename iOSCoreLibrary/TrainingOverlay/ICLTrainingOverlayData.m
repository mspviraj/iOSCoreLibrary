//
//  ICLTrainingOverlayData.m
//  iOSCoreLibrary
//
//  Created by Iain McManus on 4/09/2014.
//  Copyright (c) 2014 Iain McManus. All rights reserved.
//

#import "ICLTrainingOverlayData.h"

NSString* const kICLTrainingOverlay_ElementColour = @"ElementColour";
NSString* const kICLTrainingOverlay_ElementRect = @"ElementRect";
NSString* const kICLTrainingOverlay_ElementControls = @"ElementControls";
NSString* const kICLTrainingOverlay_ElementDescription = @"ElementDescription";
NSString* const kICLTrainingOverlay_ElementHasHighlight = @"ElementHighlight";

@implementation ICLTrainingOverlayData

- (void) addElement_Internal:(NSObject*) element description:(NSString*) elementDescription hasHighlight:(BOOL) hasHighlight {
    // null permitted
    if ([element isEqual:[NSNull null]]) {
        
    }
    else if ([element isKindOfClass:[UIView class]]) {
        
    }
    else if ([element isKindOfClass:[NSArray class]]) {
        NSArray* elementAsArray = (NSArray*) element;
        NSObject* parent = elementAsArray[0];
        NSObject* child = elementAsArray[1];
        
        if ([child isKindOfClass:[UIBarButtonItem class]]) {
        }
        else if ([child isKindOfClass:[UITabBarItem class]]) {
        }
        else if ([child isKindOfClass:[UINavigationItem class]]) {
        }
        else if ([parent isKindOfClass:[UISegmentedControl class]] && [child isKindOfClass:[NSNumber class]]) {
        }
        else if ([parent isKindOfClass:[UIView class]] && [child isKindOfClass:[UIView class]]) {
        }
        else {
            NSLog(@"Unknown element type %@ for %@", NSStringFromClass([element class]), elementDescription);
            assert(0);
            
            return;
        }
    }
    else {
        NSLog(@"Unknown element type %@ for %@", NSStringFromClass([element class]), elementDescription);
        assert(0);
        
        return;
    }
    
    if (!self.elements) {
        self.elements = [[NSMutableArray alloc] init];
    }
    
    [self.elements addObject:@{kICLTrainingOverlay_ElementControls: element,
                               kICLTrainingOverlay_ElementDescription: elementDescription,
                               kICLTrainingOverlay_ElementHasHighlight: @(hasHighlight)}];
}

- (void) addElement:(NSObject*) element description:(NSString*) elementDescription {
    [self addElement_Internal:element description:elementDescription hasHighlight:YES];
}

- (void) addUnhighlightedElement:(NSObject*) element {
    [self addElement_Internal:element description:@"" hasHighlight:NO];
}

- (void) removeAllElements {
    self.elements = nil;
    self.elementsMetadata = nil;
}

- (void) refreshInternalData:(TrainingOverlayStyle) overlayStyle {
    const NSUInteger numElements = [self numElements];
    self.elementsMetadata = [[NSMutableArray alloc] initWithCapacity:numElements];

    CGFloat hueIncrement = ([self numElements] > 0 ? (360.0f / [self numElements]) : 0.0f) / 360.0f;
    CGFloat currentHue = 0.0f;
    
    // Iterate over all of the elements drawing the background data
    for (NSUInteger elementIndex = 0; elementIndex < numElements; ++elementIndex) {
        CGRect elementRect = [self buildRectForElement:elementIndex];
        
        UIColor* elementColour = nil;
        if ([self doesElementHaveHighlight:elementIndex]) {
            if (overlayStyle == etsDarken) {
                elementColour = [UIColor colorWithHue:currentHue saturation:0.75f brightness:0.95f alpha:0.95f];
            }
            else {
                elementColour = [UIColor colorWithHue:currentHue saturation:0.75f brightness:0.75f alpha:1.0f];
            }
            
            currentHue += hueIncrement;
        }
        else {
            elementColour = [UIColor clearColor];
        }
        
        [self.elementsMetadata addObject:@{kICLTrainingOverlay_ElementColour: elementColour,
                                           kICLTrainingOverlay_ElementRect: [NSValue valueWithCGRect:elementRect]}];
    }
}

- (BOOL) doesElementHaveHighlight:(NSUInteger) elementIndex {
    return [(self.elements[elementIndex])[kICLTrainingOverlay_ElementHasHighlight] boolValue];
}

- (CGRect) buildRectForElement:(NSUInteger) elementIndex {
    CGRect elementRect = CGRectMake(0, 0, 0, 0);
    
    NSObject* element = (self.elements[elementIndex])[kICLTrainingOverlay_ElementControls];

    // Element is null
    if ([element isEqual:[NSNull null]]) {
        
    } // Element is a UIView
    else if ([element isKindOfClass:[UIView class]]) {
        UIView* elementAsView = (UIView*) element;
        
        elementRect = [elementAsView convertRect:elementAsView.bounds toView:self.overlayView];
    } // Element is a complex type
    else if ([element isKindOfClass:[NSArray class]]) {
        NSArray* elementAsArray = (NSArray*) element;
        NSObject* parent = elementAsArray[0];
        NSObject* child = elementAsArray[1];
        
        // UIBarButtonItem within a UIToolbar
        if ([child isKindOfClass:[UIBarButtonItem class]]) {
            UIBarButtonItem* childAsBarButtonItem = (UIBarButtonItem*) child;
            UIToolbar* parentAsToolbar = (UIToolbar*) parent;
            
            ////////////////////////////////////////////////////////////////////////////////
            // Begin block based on http://stackoverflow.com/questions/8231737/how-to-determine-position-of-uibarbuttonitem-in-uitoolbar
            
            UIControl* control = nil;
            for (UIView* subview in parentAsToolbar.subviews) {
                if ([subview isKindOfClass:[UIControl class]]) {
                    for (id target in [(UIControl*) subview allTargets]) {
                        if (target == childAsBarButtonItem) {
                            control = (UIControl* )subview;
                            break;
                        }
                    }
                    
                    if (control != nil) {
                        break;
                    }
                }
            }
            
            // End Block
            ////////////////////////////////////////////////////////////////////////////////
            
            if (control) {
                elementRect = [control convertRect:control.bounds toView:self.overlayView];
            }
        }
        else if ([child isKindOfClass:[UINavigationItem class]]) {
            UINavigationItem* childAsNavigationItem = (UINavigationItem*) child;
            UINavigationBar* parentAsNavigationBar = (UINavigationBar*) parent;
            
            ////////////////////////////////////////////////////////////////////////////////
            // Begin block based on http://stackoverflow.com/questions/8231737/how-to-determine-position-of-uibarbuttonitem-in-uitoolbar
            
            UIControl* control = nil;
            for (UIView* subview in parentAsNavigationBar.subviews) {
                if ([subview isKindOfClass:[UIControl class]]) {
                    for (id target in [(UIControl*) subview allTargets]) {
                        if (target == childAsNavigationItem) {
                            control = (UIControl* )subview;
                            break;
                        }
                    }
                    
                    if (control != nil) {
                        break;
                    }
                }
            }
            
            // End Block
            ////////////////////////////////////////////////////////////////////////////////
            
            if (control) {
                elementRect = [control convertRect:control.bounds toView:self.overlayView];
            }
        }
        else if ([child isKindOfClass:[UITabBarItem class]]) {
            UITabBarItem* childAsTabBarItem = (UITabBarItem*) child;
            UITabBar* parentAsTabBar = (UITabBar*) parent;
            
            ////////////////////////////////////////////////////////////////////////////////
            // Begin block based on http://stackoverflow.com/questions/8231737/how-to-determine-position-of-uibarbuttonitem-in-uitoolbar
            
            UIControl* control = nil;
            NSUInteger index = 0;
            NSUInteger childIndex = [parentAsTabBar.items indexOfObject:childAsTabBarItem];
            
            for (UIView* subview in parentAsTabBar.subviews) {
                if ([subview isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
                    if (index == childIndex) {
                        control = (UIControl*) subview;
                        break;
                    }
                    
                    ++index;
                }
            }
            
            // End Block
            ////////////////////////////////////////////////////////////////////////////////
            
            if (control) {
                elementRect = [control convertRect:control.bounds toView:self.overlayView];
            }
        }
        else if ([parent isKindOfClass:[UISegmentedControl class]] && [child isKindOfClass:[NSNumber class]]) {
            UISegmentedControl* parentAsSegmentedControl = (UISegmentedControl*) parent;
            
            NSUInteger numSegments = [parentAsSegmentedControl numberOfSegments];
            NSMutableArray* segmentWidths = [[NSMutableArray alloc] initWithCapacity:numSegments];
            
            NSUInteger numAutosizedSegments = 0;
            CGFloat availableWidthToAutosizing = CGRectGetWidth(parentAsSegmentedControl.bounds);
            
            // Populate the width info for any fixed width segments. Gather information about autosized segments if present.
            for (NSUInteger segmentIndex = 0; segmentIndex < numSegments; ++segmentIndex) {
                CGFloat segmentWidth = [parentAsSegmentedControl widthForSegmentAtIndex:segmentIndex];
                
                if (segmentWidth < FLT_EPSILON) {
                    ++numAutosizedSegments;
                }
                else {
                    availableWidthToAutosizing -= segmentWidth;
                }
                
                [segmentWidths addObject:@(segmentWidth)];
            }
            
            // Need to populate the info for autosized segments
            if (numAutosizedSegments > 0) {
                CGFloat autosizedSegmentWidth = availableWidthToAutosizing / (CGFloat)numAutosizedSegments;
                
                for (NSUInteger segmentIndex = 0; segmentIndex < numSegments; ++segmentIndex) {
                    if ([segmentWidths[segmentIndex] floatValue] < FLT_EPSILON) {
                        segmentWidths[segmentIndex] = @(autosizedSegmentWidth);
                    }
                }
            }
            
            NSUInteger segmentIndex = [((NSNumber*)child) integerValue];
            
            // If the segment is valid generate the rect
            if (segmentIndex < numSegments) {
                CGFloat segmentWidth = [segmentWidths[segmentIndex] floatValue];
                
                // Calculate the offset by summing the previous widths
                CGFloat segmentOffset = 0;
                for (NSUInteger index = 0; index < segmentIndex; ++index) {
                    segmentOffset += [segmentWidths[index] floatValue];
                }
                
                CGRect segmentRect = CGRectMake(segmentOffset, 0, segmentWidth, CGRectGetHeight(parentAsSegmentedControl.bounds));
                elementRect = [parentAsSegmentedControl convertRect:segmentRect toView:self.overlayView];
            }
        }
        else if ([parent isKindOfClass:[UIView class]] && [child isKindOfClass:[UIView class]]) {
            UIView* parentAsView = (UIView*) parent;
            UIView* childAsView = (UIView*) child;
            
            CGRect parentRect = [parentAsView convertRect:parentAsView.bounds toView:self.overlayView];
            CGRect childRect = [childAsView convertRect:childAsView.bounds toView:self.overlayView];
            
            elementRect = CGRectUnion(parentRect, childRect);
        }
    }
    
    return elementRect;
}

- (NSUInteger) numElements {
    return [self.elements count];
}

- (CGRect) rectForElement:(NSUInteger)elementIndex {
    return [((self.elementsMetadata[elementIndex])[kICLTrainingOverlay_ElementRect]) CGRectValue];
}

- (UIColor*) colourForElement:(NSUInteger)elementIndex {
    return (self.elementsMetadata[elementIndex])[kICLTrainingOverlay_ElementColour];
}

- (NSString*) descriptionForElement:(NSUInteger) elementIndex {
    return (self.elements[elementIndex])[kICLTrainingOverlay_ElementDescription];
}

@end
