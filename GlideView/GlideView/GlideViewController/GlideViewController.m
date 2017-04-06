//
//  GlideViewController.m
//  GlideView
//
//  Created by GuillermoD on 8/4/16.
//  Copyright © 2017. All rights reserved.
//

#import "GlideViewController.h"

NSString *const GVException = @"GliveViewException";

@interface GlideViewController () <UIScrollViewDelegate>

@property (nonatomic) GVScrollView *scrollView;

@property (nonatomic) BOOL isObservingOffsets;

@end

@implementation GlideViewController

- (instancetype)initOnViewController:(UIViewController *)viewController {
    if (self = [super init]) {

        [viewController addChildViewController:self];

        self.scrollView = [[GVScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewController.view.frame), CGRectGetHeight(viewController.view.frame))];
        [viewController.view addSubview:self.scrollView];
    }
    
    return self;
}

- (NSArray<NSNumber *> *)offsets {
    if (self.scrollView) {
        return self.scrollView.offsets;
    }
    
    return nil;
}

- (void)setOffsets:(NSArray<NSNumber *> *)offsets {
    if (self.scrollView) {
        [self.scrollView setOffsets:offsets];
    }
}

- (NSUInteger)currentOffsetIndex {
    if (self.scrollView) {
        return self.scrollView.offsetIndex;
    }

    return 0;
}

- (GVScrollViewOrientationType)orientationType {
    if (self.scrollView) {
        return self.scrollView.orientationType;
    }
    
    return 0;
}

- (void)setMarginOffset:(CGFloat)marginOffset {
    [self.scrollView setMargin:marginOffset];
}

- (CGFloat)marginOffset {
    if (!self.scrollView) {
        return 0.0f;
    }
    
    return [self.scrollView margin];
}

#pragma mark - Public methods

- (void)setContentViewController:(UIViewController *)contentViewController
                            type:(GVScrollViewOrientationType)type
                         offsets:(NSArray<NSNumber *> *)offsets {
    
    if (!contentViewController) {
        @throw [NSException exceptionWithName:GVException
                                       reason:@"Invalid contentViewController - ViewController cannot be nil"
                                     userInfo:nil];
    }
    
    if (self.scrollView && !CGRectIsNull(self.scrollView.frame)) {
        
        [self.scrollView setOrientationType:type];
        [self.scrollView setOffsets:offsets];
        
        self.contentViewController = contentViewController;
        [self.scrollView setContent:self.contentViewController.view];
 
        self.scrollView.delegate = self;
        
        [self setCanCloseDragging:YES];
    }
}

- (void)shake {
    
    CGFloat shakeMargin = 10.0f;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:2];
    [animation setAutoreverses:YES];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    if (self.orientationType == GVScrollViewOrientationRightToLeft ||
        self.orientationType == GVScrollViewOrientationLeftToRight) {
        [animation setFromValue:[NSValue valueWithCGPoint: CGPointMake([self.scrollView center].x,
                                                                       [self.scrollView  center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint: CGPointMake([self.scrollView  center].x + shakeMargin,
                                                                     [self.scrollView  center].y)]];
        
    } else if (self.orientationType == GVScrollViewOrientationBottomToTop ||
               self.orientationType == GVScrollViewOrientationTopToBottom) {
        [animation setFromValue:[NSValue valueWithCGPoint: CGPointMake([self.scrollView center].x,
                                                                       [self.scrollView  center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint: CGPointMake([self.scrollView  center].x,
                                                                     [self.scrollView  center].y + shakeMargin)]];
    }

    [[self.scrollView layer] addAnimation:animation forKey:@"position"];
}

- (void)expand {
    if ([self.delegate respondsToSelector:@selector(glideViewControllerWillExpand:)]) {
        [self.delegate glideViewControllerWillExpand:self];
    }
    
    [self.scrollView expandWithCompletion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(glideViewControllerDidExpand:)]) {
            [self.delegate glideViewControllerDidExpand:self];
        }
    }];
}

- (void)collapse {
    if ([self.delegate respondsToSelector:@selector(glideViewControllerWillCollapse:)]) {
        [self.delegate glideViewControllerWillCollapse:self];
    }
    
    [self.scrollView collapseWithCompletion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(glideViewControllerDidCollapse:)]) {
            [self.delegate glideViewControllerDidCollapse:self];
        }
    }];
}

