//
//  UIColor+CADRACSwippableCellAdditions.m
//  Pods
//
//  Created by Joan Romano on 17/06/14.
//
//

#import "UIColor+CADRACSwippableCellAdditions.h"

@implementation UIColor (CADRACSwippableCellAdditions)

+ (UIColor *)firstNonClearBackgroundColorInHierarchyForView:(UIView *)view
{
	UIView *superview = view;
	UIColor *color = view.backgroundColor;
    
	while (superview != nil && [color isEqualToColor:[UIColor clearColor]])
    {
		superview = [superview superview];
        color = superview.backgroundColor;
	}
    
	return color;
}

- (BOOL)isEqualToColor:(UIColor *)otherColor
{
    CGColorSpaceRef colorSpaceRGB = CGColorSpaceCreateDeviceRGB();
    
    UIColor *(^convertColorToRGBSpace)(UIColor*) = ^(UIColor *color) {
        if(CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome)
        {
            const CGFloat *oldComponents = CGColorGetComponents(color.CGColor);
            CGFloat components[4] = {oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1]};
            return [UIColor colorWithCGColor:CGColorCreate(colorSpaceRGB, components)];
        } else
            return color;
    };
    
    UIColor *selfColor = convertColorToRGBSpace(self);
    otherColor = convertColorToRGBSpace(otherColor);
    CGColorSpaceRelease(colorSpaceRGB);
    
    return [selfColor isEqual:otherColor];
}

@end
