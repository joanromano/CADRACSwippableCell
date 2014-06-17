//
//  UIColor+CADRACSwippableCellAdditions.h
//  Pods
//
//  Created by Joan Romano on 17/06/14.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (CADRACSwippableCellAdditions)

- (BOOL)isEqualToColor:(UIColor *)otherColor;
+ (UIColor *)firstNonClearBackgroundColorInHierarchyForView:(UIView *)view;

@end