- (void)changeOffsetTo:(NSUInteger)offsetIndex {
    if (offsetIndex > self.scrollView.offsetIndex) {
        if ([self.delegate respondsToSelector:@selector(glideViewControllerWillExpand:)]) {
            [self.delegate glideViewControllerWillExpand:self];
        }
        
        [self.scrollView changeOffsetTo:offsetIndex animated:NO completion:^(BOOL finished) {

            if ([self.delegate respondsToSelector:@selector(glideViewControllerDidExpand:)]) {
                [self.delegate glideViewControllerDidExpand:self];
            }
        }];
    } else if (offsetIndex < self.scrollView.offsetIndex) {
        if ([self.delegate respondsToSelector:@selector(glideViewControllerWillCollapse:)]) {
            [self.delegate glideViewControllerWillCollapse:self];
        }
        
        [self.scrollView changeOffsetTo:offsetIndex animated:NO completion:^(BOOL finished) {

            if ([self.delegate respondsToSelector:@selector(glideViewControllerDidCollapse:)]) {
                [self.delegate glideViewControllerDidCollapse:self];
            }
        }];
    } else {
        [self.scrollView changeOffsetTo:self.currentOffsetIndex
                               animated:NO
                             completion:nil];
    }
}

- (void)close {
    if ([self.delegate respondsToSelector:@selector(glideViewControllerWillCollapse:)]) {
        [self.delegate glideViewControllerWillCollapse:self];
    }
    
    [self.scrollView closeWithCompletion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(glideViewControllerDidCollapse:)]) {
            [self.delegate glideViewControllerDidCollapse:self];
        }
    }];
}

- (BOOL)isOpen {
    return self.scrollView.isOpen;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat max = [[self offsets] lastObject].floatValue;
    
    if (self.orientationType == GVScrollViewOrientationLeftToRight ||
        self.orientationType == GVScrollViewOrientationRightToLeft) {
        max *= CGRectGetWidth(self.scrollView.frame);
    }
    else {
        max *= CGRectGetHeight(self.scrollView.frame);
    }

    if (self.orientationType == GVScrollViewOrientationTopToBottom ||
        self.orientationType == GVScrollViewOrientationLeftToRight) {
        max -= [self marginOffset];
    } else {
        max += [self marginOffset];
    }
    
    if ([self.delegate respondsToSelector:@selector(glideViewController:hasChangedOffsetOfContent:)]) {
        [self.delegate glideViewController:self hasChangedOffsetOfContent:scrollView.contentOffset];
    }
    
    if (self.orientationType == GVScrollViewOrientationRightToLeft &&
        scrollView.contentOffset.x >= max) {
        [scrollView setContentOffset:CGPointMake(max, scrollView.contentOffset.y) animated:NO];
    }
    else if (self.orientationType == GVScrollViewOrientationLeftToRight &&
               scrollView.contentOffset.x <= max) {
        [scrollView setContentOffset:CGPointMake(max, scrollView.contentOffset.y) animated:NO];
    }
    else if (self.orientationType == GVScrollViewOrientationBottomToTop &&
             scrollView.contentOffset.y >= max) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, max) animated:NO];
    }
    else if (self.orientationType == GVScrollViewOrientationTopToBottom &&
             scrollView.contentOffset.y <= max) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, max) animated:NO];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    NSUInteger index = 0;
    CGFloat offset = self.scrollView.contentOffset.x;
    CGFloat threshold = CGRectGetWidth(self.scrollView.content.frame);

    if (self.scrollView.orientationType == GVScrollViewOrientationBottomToTop ||
        self.scrollView.orientationType == GVScrollViewOrientationTopToBottom) {
        offset = self.scrollView.contentOffset.y;
        threshold = CGRectGetHeight(self.scrollView.content.frame);
    }
    
    for (int i = 0 ; i < [self.offsets count] ; i++) {
        CGFloat transformedOffset = [[self.scrollView offsets] objectAtIndex:i].floatValue * threshold;
        if (offset > transformedOffset) {
            index = i;
        }
    }
    
    [self changeOffsetTo:(index == 0 && !self.canCloseDragging) ? 1 : index];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [self.scrollView setContentOffset:self.scrollView.contentOffset animated:NO];
}

#pragma mark - Rotation event

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (self.contentViewController) {
        [self.contentViewController viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    }
    
    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
        [self.scrollView changeOffsetTo:self.currentOffsetIndex
                               animated:YES
                             completion:nil];
    } completion:nil];
}

@end
