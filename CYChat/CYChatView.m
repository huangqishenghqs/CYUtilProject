//
//  CYChatView.m
//  CYUtilProject
//
//  Created by HuangQiSheng on 10/20/15.
//  Copyright © 2015 Charry. All rights reserved.
//

#import "CYChatView.h"
#import "UIScrollView+CYUtils.h"

@interface CYChatView () <UIGestureRecognizerDelegate, CYChatInputContentViewDelegate>

@property (nonatomic, weak) NSLayoutConstraint *chatInputContentViewBottomConstraint;
@property (nonatomic, weak) NSLayoutConstraint *chatInputMorePositionConstraint;
@property (nonatomic, weak) NSLayoutConstraint *chatInputEmotionPositionConstraint;

@property (nonatomic, weak) UITapGestureRecognizer *tableTap;

@end

@implementation CYChatView

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self createChatViewSubviews];
        [self createConstraintsForChatView];
        self.backgroundColor = [UIColor whiteColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChangeFrame:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        [self createChatViewSubviews];
        [self createConstraintsForChatView];
        self.backgroundColor = [UIColor whiteColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChangeFrame:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    }
    return self;
}

- (void)createChatViewSubviews {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.scrollsToTop = YES;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:tableView];
    _tableView = tableView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTapped:)];
    tap.delegate = self;
    [tableView addGestureRecognizer:tap];
    _tableTap = tap;
    
    CYChatInputContentView *inputContent = [[CYChatInputContentView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 45)];
    inputContent.delegate = self;
    inputContent.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:inputContent];
    _chatInputContentView = inputContent;
    
    CYChatInputMorePadView *inputMore = [[CYChatInputMorePadView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 210)];
    inputMore.translatesAutoresizingMaskIntoConstraints = NO;
    inputMore.backgroundColor = [UIColor redColor];
    [self addSubview:inputMore];
    _chatInputMorePadView = inputMore;
    
    CYChatInputEmotionPadView *inputEmotion = [[CYChatInputEmotionPadView alloc] init];
    inputEmotion.translatesAutoresizingMaskIntoConstraints = NO;
    inputEmotion.backgroundColor = [UIColor greenColor];
    [self addSubview:inputEmotion];
    _chatInputEmotionPadView = inputEmotion;
}

- (void)createConstraintsForChatView {
    
    NSLayoutConstraint *inputMoreConstraintLeft = [NSLayoutConstraint constraintWithItem:_chatInputMorePadView
                                                                               attribute:NSLayoutAttributeLeft
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self
                                                                               attribute:NSLayoutAttributeLeft
                                                                              multiplier:1
                                                                                constant:0];
    NSLayoutConstraint *inputMoreConstraintRight = [NSLayoutConstraint constraintWithItem:_chatInputMorePadView
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1
                                                                                 constant:0];
    NSLayoutConstraint *inputMoreConstraintTop = [NSLayoutConstraint constraintWithItem:_chatInputMorePadView
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1
                                                                               constant:0];
    NSLayoutConstraint *inputMoreConstraintHeight = [NSLayoutConstraint constraintWithItem:_chatInputMorePadView
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1
                                                                                  constant:210];
    [self addConstraints:@[ inputMoreConstraintLeft, inputMoreConstraintRight, inputMoreConstraintTop, inputMoreConstraintHeight ]];
    _chatInputMorePositionConstraint = inputMoreConstraintTop;
    
    NSLayoutConstraint *inputEmotionConstraintLeft = [NSLayoutConstraint constraintWithItem:_chatInputEmotionPadView
                                                                               attribute:NSLayoutAttributeLeft
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self
                                                                               attribute:NSLayoutAttributeLeft
                                                                              multiplier:1
                                                                                constant:0];
    NSLayoutConstraint *inputEmotionConstraintRight = [NSLayoutConstraint constraintWithItem:_chatInputEmotionPadView
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1
                                                                                 constant:0];
    NSLayoutConstraint *inputEmotionConstraintTop = [NSLayoutConstraint constraintWithItem:_chatInputEmotionPadView
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1
                                                                               constant:0];
    NSLayoutConstraint *inputEmotionConstraintHeight = [NSLayoutConstraint constraintWithItem:_chatInputEmotionPadView
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1
                                                                                  constant:210];
    [self addConstraints:@[ inputEmotionConstraintLeft, inputEmotionConstraintRight, inputEmotionConstraintTop, inputEmotionConstraintHeight ]];
    _chatInputEmotionPositionConstraint = inputEmotionConstraintTop;
    
    NSLayoutConstraint *inputConstraintLeft = [NSLayoutConstraint constraintWithItem:_chatInputContentView
                                                                           attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1
                                                                            constant:0];
    NSLayoutConstraint *inputConstraintRight = [NSLayoutConstraint constraintWithItem:_chatInputContentView
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1
                                                                             constant:0];
    NSLayoutConstraint *inputConstraintBottom = [NSLayoutConstraint constraintWithItem:_chatInputContentView
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1
                                                                              constant:0];
    [self addConstraints:@[ inputConstraintLeft, inputConstraintRight, inputConstraintBottom ]];
    _chatInputContentViewBottomConstraint = inputConstraintBottom;
    
    NSLayoutConstraint *tableConstraintLeft = [NSLayoutConstraint constraintWithItem:_tableView
                                                                           attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1
                                                                            constant:0];
    NSLayoutConstraint *tableConstraintRight = [NSLayoutConstraint constraintWithItem:_tableView
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1
                                                                             constant:0];
    NSLayoutConstraint *tableConstraintTop = [NSLayoutConstraint constraintWithItem:_tableView
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1
                                                                           constant:0];
    NSLayoutConstraint *tableConstraintBottom = [NSLayoutConstraint constraintWithItem:_tableView
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:_chatInputContentView
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1
                                                                              constant:0];
    [self addConstraints:@[ tableConstraintLeft, tableConstraintRight, tableConstraintTop, tableConstraintBottom ]];
}

