//
//  CADRACSwippableCell.h
//  CADRACSwippableCell
//
//  Created by Joan Romano on 18/02/14.
//  Copyright (c) 2014 Crows And Dogs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACSignal;

typedef NS_ENUM(NSUInteger, CADRACSwippableCellAllowedDirection) {
    CADRACSwippableCellAllowedDirectionLeft,
    CADRACSwippableCellAllowedDirectionRight
};

@interface CADRACSwippableCell : UICollectionViewCell

/** 
 Signal which sends next: events with @(YES)/@(NO) values each time the reveal view is shown/hidden.
 */
@property (nonatomic, strong, readonly) RACSignal *revealViewSignal;

/**
 The view beneath the cell that will be shown. You should provide this view if you want your cell to be swippable.
 */
@property (nonatomic, strong) UIView *revealView;

/**
 The allowed swipe direction. Defaults to CADRACSwippableCellAllowedDirectionLeft.
 */
@property (nonatomic) CADRACSwippableCellAllowedDirection allowedDirection;

/**
 Explicitly hide the reveal view.
 
 @param animated YES if you want the action to be animated, NO otherwise
 */
- (void)hideRevealViewAnimated:(BOOL)animated;

/**
 Explicitly show the reveal view.
 
 @param animated YES if you want the action to be animated, NO otherwise
 */
- (void)showRevealViewAnimated:(BOOL)animated;

@end
