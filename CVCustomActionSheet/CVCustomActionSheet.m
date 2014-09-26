//
//  CVCustomActionSheet.m
//  CVCustomActionSheet
//
//  Created by Coulton Vento on 5/7/14.
//  Copyright (c) 2014 twobros. All rights reserved.
//

#import "CVCustomActionSheet.h"

CGFloat const buttonHeight = 44.0f;
CGFloat const buttonMargin = 15.0f;
NSInteger const buttonCountMax = 4;

#define kScreenSize [[UIScreen mainScreen] bounds]
#define kButtonWidth kScreenSize.size.width - (buttonMargin * 2)

@interface CVCustomActionSheet () {
    NSString *cancelTitle;
    NSArray *buttonTitles;
    
    UIView *contentView;
    UIScrollView *scrollView;
    UIVisualEffectView *backgroundView;
}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) CVCustomActionSheet *actionSheet;
@property (nonatomic, readonly) UIButton *cancelButton, *optionButton;
@end

@implementation CVCustomActionSheet

- (void)setDefaults
{
    self.buttonBackgroundColor = [UIColor whiteColor];
    self.buttonTextColor = [UIColor blackColor];
    self.selectedButtonBackgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.selectedButtonTextColor = [UIColor blackColor];
    
    self.cancelBackgroundColor = [UIColor blueColor];
    self.cancelTextColor = [UIColor whiteColor];
    self.selectedCancelBackgroundColor = [UIColor blueColor];
    self.selectedCancelTextColor = [UIColor whiteColor];
    
    self.buttonFont = [UIFont systemFontOfSize:15];
    self.lineColor = [UIColor colorWithWhite:0.9 alpha:1.0];
}

