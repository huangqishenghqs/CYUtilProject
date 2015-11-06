//
//  CYAlertView.m
//  CYUtilProject
//
//  Created by HuangQiSheng on 10/15/15.
//  Copyright © 2015 Charry. All rights reserved.
//

#import "CYAlertView.h"

#define CY_ALERT_VIEW_MESSAGE_MAX_HEIGHT   200
#define CY_ALERT_VIEW_CONTENT_BODER_GAP    15
#define CY_ALERT_VIEW_CONTENT_BETWEEN_GAP  15
#define CY_ALERT_VIEW_ACTION_VIEW_HEIGHT    44
#define CY_ALERT_VIEW_ACTION_SEPARATOR_COLOR ([UIColor colorWithRed:200/255.f green:200/255.f blue:200/255.f alpha:1.f].CGColor)
//#define CY_ALERT_VIEW_ACTION_SEPARATOR_COLOR ([UIColor greenColor].CGColor)

typedef NS_ENUM(NSInteger, CYAlertViewActionViewsLayout) {
    
    CYAlertViewActionViewsLayoutVertical,
    CYAlertViewActionViewsLayoutHerizontal
};

@interface CYAlertView ()

@property (nonatomic, assign) CYAlertViewStyle style;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *messageTextView;

@property (nonatomic, strong) UIView *cancelActionView;
@property (nonatomic, strong) CYAlertViewAction *cancelAction;

//@property (nonatomic, strong) UIView *customContentView;
@property (nonatomic, strong) NSMutableArray *customMessageViews;

@property (nonatomic, strong) NSMutableArray *actionButtons;
@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, strong) UIWindow *showingWindow;
@property (nonatomic, weak) UIWindow *originKeyWindow;

@property (nonatomic, assign, readonly) CYAlertViewActionViewsLayout actionLayout;
@property (nonatomic, assign, readonly) NSInteger numberOfActions;

@end

@implementation CYAlertView

- (void)dealloc {
    
    [alertShowingWindowTap removeTarget:self action:@selector(alertTapped:)];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     delegate:(id)delegate
                  cancelTitle:(NSString *)cancelTitle
                        style:(CYAlertViewStyle)style {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        _title = title;
        _message = message;
        _cancelTitle = cancelTitle;
        
        _style = style;
        
        [self createSubViews];
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.98];
        self.layer.cornerRadius = 10.f;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)createSubViews {
    
    if (_title) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = _title;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    if (_message) {
        
        _messageTextView = [[UITextView alloc] init];
        _messageTextView.font = [UIFont systemFontOfSize:14.f];
        _messageTextView.textColor = [UIColor darkGrayColor];
        _messageTextView.backgroundColor = [UIColor clearColor];
        _messageTextView.text = _message;
        _messageTextView.editable = NO;
        _messageTextView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_messageTextView];
    }
    if (_cancelTitle
        && ![_cancelTitle isEqualToString:@""]) {
        
        __weak CYAlertView *weakSelf = self;
        _cancelAction = [[CYAlertViewAction alloc] initWithTitle:_cancelTitle
                                                         handler:^(CYAlertViewAction *action) {
                                                             
                                                             [weakSelf dismiss];
                                                         }];
        _cancelActionView = _cancelAction.actionView;
        [self addSubview:_cancelActionView];
    }
}

- (CYAlertViewActionViewsLayout)actionLayout {
    
    if (self.numberOfActions <= 2) {
        
        return CYAlertViewActionViewsLayoutHerizontal;
    } else {
        
        return CYAlertViewActionViewsLayoutVertical;
    }
}

- (NSInteger)numberOfActions {
    
    NSInteger numberOfActions = [_actions count];
    if (_cancelAction) {
        
        numberOfActions++;
    }
    return numberOfActions;
}

#pragma mark - custom alert
- (void)addCustomMessageView:(UIView *)view {
    
    if (!view) {
        return;
    }
    if (!_customMessageViews) {
        
        _customMessageViews = [NSMutableArray array];
    }
    [self addSubview:view];
    [_customMessageViews addObject:view];
}

