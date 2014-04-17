//
//  CADRACSwippableCell.m
//  CADRACSwippableCell
//
//  Created by Joan Romano on 18/02/14.
//  Copyright (c) 2014 Crows And Dogs. All rights reserved.
//

#import "CADRACSwippableCell.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CADRACSwippableCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) RACSubject *revealViewSignal;
@property (nonatomic, strong) UIView *contentSnapshotView;

@end

@implementation CADRACSwippableCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        [self setupView];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupView];
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (void)setupView
{
    self.revealViewSignal = [RACSubject subject];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    panGesture.delegate = self;
    
    RACSignal *gestureSignal = [panGesture rac_gestureSignal],
              *beganOrChangedSignal = [gestureSignal filter:^BOOL(UIGestureRecognizer *gesture) {
        return gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateBegan;
    }],
              *endedOrCancelledSignal = [gestureSignal filter:^BOOL(UIGestureRecognizer *gesture) {
        return gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled;
    }];
    
    RAC(self, contentSnapshotView.center) = [beganOrChangedSignal map:^id(id value) {
        return [NSValue valueWithCGPoint:[self centerPointForTranslation:[panGesture translationInView:self]]];
    }];
    
    [beganOrChangedSignal subscribeNext:^(UIPanGestureRecognizer *panGesture) {
        [self.contentView addSubview:self.revealView];
        [self.contentView addSubview:self.contentSnapshotView];
        
        [panGesture setTranslation:CGPointZero inView:self];
    }];
    
    [[endedOrCancelledSignal filter:^BOOL(UIPanGestureRecognizer *gestureRecognizer) {
        return fabsf(CGRectGetMinX(self.contentSnapshotView.frame)) >= CGRectGetWidth(self.revealView.frame)/2 ||
               [self shouldShowRevealViewForVelocity:[gestureRecognizer velocityInView:self]];
    }] subscribeNext:^(id x) {
        [self showRevealViewAnimated:YES];
    }];
    
    [[endedOrCancelledSignal filter:^BOOL(UIPanGestureRecognizer *gestureRecognizer) {
        return fabsf(CGRectGetMinX(self.contentSnapshotView.frame)) < CGRectGetWidth(self.revealView.frame)/2 ||
               [self shouldHideRevealViewForVelocity:[gestureRecognizer velocityInView:self]];
    }] subscribeNext:^(id x) {
        [self hideRevealViewAnimated:YES];
    }];
    
    [[RACSignal merge:@[RACObserve(self, allowedDirection), RACObserve(self, revealView)]] subscribeNext:^(id x) {
        [self setNeedsLayout];
    }];
    
    [[self rac_prepareForReuseSignal] subscribeNext:^(id x) {
        [self.contentSnapshotView removeFromSuperview];
        self.contentSnapshotView = nil;
        
        [self.revealView removeFromSuperview];
        self.revealView = nil;
    }];
    
    [[[self rac_signalForSelector:@selector(updateConstraints)] filter:^BOOL(id value) {
        return _contentSnapshotView != nil;
    }] subscribeNext:^(id x) {
        [self.contentSnapshotView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentSnapshotView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentSnapshotView)]];
        [self.contentSnapshotView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentSnapshotView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentSnapshotView)]];
        
        [super updateConstraints];
    }];
    
    [self addGestureRecognizer:panGesture];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.revealView.frame = (CGRect){
        .origin = CGPointMake(self.allowedDirection == CADRACSwippableCellAllowedDirectionRight ? 0.0f : CGRectGetWidth(self.frame) - CGRectGetWidth(self.revealView.frame), 0.0f),
        .size = self.revealView.frame.size
    };
}

#pragma mark - Public

- (void)showRevealViewAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.1 : 0.0
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.contentSnapshotView.center = CGPointMake(
                            self.allowedDirection == CADRACSwippableCellAllowedDirectionRight ?
                               CGRectGetWidth(self.frame)/2 + CGRectGetWidth(self.revealView.frame) :
                               CGRectGetWidth(self.frame)/2 - CGRectGetWidth(self.revealView.frame),
                             self.contentSnapshotView.center.y);
                     }
                     completion:^(BOOL finished) {
                         [(RACSubject *)self.revealViewSignal sendNext:@(YES)];
                     }];
}

