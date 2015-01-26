//
//  UIView+CADRACSwippableCellAdditions.m
//  Pods
//
//  Created by Joan Romano on 17/06/14.
//
//

#import "UIView+CADRACSwippableCellAdditions.h"

@implementation UIView (CADRACSwippableCellAdditions)

- (UICollectionView *)superCollectionView
{
	UIView *superview = self.superview;
    
	while (superview != nil)
    {
		if ([superview isKindOfClass:[UICollectionView class]])
        {
			return (id)superview;
		}
        
		superview = [superview superview];
	}
    
	return nil;
}

@end