- (void)addAction:(CYAlertViewAction *)action {
    
    if (!action) {
        
        return;
    }
    if (!_actions) {
        
        _actions = [NSMutableArray array];
    }
    if (!_actionButtons) {
        
        _actionButtons = [NSMutableArray array];
    }
    action.alertView = self;
    [_actions addObject:action];
    [_actionButtons addObject:action.actionView];
    
    [self addSubview:action.actionView];
}

#pragma mark - layout content views
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_style == CYAlertViewStyleAlert) {
        
        [self layoutAlert];
    }
}

- (void)layoutAlert {
    
    CGFloat selfWidth = 280;
    CGFloat contentWidth = selfWidth - CY_ALERT_VIEW_CONTENT_BODER_GAP * 2;
    CGRect frame;
    __block CGFloat nextY = CY_ALERT_VIEW_CONTENT_BODER_GAP;
    if (_title
        && ![_title isEqualToString:@""]) {
        
        CGSize size = [_titleLabel sizeThatFits:CGSizeMake(contentWidth, 100)];
        frame.size = size;
        frame.origin.x = (selfWidth - size.width) / 2.f;
        frame.origin.y = nextY;
        _titleLabel.frame = frame;
        
        nextY = CGRectGetMaxY(_titleLabel.frame);
    }
    
    if (_message
        && ![_message isEqualToString:@""]) {
        
        CGSize size = [_messageTextView sizeThatFits:CGSizeMake(contentWidth, CY_ALERT_VIEW_MESSAGE_MAX_HEIGHT)];
        frame.size = size;
        frame.origin.x = (selfWidth - size.width) / 2.f;
        frame.origin.y = nextY;
        _messageTextView.frame = frame;
        
        nextY = CGRectGetMaxY(_messageTextView.frame) + 5;
    }
    
    if (_customMessageViews
        && [_customMessageViews count] > 0) {
        
        [_customMessageViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGRect frame = view.frame;
            frame.origin.x = (selfWidth - frame.size.width) / 2.f;
            frame.origin.y = nextY;
            view.frame = frame;
            
            nextY = CGRectGetMaxY(view.frame) + CY_ALERT_VIEW_CONTENT_BETWEEN_GAP;
        }];
    }
    
    if (self.numberOfActions > 0) {
        
        if (self.actionLayout == CYAlertViewActionViewsLayoutVertical) {
            
            // 按钮竖着布局
            [_actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CGRect frame;
                frame.origin.x = 0;
                frame.origin.y = nextY + 0.5;
                frame.size.width = selfWidth;
                frame.size.height = CY_ALERT_VIEW_ACTION_VIEW_HEIGHT - 0.5;
                button.frame = frame;
                
                nextY = CGRectGetMaxY(button.frame);
            }];
            if (_cancelActionView) {
                
                CGRect frame;
                frame.origin.x = 0;
                frame.origin.y = nextY + 0.5;
                frame.size.width = selfWidth;
                frame.size.height = CY_ALERT_VIEW_ACTION_VIEW_HEIGHT - 0.5;
                _cancelActionView.frame = frame;
                
                nextY = CGRectGetMaxY(_cancelActionView.frame);
            }
        } else {
            
            // 按钮水平布局
            __block CGFloat nextX = 0;
            CGFloat buttonWidth = selfWidth / self.numberOfActions;
            CGSize buttonSize = CGSizeMake(buttonWidth - 0.5, CY_ALERT_VIEW_ACTION_VIEW_HEIGHT);
            if (_cancelActionView) {
                
                CGRect frame;
                frame.origin.x = 0;
                frame.origin.y = nextY;
                if (!_actionButtons
                    || _actionButtons.count == 0) {
                    
                    frame.size = CGSizeMake(buttonWidth, CY_ALERT_VIEW_ACTION_VIEW_HEIGHT);
                } else {
                    
                    frame.size = buttonSize;
                }
                _cancelActionView.frame = frame;
                
                nextX = buttonWidth;
            }
            [_actionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CGRect frame;
                frame.origin.x = nextX;
                frame.origin.y = nextY;
                if (idx == (_actionButtons.count - 1)) {
                    
                    frame.size = CGSizeMake(buttonWidth, CY_ALERT_VIEW_ACTION_VIEW_HEIGHT);
                } else {
                    
                    frame.size = buttonSize;
                }
                button.frame = frame;
                
                nextX = CGRectGetMaxX(button.frame) + 0.5;
            }];
            nextY += 44;
        }
    } else {
        
        nextY += CY_ALERT_VIEW_CONTENT_BODER_GAP;
    }
    frame = CGRectMake(0, 0, 280, nextY);
    CGPoint center = self.center;
    self.frame = frame;
    self.center = center;
}