- (void)hideRevealViewAnimated:(BOOL)animated
{
    if (CGPointEqualToPoint(self.contentSnapshotView.center, self.contentView.center))
        return;
    
    [UIView animateWithDuration:animated ? 0.1 : 0.0
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.contentSnapshotView.center = CGPointMake(CGRectGetWidth(self.frame)/2, self.contentSnapshotView.center.y);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:animated ? 0.1 : 0.0
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              self.contentSnapshotView.center = CGPointMake(self.allowedDirection == CADRACSwippableCellAllowedDirectionRight ? self.center.x+2.0f : self.center.x-2.0f, self.contentSnapshotView.center.y);
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:animated ? 0.1 : 0.0
                                                                    delay:0.0f
                                                                  options:UIViewAnimationOptionCurveLinear
                                                               animations:^{
                                                                   self.contentSnapshotView.center = CGPointMake(CGRectGetWidth(self.frame)/2, self.contentSnapshotView.center.y);
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [(RACSubject *)self.revealViewSignal sendNext:@(NO)];
                                                               }];
                                          }];
                     }];
}

#pragma mark - Private

- (BOOL)shouldShowRevealViewForVelocity:(CGPoint)velocity
{
    BOOL shouldShow = NO,
         velocityIsBiggerThanOffset = fabsf(velocity.x) > CGRectGetWidth(self.revealView.frame)/2;
    
    switch (self.allowedDirection)
    {
        case CADRACSwippableCellAllowedDirectionLeft:
            shouldShow = velocity.x < 0 && velocityIsBiggerThanOffset;
            break;

        case CADRACSwippableCellAllowedDirectionRight:
            shouldShow = velocity.x > 0 && velocityIsBiggerThanOffset;
            break;
    }
    
    return shouldShow;
}

- (BOOL)shouldHideRevealViewForVelocity:(CGPoint)velocity
{
    BOOL shouldHide = NO,
         velocityIsBiggerThanOffset = fabsf(velocity.x) > CGRectGetWidth(self.revealView.frame)/2;
    
    switch (self.allowedDirection)
    {
        case CADRACSwippableCellAllowedDirectionLeft:
            shouldHide = velocity.x > 0 && velocityIsBiggerThanOffset;
            break;
            
        case CADRACSwippableCellAllowedDirectionRight:
            shouldHide = velocity.x < 0 && velocityIsBiggerThanOffset;
            break;
    }
    
    return shouldHide;
}

- (CGPoint)centerPointForTranslation:(CGPoint)translation
{
    CGPoint centerPoint = CGPointMake(0.0f, self.contentSnapshotView.center.y);
    
    switch (self.allowedDirection)
    {
        case CADRACSwippableCellAllowedDirectionRight:
            centerPoint.x = MAX(CGRectGetWidth(self.frame)/2, MIN(self.contentSnapshotView.center.x + translation.x,
                                                                  CGRectGetWidth(self.revealView.frame) + CGRectGetWidth(self.frame)/2));
            break;
        case CADRACSwippableCellAllowedDirectionLeft:
            centerPoint.x = MIN(CGRectGetWidth(self.frame)/2, MAX(self.contentSnapshotView.center.x + translation.x,
                                                                  CGRectGetWidth(self.frame)/2 - CGRectGetWidth(self.revealView.frame)));
            break;
    }
    
    return centerPoint;
}

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

#pragma mark - UIGestureRecognizer Delegate

// Would be awesome to do this with RAC
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]])
    {
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [gesture velocityInView:self];
        
        if (fabsf(point.x) > fabsf(point.y))
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return otherGestureRecognizer != [self superCollectionView].panGestureRecognizer;
}

#pragma mark - Lazy

- (UIView *)contentSnapshotView
{
    if (!_contentSnapshotView)
    {
        _contentSnapshotView = [self snapshotViewAfterScreenUpdates:NO];
        _contentSnapshotView.backgroundColor = self.backgroundColor;
    }
    
    return _contentSnapshotView;
}

@end
