//
// SVPullToRefresh.m
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <QuartzCore/QuartzCore.h>
#import "SVPullToRefresh.h"

enum {
    SVPullToRefreshStateHidden = 1,
	SVPullToRefreshStateVisible,
    SVPullToRefreshStateTriggered,
    SVPullToRefreshStateLoading
};

typedef NSUInteger SVPullToRefreshState;


@interface SVPullToRefresh ()

- (id)initWithScrollView:(UIScrollView*)scrollView;
- (void)rotateArrow:(float)degrees hide:(BOOL)hide;
- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset;
- (void)scrollViewDidScroll:(CGPoint)contentOffset;

@property (nonatomic, copy) void (^actionHandler)(void);
@property (nonatomic, readwrite) SVPullToRefreshState state;
@property (nonatomic, retain) UILabel *lastUpdatedLabel;
@property (nonatomic, retain) UIImageView *arrow;
@property (nonatomic, retain, readonly) UIImage *arrowImage;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UILabel *titleLabel;

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, readwrite) UIEdgeInsets originalScrollViewContentInset;

@end


@implementation SVPullToRefresh

// public properties
@synthesize actionHandler, arrowColor, textColor, activityIndicatorViewStyle;

@synthesize state;
@synthesize scrollView = _scrollView;
@synthesize arrow, lastUpdatedLabel, arrowImage, activityIndicatorView, titleLabel, originalScrollViewContentInset;

- (id)initWithScrollView:(UIScrollView *)scrollView {
    self = [super initWithFrame:CGRectZero];
    self.scrollView = scrollView;
    [_scrollView addSubview:self];
    
    self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(ceil(self.superview.bounds.size.width*0.36+70), 20, 180, 20)]autorelease];
    titleLabel.text = NSLocalizedString(@"拖曳以更新...",);
    titleLabel.font = [UIFont boldSystemFontOfSize:12];
    titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:titleLabel];
    
    self.lastUpdatedLabel = [[[UILabel alloc] initWithFrame:CGRectMake(ceil(self.superview.bounds.size.width*0.36+10), 40, 180, 20)]autorelease];
    lastUpdatedLabel.adjustsFontSizeToFitWidth = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *timeStr = [defaults objectForKey:@"time"];
    if (timeStr) {
        lastUpdatedLabel.text = [NSString stringWithFormat:@"上次更新时间:%@",timeStr];
    }else {
        lastUpdatedLabel.text = @"上次更新时间:0000-00-00 00:00:00";
    }
    
    lastUpdatedLabel.font = [UIFont boldSystemFontOfSize:12];
    lastUpdatedLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:lastUpdatedLabel];

    // default styling values
    self.arrowColor = [UIColor grayColor];
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.lastUpdatedLabel.textColor = [UIColor darkGrayColor];
    
    [self addSubview:self.arrow];
    
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    self.originalScrollViewContentInset = scrollView.contentInset;
    
    self.state = SVPullToRefreshStateHidden;    
    self.frame = CGRectMake(0, -60, scrollView.bounds.size.width, 60);

    return self;
}


#pragma mark - Getters

- (UIImageView *)arrow {
    if(!arrow) {
        arrow = [[UIImageView alloc] initWithImage:self.arrowImage];
        arrow.frame = CGRectMake(ceil(self.superview.bounds.size.width*0.36-30), 12, 22, 48);
        arrow.backgroundColor = [UIColor clearColor];
    }
    return arrow;
}

- (UIImage *)arrowImage {
    CGRect rect = CGRectMake(0, 0, 22, 48);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] set];
    CGContextFillRect(context, rect);
    
    [self.arrowColor set];
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, [[UIImage imageNamed:@"SVPullToRefresh.bundle/arrow"] CGImage]);
    CGContextFillRect(context, rect);
    
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if(!activityIndicatorView) {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:activityIndicatorView];
        self.activityIndicatorView.center = self.arrow.center;
    }
    return activityIndicatorView;
}

#pragma mark - Setters

- (void)setArrowColor:(UIColor *)newArrowColor {
    arrowColor = newArrowColor;
    self.arrow.image = self.arrowImage;
}

