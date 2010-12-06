//
//  PostCell.h
//  Reddit
//
//  Created by Ross Boucher on 11/25/08.
//  Copyright 2008 280 North. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "Story.h"
#import <QuartzCore/QuartzCore.h>

@interface TransparentToolbar : UIToolbar
@end

@interface StoryCellBackView : UIView
@end

@interface StoryCell : UITableViewCell {
	Story		*story;
	UILabel		*storyTitleView;
	UILabel		*storyDescriptionView;
	UILabel		*secondaryDescriptionView;
	TTImageView	*storyImage;
	StoryCellBackView *backView;
	UIToolbar   *swipebar;
	NSMutableDictionary *toolbarItems;

	BOOL contentViewMoving;
}

@property (nonatomic,retain) Story *story;
@property (nonatomic,retain) UILabel *storyTitleView;
@property (nonatomic,retain) UILabel *storyDescriptionView;
@property (nonatomic,retain) TTImageView *storyImage;
@property (readonly) UIToolbar *swipebar;
@property (readonly) NSMutableDictionary *toolbarItems;
@property (nonatomic,retain) StoryCellBackView *backView;
@property (nonatomic,assign) BOOL contentViewMoving;

- (void)setScore:(int)score;
- (void)drawBackView:(CGRect )rect;
- (void)backViewDidDisappear;
- (void)showBackView;
- (void)hideBackView;
- (void)resetViews;
- (CAAnimationGroup *)bounceAnimationWithHideDuration:(CGFloat)hideDuration initialXOrigin:(CGFloat)originalX;

@end