- (id)initWithButtons:(NSArray *)buttons
 andCancelButtonTitle:(NSString*)cancelButtonTitle
{
    self = [super init];
    if (self) {
        cancelTitle = cancelButtonTitle;
        [self setDefaults];
        
        self.window = [UIApplication sharedApplication].keyWindow;
        self.actionSheet = self;
        buttonTitles = buttons;
        
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        backgroundView = [[UIVisualEffectView alloc] initWithEffect:effect];
        backgroundView.frame = kScreenSize;
        [self.window addSubview:backgroundView];
        
        contentView = [[UIView alloc] initWithFrame:kScreenSize];
        
        if ([buttons count] > buttonCountMax) {
            CGRect frame = CGRectMake(buttonMargin, 0, kButtonWidth, buttonHeight * buttonCountMax);
            scrollView = [[UIScrollView alloc] initWithFrame:frame];
            scrollView.backgroundColor = self.buttonBackgroundColor;
            scrollView.delegate = self.actionSheet;
            scrollView.showsVerticalScrollIndicator = NO;
            
            scrollView.contentSize = CGSizeMake(kButtonWidth, ((buttonHeight + 1) * [buttons count]) - 1);
            [contentView addSubview:scrollView];
        }
        
        int i = 0;
        for (NSString *buttonTitle in buttons) {
            
            // Single option
            UIButton *optionButton = [self optionButton];
            [optionButton setTitle:buttonTitle forState:UIControlStateNormal];
            
            if ([buttons count] > buttonCountMax) {
                
                optionButton.frame = CGRectMake(0, i * (buttonHeight + 1), kButtonWidth, buttonHeight);
                [scrollView addSubview:optionButton];
            } else {
                
                optionButton.frame = CGRectMake(buttonMargin, i * (buttonHeight + 1), kButtonWidth, buttonHeight);
                [contentView addSubview:optionButton];
            }
            
            // Line
            if (i < [buttons count] - 1) {
                CALayer *line = [CALayer layer];
                line.backgroundColor = self.lineColor.CGColor;
                
                if ([buttons count] > buttonCountMax) {
                    
                    line.frame = CGRectMake(0, optionButton.frame.origin.y + buttonHeight, kButtonWidth, 1);
                    [scrollView.layer addSublayer:line];
                } else {
                    
                    line.frame = CGRectMake(buttonMargin, optionButton.frame.origin.y + buttonHeight, kButtonWidth, 1);
                    [contentView.layer addSublayer:line];
                }
            }
            
            i++;
        }
        
        if ([buttons count] > buttonCountMax) {
            
            CALayer *lineTop = [CALayer layer];
            lineTop.backgroundColor = self.lineColor.CGColor;
            lineTop.frame = CGRectMake(0, -1, kButtonWidth, 1);
            [scrollView.layer addSublayer:lineTop];
            
            CALayer *lineBottom = [CALayer layer];
            lineBottom.backgroundColor = self.lineColor.CGColor;
            lineBottom.frame = CGRectMake(0, scrollView.contentSize.height, kButtonWidth, 1);
            [scrollView.layer addSublayer:lineBottom];
        }
        
        // Cancel
        UIButton *cancel = [self cancelButton];
        if ([buttons count] > buttonCountMax) {
            cancel.frame = CGRectMake(buttonMargin, buttonCountMax * (buttonHeight + 1), kButtonWidth, buttonHeight);
        } else {
            cancel.frame = CGRectMake(buttonMargin, (i * (buttonHeight + 1)) + 7.5f, kButtonWidth, buttonHeight);
        }
        [cancel setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [contentView addSubview:cancel];
        
        // Content frame
        CGRect frame = contentView.frame;
        frame.size.height = cancel.frame.origin.y + cancel.frame.size.height;
        frame.origin.y = kScreenSize.size.height;
        contentView.frame = frame;
        [self.window addSubview:contentView];
    
    }
    return self;
}

#pragma mark Properties

- (UIButton *)cancelButton
{
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setTitleColor:self.cancelTextColor forState:UIControlStateNormal];
    cancel.titleLabel.font = self.buttonFont;
    cancel.backgroundColor = self.cancelBackgroundColor;
    
    [cancel addTarget:self.actionSheet
               action:@selector(cancel:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [cancel addTarget:self.actionSheet
               action:@selector(buttonPress:)
     forControlEvents:UIControlEventTouchDown];
    
    [cancel addTarget:self.actionSheet
               action:@selector(buttonRelease:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [cancel addTarget:self.actionSheet
               action:@selector(buttonRelease:)
     forControlEvents:UIControlEventTouchUpOutside];
    
    return cancel;
}

- (UIButton *)optionButton
{
    UIButton *option = [UIButton buttonWithType:UIButtonTypeCustom];
    [option setTitleColor:self.buttonTextColor forState:UIControlStateNormal];
    option.titleLabel.font = self.buttonFont;
    option.backgroundColor = self.buttonBackgroundColor;
    
    [option addTarget:self.actionSheet
               action:@selector(buttonPress:)
     forControlEvents:UIControlEventTouchDown];
    
    [option addTarget:self.actionSheet
               action:@selector(buttonRelease:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [option addTarget:self.actionSheet
               action:@selector(buttonRelease:)
     forControlEvents:UIControlEventTouchUpOutside];
    
    [option addTarget:self.actionSheet
               action:@selector(close:)
     forControlEvents:UIControlEventTouchUpInside];
    
    return option;
}

#pragma mark - Buttons
#pragma mark Actions

- (void)show
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         
                         contentView.alpha = 1.0;
                         backgroundView.alpha = 1.0f;
                         
                     } completion:nil];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
                            
                            CGRect frame = contentView.frame;
                            frame.origin.y = kScreenSize.size.height - contentView.frame.size.height - buttonMargin;
                            contentView.frame = frame;
                            
                        }
                     completion:nil];
}

- (void)close:(id)sender
{
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        
        backgroundView.alpha = 0.0;
        
        CGRect frame = contentView.frame;
        frame.origin.y = kScreenSize.size.height;
        contentView.frame = frame;
        
    } completion:^(BOOL finish){
        
        [backgroundView removeFromSuperview];
        backgroundView = nil;
        self.actionSheet = nil;
        
//        [self.delegate actionSheetButtonClicked:self.actionSheet
//                                withButtonIndex:[NSNumber numberWithInt:index]
//                                withButtonTitle:[buttonTitles objectAtIndex:index]];
        
    }];
}

- (void)cancel:(id)sender
{
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
    
        backgroundView.alpha = 0.0;
        
        CGRect frame = contentView.frame;
        frame.origin.y = kScreenSize.size.height;
        contentView.frame = frame;
    
    } completion:^(BOOL finish){
        
        [backgroundView removeFromSuperview];
        backgroundView = nil;
        self.actionSheet = nil;
        
        //[self.delegate actionSheetCancelled:self.actionSheet];
        
    }];
}

#pragma mark Highlighting

- (void)scrollViewWillBeginDragging:(UIScrollView *)draggedScrollView
{
    for (UIView *subview in scrollView.subviews) {
        
        if (subview.tag == 0) continue;
        [self buttonRelease:subview];
    }
}

- (void)buttonPress:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    if ([button.titleLabel.text isEqualToString:cancelTitle]) {
        [button setTitleColor:self.selectedCancelTextColor forState:UIControlStateNormal];
        [button setBackgroundColor:self.selectedCancelBackgroundColor];
    } else {
        [button setTitleColor:self.selectedButtonTextColor forState:UIControlStateNormal];
        [button setBackgroundColor:self.selectedButtonBackgroundColor];
    }
}

- (void)buttonRelease:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    if ([button.titleLabel.text isEqualToString:cancelTitle]) {
        [button setTitleColor:self.cancelTextColor forState:UIControlStateNormal];
        [button setBackgroundColor:self.cancelBackgroundColor];
    } else {
        [button setTitleColor:self.buttonTextColor forState:UIControlStateNormal];
        [button setBackgroundColor:self.buttonBackgroundColor];
    }
}

@end