- (void)setTextColor:(UIColor *)newTextColor {
    self.titleLabel.textColor = newTextColor;
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)viewStyle {
    self.activityIndicatorView.activityIndicatorViewStyle = viewStyle;
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.scrollView.contentInset = contentInset;
    } completion:NULL];
}


#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {    
    CGFloat scrollOffsetThreshold = self.frame.origin.y-self.originalScrollViewContentInset.top;
    
    if(!self.scrollView.isDragging && self.state == SVPullToRefreshStateTriggered)
        self.state = SVPullToRefreshStateLoading;
    else if(contentOffset.y > scrollOffsetThreshold && contentOffset.y < -self.originalScrollViewContentInset.top && self.scrollView.isDragging && self.state != SVPullToRefreshStateLoading)
        self.state = SVPullToRefreshStateVisible;
    else if(contentOffset.y < scrollOffsetThreshold && self.scrollView.isDragging && self.state == SVPullToRefreshStateVisible)
        self.state = SVPullToRefreshStateTriggered;
    else if(contentOffset.y >= -self.originalScrollViewContentInset.top && self.state != SVPullToRefreshStateHidden)
        self.state = SVPullToRefreshStateHidden;
}

- (void)stopAnimating {

    self.state = SVPullToRefreshStateHidden;
}

- (void)setState:(SVPullToRefreshState)newState {
    state = newState;
    
    switch (newState) {
        case SVPullToRefreshStateHidden:
            titleLabel.text = NSLocalizedString(@"拖曳以更新...",);
            [self.activityIndicatorView stopAnimating];
            [self setScrollViewContentInset:self.originalScrollViewContentInset];
            [self rotateArrow:0 hide:YES];
            break;
            
        case SVPullToRefreshStateVisible:
            titleLabel.text = NSLocalizedString(@"拖曳以更新...",);
            [self.activityIndicatorView stopAnimating];
            [self setScrollViewContentInset:self.originalScrollViewContentInset];
            [self rotateArrow:0 hide:NO];
            break;
            
        case SVPullToRefreshStateTriggered:
            titleLabel.text = NSLocalizedString(@"释放以更新...",);
            [self rotateArrow:M_PI hide:NO];
            break;
            
        case SVPullToRefreshStateLoading:
            titleLabel.text = NSLocalizedString(@"更新中...",);
            [self.activityIndicatorView startAnimating];
            
            [self setScrollViewContentInset:UIEdgeInsetsMake(self.frame.origin.y*-1+self.originalScrollViewContentInset.top, 0, 0, 0)];
            [self rotateArrow:0 hide:YES];
            if(actionHandler)
                actionHandler();
            
            // UI 更新日期计算
            NSDate *localeDate = [NSDate date];

            NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
            [outFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *timeStr = [outFormat stringFromDate:localeDate];
            [outFormat release];
            // UI 赋值
            lastUpdatedLabel.text = [NSString stringWithFormat:@"上次更新时间:%@",timeStr];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:timeStr forKey:@"time"];
            [defaults synchronize];
            break;
    }
}

- (void)rotateArrow:(float)degrees hide:(BOOL)hide {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.arrow.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
        self.arrow.layer.opacity = !hide;
    } completion:NULL];
}

@end


#pragma mark - UIScrollView (SVPullToRefresh)
#import <objc/runtime.h>

static char UIScrollViewPullToRefreshView;

@implementation UIScrollView (SVPullToRefresh)

@dynamic pullToRefreshView;

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler {
    SVPullToRefresh *pullToRefreshView = [[[SVPullToRefresh alloc] initWithScrollView:self]autorelease];
    pullToRefreshView.actionHandler = actionHandler;
    self.pullToRefreshView = pullToRefreshView;
}

- (void)setPullToRefreshView:(SVPullToRefresh *)pullToRefreshView {
    [self willChangeValueForKey:@"pullToRefreshView"];
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView,
                             pullToRefreshView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"pullToRefreshView"];
}

- (SVPullToRefresh *)pullToRefreshView {
    return objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
}

@end