#pragma mark - draw separator
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    NSInteger numberOfActions = self.numberOfActions;
    if (numberOfActions > 0) {
        
        NSInteger leftSeparatorCount = numberOfActions;
        if (self.actionLayout == CYAlertViewActionViewsLayoutVertical) {
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(context, 0.5);
            CGContextSetStrokeColorWithColor(context, CY_ALERT_VIEW_ACTION_SEPARATOR_COLOR);
            while (leftSeparatorCount > 0) {
                
                CGFloat lineY = self.frame.size.height - CY_ALERT_VIEW_ACTION_VIEW_HEIGHT * leftSeparatorCount;
                CGContextMoveToPoint(context, 0, lineY);
                CGContextAddLineToPoint(context, self.frame.size.width, lineY);
                CGContextStrokePath(context);
                leftSeparatorCount--;
            }
        } else {
            
            // 最上面一条横线
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(context, 0.5);
            CGContextSetStrokeColorWithColor(context, CY_ALERT_VIEW_ACTION_SEPARATOR_COLOR);
            CGContextMoveToPoint(context, 0, self.frame.size.height - CY_ALERT_VIEW_ACTION_VIEW_HEIGHT - 0.5);
            CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height - CY_ALERT_VIEW_ACTION_VIEW_HEIGHT);
            CGContextStrokePath(context);
            
            // 按钮之间的分割线
            CGFloat actionWidth = self.frame.size.width / numberOfActions;
            leftSeparatorCount--;
            while (leftSeparatorCount > 0) {
                
                CGContextMoveToPoint(context, actionWidth * leftSeparatorCount, self.frame.size.height);
                CGContextAddLineToPoint(context, actionWidth * leftSeparatorCount, self.frame.size.height - CY_ALERT_VIEW_ACTION_VIEW_HEIGHT);
                CGContextStrokePath(context);
                leftSeparatorCount--;
            }
        }
    }
}

#pragma mark - show

static UIWindow *alertShowingWindow = nil;
static UITapGestureRecognizer *alertShowingWindowTap = nil;

- (void)show {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        
        alertShowingWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertShowingWindow.windowLevel = 10;
        [alertShowingWindow makeKeyAndVisible];
        
        alertShowingWindowTap = [[UITapGestureRecognizer alloc] init];
        [alertShowingWindow addGestureRecognizer:alertShowingWindowTap];
        
        [keyWindow makeKeyWindow];
    });
    
    [alertShowingWindowTap addTarget:self action:@selector(alertTapped:)];
    alertShowingWindow.backgroundColor = [UIColor clearColor];
    [alertShowingWindow addSubview:self];
    self.center = CGPointMake(alertShowingWindow.frame.size.width / 2.f, alertShowingWindow.frame.size.height / 2.f);
    self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         alertShowingWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
                         self.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         
                     }];
    
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    keyframeAnimation.values = @[ [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)],
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)] ];
    keyframeAnimation.duration = 0.3f;
    keyframeAnimation.removedOnCompletion = YES;
    keyframeAnimation.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:keyframeAnimation forKey:@"transform"];
    
    alertShowingWindow.hidden = NO;
}

- (void)dismiss {
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         
                         alertShowingWindow.alpha = 0;
                     } completion:^(BOOL finished) {
                         
                         alertShowingWindow.hidden = YES;
                         alertShowingWindow.alpha = 1;
                         [alertShowingWindowTap removeTarget:self action:@selector(alertTapped:)];
                         [self removeFromSuperview];
                     }];
}

#pragma mark - event
- (void)alertTapped:(id)sender {
    
    [self endEditing:YES];
}

@end