#pragma mark - replace constraint
- (void)replaceChatInputContentViewBottomConstraint:(NSLayoutConstraint *)constraint {
    
    [self removeConstraint:_chatInputContentViewBottomConstraint];
    [self addConstraint:constraint];
    _chatInputContentViewBottomConstraint = constraint;
}

- (void)animatedRefreshConstraints {
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self layoutIfNeeded];
    }];
}

- (void)endInput {
    
    if (_chatInputContentView.inputType == CYChatInputContentInputTypeEmotion) {
        
        // 隐藏emotion pad
        [self removeConstraint:_chatInputEmotionPositionConstraint];
        NSLayoutConstraint *inputEmotionConstraintTop = [NSLayoutConstraint constraintWithItem:_chatInputEmotionPadView
                                                                                     attribute:NSLayoutAttributeTop
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                    multiplier:1
                                                                                      constant:0];
        [self addConstraint:inputEmotionConstraintTop];
        _chatInputEmotionPositionConstraint = inputEmotionConstraintTop;
    } else if (_chatInputContentView.inputType == CYChatInputContentInputTypeMore) {
        
        // 隐藏more pad
        [self removeConstraint:_chatInputMorePositionConstraint];
        NSLayoutConstraint *inputMoreConstraintTop = [NSLayoutConstraint constraintWithItem:_chatInputMorePadView
                                                                                  attribute:NSLayoutAttributeTop
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1
                                                                                   constant:0];
        [self addConstraint:inputMoreConstraintTop];
        _chatInputMorePositionConstraint = inputMoreConstraintTop;
    }
    [self animatedRefreshConstraints];
    
    if (_chatInputContentView.inputType != CYChatInputContentInputTypeVoice) {
        
        [_chatInputContentView resetInputType:CYChatInputContentInputTypeText editing:NO];
    }
}

#pragma mark - CYChatInputContentViewDelegate
- (BOOL)chatInputContentShouldSendText:(NSString *)text {
    
    if (_delegate) {
        
        [_delegate chatViewShouldSendTextMessage:text];
    }
    return YES;
}

