//
//  CADRACSwippeableCell.h
//  CADRACSwippeableCell
//
//  Created by Joan Romano on 18/02/14.
//  Copyright (c) 2014 Crows And Dogs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACSignal;

typedef NS_ENUM(NSUInteger, CADRACSwippeableCellAllowedDirection) {
    CADRACSwippeableCellAllowedDirectionLeft,
    CADRACSwippeableCellAllowedDirectionRight
};

@interface CADRACSwippeableCell : UICollectionViewCell

@property (nonatomic, strong, readonly) RACSignal *revealViewSignal;
@property (nonatomic, strong) UIView *revealView;
@property (nonatomic) CADRACSwippeableCellAllowedDirection allowedDirection;

- (void)hideRevealViewAnimated:(BOOL)animated;
- (void)showRevealViewAnimated:(BOOL)animated;

@end