- (void)chatInputContentDidChangeInputType:(CYChatInputContentInputType)inputType {
    
    if (inputType == CYChatInputContentInputTypeVoice) {
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_chatInputContentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:0];
        [self replaceChatInputContentViewBottomConstraint:constraint];
    } else if (inputType == CYChatInputContentInputTypeMore) {
        
        // 显示more pad
        [self removeConstraint:_chatInputMorePositionConstraint];
        NSLayoutConstraint *inputMoreConstraintBottom = [NSLayoutConstraint constraintWithItem:_chatInputMorePadView
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                    multiplier:1
                                                                                      constant:0];
        [self addConstraint:inputMoreConstraintBottom];
        _chatInputMorePositionConstraint = inputMoreConstraintBottom;
        
        // 输入栏在more pad的顶部
        NSLayoutConstraint *inputConstraintBottom = [NSLayoutConstraint constraintWithItem:_chatInputContentView
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:_chatInputMorePadView
                                                                                 attribute:NSLayoutAttributeTop
                                                                                multiplier:1
                                                                                  constant:0];
        [self replaceChatInputContentViewBottomConstraint:inputConstraintBottom];
        
    } else if (inputType == CYChatInputContentInputTypeEmotion) {
        
        // 显示emotion pad
        [self removeConstraint:_chatInputEmotionPositionConstraint];
        NSLayoutConstraint *inputEmotionConstraintBottom = [NSLayoutConstraint constraintWithItem:_chatInputEmotionPadView
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                    multiplier:1
                                                                                      constant:0];
        [self addConstraint:inputEmotionConstraintBottom];
        _chatInputEmotionPositionConstraint = inputEmotionConstraintBottom;
        
        // 输入栏在emotion pad的顶部
        NSLayoutConstraint *inputConstraintBottom = [NSLayoutConstraint constraintWithItem:_chatInputContentView
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:_chatInputEmotionPadView
                                                                                 attribute:NSLayoutAttributeTop
                                                                                multiplier:1
                                                                                  constant:0];
        [self replaceChatInputContentViewBottomConstraint:inputConstraintBottom];
    }
    if (inputType != CYChatInputContentInputTypeMore) {
        
        // 隐藏more pad
        [self removeConstraint:_chatInputMorePositionConstraint];
        NSLayoutConstraint *inputMoreConstraintTop = [NSLayoutConstraint constraintWithItem:_chatInputMorePadView
                                                                                  attribute:NSLayoutAttributeTop
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1
                                                                                   constant:0];
        [self addConstraint:inputMoreConstraintTop];
        _chatInputMorePositionConstraint = inputMoreConstraintTop;
    }
    if (inputType != CYChatInputContentInputTypeEmotion) {
        
        // 隐藏emotion pad
        [self removeConstraint:_chatInputEmotionPositionConstraint];
        NSLayoutConstraint *inputEmotionConstraintTop = [NSLayoutConstraint constraintWithItem:_chatInputEmotionPadView
                                                                                     attribute:NSLayoutAttributeTop
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                    multiplier:1
                                                                                      constant:0];
        [self addConstraint:inputEmotionConstraintTop];
        _chatInputEmotionPositionConstraint = inputEmotionConstraintTop;
    }
    [self animatedRefreshConstraints];
    
    [_tableView scrollToBottomAnimated:YES];
}

#pragma mark - NSNotification
- (void)keyboardWillShow:(NSNotification *)notice {
    
    if (_chatInputContentView.textView.isFirstResponder) {
        
        CGFloat keyboardHeight = [[notice.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].size.height;
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_chatInputContentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:-keyboardHeight];
        [self replaceChatInputContentViewBottomConstraint:constraint];
        [self animatedRefreshConstraints];
    }
}

- (void)keyboardWillHide:(NSNotification *)notice {
    
    if (_chatInputContentView.inputType == CYChatInputContentInputTypeText
        && _chatInputContentView.textView.isFirstResponder) {
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_chatInputContentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:0];
        [self replaceChatInputContentViewBottomConstraint:constraint];
        [self animatedRefreshConstraints];

    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notice {
    
    if (_chatInputContentView.inputType == CYChatInputContentInputTypeText
        && _chatInputContentView.textView.isFirstResponder) {
        
        CGFloat keyboardHeight = [[notice.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].size.height;
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_chatInputContentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:-keyboardHeight];
        [self replaceChatInputContentViewBottomConstraint:constraint];
    }
}

#pragma mark - event
- (void)tableTapped:(id)sender {
    
    [self endInput];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

@end
