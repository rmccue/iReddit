//
//  StoryCell.m
//  Reddit
//
//  Created by Ross Boucher on 11/25/08.
//  Copyright 2008 280 North. All rights reserved.
//

#import "StoryCell.h"
#import "Constants.h"
#import "LoginController.h"
#import "LoginViewController.h"

@implementation TransparentToolbar

// Override draw rect to avoid
// background coloring
- (void)drawRect:(CGRect)rect {
    // do nothing in here
}

// Set properties to make background
// translucent.
- (void) applyTranslucentBackground
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.translucent = YES;
}

// Override init.
- (id) init
{
    self = [super init];
    [self applyTranslucentBackground];
    return self;
}

// Override initWithFrame.
- (id) initWithFrame:(CGRect) frame
{
    self = [super initWithFrame:frame];
    [self applyTranslucentBackground];
    return self;
}

@end

@implementation StoryCellBackView
- (void)drawRect:(CGRect)rect {
	if (!self.hidden){
		[(StoryCell *)[self superview] drawBackView:rect];
	}
	else
	{
		[super drawRect:rect];
	}
}

@end

@implementation StoryCell

@synthesize storyTitleView, storyDescriptionView, storyImage, backView, contentViewMoving, scoreItem, swipebar;
@dynamic story;

+ (float)tableView:(UITableView *)aTableView rowHeightForItem:(Story *)aStory
{
	float height = [aStory heightForDeviceMode:[[UIDevice currentDevice] orientation] 
								 withThumbnail:[[NSUserDefaults standardUserDefaults] boolForKey:showStoryThumbnailKey] && [aStory hasThumbnail]] + 46.0;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:showStoryThumbnailKey])
		return MAX(height, 68.0);
	else
		return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{	
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
	{
		
		self.opaque = YES;
		self.backgroundColor = [UIColor blueColor];

		for (UIView *view in [self subviews])
		{
			[view setBackgroundColor:[UIColor whiteColor]];
			[view setOpaque:YES];
		}

		self.superview.opaque = YES;
		self.superview.backgroundColor = [UIColor whiteColor];

		for (UIView *view in [[self superview] subviews])
		{
			[view setBackgroundColor:[UIColor whiteColor]];
			[view setOpaque:YES];
		}
		StoryCellBackView *anotherView = [[StoryCellBackView alloc] initWithFrame:CGRectZero];
		[anotherView setOpaque:YES];
		[anotherView setClipsToBounds:YES];
		[anotherView setBackgroundColor:[UIColor blueColor]];
		[self setBackView:anotherView];
		[anotherView release];
		
		[self addSubview:backView];
		
		// Swipe toolbar
		UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];		
		UIBarButtonItem *upbutton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"voteUp.png"]
																   style:UIBarButtonItemStylePlain target:self
																  action:@selector(pressButton1:)];
		scoreItem = [[UILabel alloc] init];
		scoreItem.font = [UIFont boldSystemFontOfSize:18.0];
		[scoreItem setTextColor:[UIColor whiteColor]];
		[scoreItem setShadowColor:[UIColor blackColor]];
		[scoreItem setBackgroundColor:[UIColor clearColor]];
		
		scoreItem.shadowOffset = CGSizeMake(0.0, -1.0);
		
		UIBarButtonItem *downbutton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"voteDown.png"]
																   style:UIBarButtonItemStylePlain target:self
																  action:@selector(pressButton2:)];
		
		swipebar = [[TransparentToolbar alloc] initWithFrame:CGRectZero];
		NSArray *items = [NSArray arrayWithObjects:flexibleSpace, upbutton, [[[UIBarButtonItem alloc] initWithCustomView:scoreItem] autorelease], downbutton, flexibleSpace, nil];
		[flexibleSpace release];
		[upbutton release];
		[downbutton release];
		
		[swipebar setItems:items animated:NO];
		[swipebar setOpaque:YES];
		[swipebar setClipsToBounds:YES];
		[backView addSubview:swipebar];
		
		story = nil;

		storyTitleView = [[UILabel alloc] initWithFrame:CGRectZero];		
		storyTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		[storyTitleView setFont:[UIFont boldSystemFontOfSize:14]];
		[storyTitleView setTextColor:[UIColor blueColor]];
		[storyTitleView setLineBreakMode:UILineBreakModeTailTruncation];
		[storyTitleView setNumberOfLines:0];
		//[storyTitleView setLineBreakMode:UILineBreakModeWordWrap];
		
		storyDescriptionView = [[UILabel alloc] initWithFrame:CGRectZero];
		storyDescriptionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		[storyDescriptionView setFont:[UIFont boldSystemFontOfSize:12]];
		[storyDescriptionView setTextColor:[UIColor grayColor]];
		[storyDescriptionView setLineBreakMode:UILineBreakModeTailTruncation];
		
		secondaryDescriptionView = [[UILabel alloc] initWithFrame:CGRectZero];
		secondaryDescriptionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		[secondaryDescriptionView setFont:[UIFont systemFontOfSize:12]];
		[secondaryDescriptionView setTextColor:[UIColor grayColor]];
		[secondaryDescriptionView setLineBreakMode:UILineBreakModeTailTruncation];

		[[self contentView] addSubview:storyTitleView];
		[[self contentView] addSubview:storyDescriptionView];
		[[self contentView] addSubview:secondaryDescriptionView];
		
		storyImage = [[TTImageView alloc] initWithFrame:CGRectZero];
		storyImage.defaultImage = [UIImage imageNamed:@"noimage.png"];

		storyImage.autoresizesToImage = NO;
		storyImage.autoresizesSubviews = NO;
		storyImage.contentMode = UIViewContentModeScaleAspectFill;
		storyImage.clipsToBounds = YES;
		storyImage.opaque = YES;
		storyImage.backgroundColor = [UIColor whiteColor];

		storyImage.style =  [TTSolidFillStyle styleWithColor:[UIColor clearColor] 
														next:[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:6.0f] 
																					 next:[TTContentStyle styleWithNext:nil]]];

		[[self contentView] addSubview:storyImage];

		[self setContentViewMoving:NO];
		[self hideBackView];
    }
	
    return self;
}

- (void)layoutSubviews 
{
	[super layoutSubviews];
	
	CGRect contentRect = self.contentView.bounds;
	[backView setFrame:contentRect];
	[swipebar setFrame:contentRect];
	CGRect labelRect = contentRect;

	//contentRect.size.width = 320;
	
	float yOffset = 4.0;
	if (contentRect.size.height > 68)
		yOffset = 8.0;
	
	storyImage.frame = CGRectMake(8, yOffset, 60, 60);

	//BOOL showThumbnails = [[NSUserDefaults standardUserDefaults] boolForKey:@"showStoryThumbnails"];
	
	if ([storyImage isHidden])
	{
		//[storyImage setHidden:YES];
		
		labelRect.origin.y = contentRect.origin.y + 4.0;
		labelRect.origin.x = contentRect.origin.x + 8.0;
		
		labelRect.size.width = contentRect.size.width - 24.0;
		labelRect.size.height = contentRect.size.height - 44.0;
	}
	else
	{
		//[storyImage setHidden:NO];

		labelRect.origin.y = labelRect.origin.y + 4.0;
		labelRect.origin.x = labelRect.origin.x + 16.0 + storyImage.frame.size.height;
				
		labelRect.size.width = contentRect.size.width - 32.0 - storyImage.frame.size.height;
		labelRect.size.height = contentRect.size.height - 44.0;		
	}
	
	storyTitleView.frame = labelRect;
	storyDescriptionView.frame = CGRectMake(labelRect.origin.x, CGRectGetHeight(contentRect) - 40.0, labelRect.size.width, 16);
	secondaryDescriptionView.frame = CGRectMake(labelRect.origin.x, CGRectGetHeight(contentRect) - 24.0, labelRect.size.width, 16);
}

- (void)dealloc 
{
	[story release];
	[storyTitleView release];
	[storyDescriptionView release];
	
	if (storyImage)
		[storyImage release];
	
	[backView release];
	[swipebar release];
	[scoreItem release];
    [super dealloc];
}

- (void)setHighlighted:(BOOL)selected animated:(BOOL)animated
{
	if (!backView.hidden)
	{
		selected = NO;
	}

	[super setSelected:selected animated:animated];
	
	//UIColor *titleColor = selected ? [UIColor colorWithRed:85.0/255.0 green:26.0/255.0 blue:139.0/255.0 alpha:1.0] : [UIColor blueColor];
	UIColor *titleColor = story.visited ? [UIColor colorWithRed:85.0/255.0 green:26.0/255.0 blue:139.0/255.0 alpha:1.0] : [UIColor blueColor];
	UIColor *finalColor = selected ? [UIColor whiteColor] : titleColor;
	UIColor *descriptionColor = selected ? [UIColor colorWithWhite:0.8 alpha:1.0] : [UIColor grayColor];
	
	[storyTitleView setTextColor:finalColor];
	[storyDescriptionView setTextColor:descriptionColor];
	[secondaryDescriptionView setTextColor:descriptionColor];
}

- (Story *)story
{
	return story;
}

- (void)setStory:(Story *)aStory 
{		
	[story autorelease];
	story = [aStory retain];

	if (!story)
	{
		[storyImage setImage:storyImage.defaultImage];
		[storyTitleView setText:@""];
		[storyDescriptionView setText:@""];
		[secondaryDescriptionView setText:@""];
		return;
	}

	if ([[NSUserDefaults standardUserDefaults] boolForKey:showStoryThumbnailKey])
	{
		if ([story hasThumbnail])
		{
			[storyImage setHidden:NO];
			[storyImage setURL:story.thumbnailURL];
		}
		else
		{
			[storyImage setHidden:YES];
		}
	}
	else
		[storyImage setHidden:YES];
	
	UIColor *titleColor = story.visited ? [UIColor colorWithRed:85.0/255.0 green:26.0/255.0 blue:139.0/255.0 alpha:1.0] : [UIColor blueColor];
	[storyTitleView setTextColor:titleColor];
	
	[storyTitleView setText:story.title];
	[storyTitleView setNeedsDisplay];
	
	[storyDescriptionView setText:[NSString stringWithFormat:@"%@", story.domain]];
	[storyDescriptionView setNeedsDisplay];
	
	[secondaryDescriptionView setText:[NSString stringWithFormat:@"%d points in %@ by %@", story.score, story.subreddit, story.author, story.totalComments, story.totalComments == 1  ? @"" : @"s"]];
	[secondaryDescriptionView setNeedsDisplay];
	
	[self setScore:story.score];
}

- (void)drawBackView:(CGRect )rect
{
	[[UIImage imageNamed:@"meshpattern.png"] drawAsPatternInRect:rect];
	[swipebar setNeedsDisplay];
	NSLog(@"Drawing back view");
}

- (void)setScore:(int)score
{
	[scoreItem setText:[NSString stringWithFormat:@"%i", score]];
	[scoreItem sizeToFit];
	
	if (story.likes)
		[scoreItem setTextColor:[UIColor colorWithRed:255.0/255.0 green:139.0/255.0 blue:96.0/255.0 alpha:1.0]];
	else if (story.dislikes)
		[scoreItem setTextColor:[UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1.0]];
	else
		[scoreItem setTextColor:[UIColor whiteColor]];
}

- (void)pressButton1:(UIBarButtonItem *)button
{
	NSLog(@"Pressed button 1");
	NSLog(@"Upvoting story: %@", story.title);
}

- (void)pressButton2:(UIBarButtonItem *)button
{
	NSLog(@"Pressed button 2");
	NSLog(@"Downvoting story: %@", story.title);
}

- (void)backViewDidDisappear
{
	/*NSEnumerator *subviews = [[backView subviews] objectEnumerator];
	id view;
	while (view = [subviews nextObject]) {
		[view removeFromSuperview];
	}*/
}

- (void)showBackView
{
	if (!contentViewMoving && backView.hidden) {
		
		contentViewMoving = YES;

		[backView.layer setHidden:NO];
		[backView setNeedsDisplay];
		[self.contentView.layer setAnchorPoint:CGPointMake(0, 0.5)];
		[self.contentView.layer setPosition:CGPointMake(self.contentView.frame.size.width, self.contentView.layer.position.y)];
		
		CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
		[animation setRemovedOnCompletion:NO];
		[animation setDelegate:self];
		[animation setDuration:0.14];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
		[self.contentView.layer addAnimation:animation forKey:@"reveal"];
	}
	NSLog(@"Showing back view for %@", story.title);
}

- (void)hideBackView
{
	NSLog(@"Attempting to hide...");
	if (!contentViewMoving && !backView.hidden) {
		//backView.hidden = YES;
		
		contentViewMoving = YES;
		
		CGFloat hideDuration = 0.09;
		
		[backView.layer setOpacity:0.0];
		CABasicAnimation *hideAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		[hideAnimation setFromValue:[NSNumber numberWithFloat:1.0]];
		[hideAnimation setToValue:[NSNumber numberWithFloat:0.0]];
		[hideAnimation setDuration:hideDuration];
		[hideAnimation setRemovedOnCompletion:NO];
		[hideAnimation setDelegate:self];
		[backView.layer addAnimation:hideAnimation forKey:@"hide"];
		
		CGFloat originalX = self.contentView.layer.position.x;
		[self.contentView.layer setAnchorPoint:CGPointMake(0, 0.5)];
		[self.contentView.layer setPosition:CGPointMake(0, self.contentView.layer.position.y)];
		[self.contentView.layer addAnimation:[self bounceAnimationWithHideDuration:hideDuration initialXOrigin:originalX] 
								 forKey:@"bounce"];
		NSLog(@"will disappear");
	}
}

- (void)resetViews
{
	[self.contentView.layer setAnchorPoint:CGPointMake(0, 0.5)];
	[self.contentView.layer setPosition:CGPointMake(0, self.contentView.layer.position.y)];

	[backView.layer setHidden:YES];
	[backView.layer setOpacity:1.0];
	
	[self backViewDidDisappear];
	NSLog(@"did disappear");
	contentViewMoving = NO;
}


- (void)voteUp:(id)sender
{
	if (![[LoginController sharedLoginController] isLoggedIn] && sender != self)
	{
		[LoginViewController presentWithDelegate:(id <LoginViewControllerDelegate>)self context:@"voteUp"];
		return;
	}
	
	NSString *url = [NSString stringWithFormat:@"%@%@", RedditBaseURLString, RedditVoteAPIString];
	TTURLRequest *request = [TTURLRequest requestWithURL:url delegate:nil];
	
	request.cacheExpirationAge = 0;
	request.cachePolicy = TTURLRequestCachePolicyNoCache;
	request.contentType = @"application/x-www-form-urlencoded";
	request.httpMethod = @"POST";
	request.httpBody = [[NSString stringWithFormat:@"dir=%d&uh=%@&id=%@&_=", story.likes ? 0 : 1, 
						 [[LoginController sharedLoginController] modhash], story.name] 
						dataUsingEncoding:NSASCIIStringEncoding];
	
	[request send];
	
	
	story.likes = !story.likes;
	story.dislikes = NO;
	
	[self setScore:story.score];
	
	//[[Beacon shared] startSubBeaconWithName:@"votedUp" timeSession:NO];
}

- (void)voteDown:(id)sender
{
	if (![[LoginController sharedLoginController] isLoggedIn] && sender != self)
	{
		[LoginViewController presentWithDelegate:(id <LoginViewControllerDelegate>)self context:@"voteDown"];
		return;
	}
	
	NSString *url = [NSString stringWithFormat:@"%@%@", RedditBaseURLString, RedditVoteAPIString];
	TTURLRequest *request = [TTURLRequest requestWithURL:url delegate:nil];
	
	request.cacheExpirationAge = 0;
	request.cachePolicy = TTURLRequestCachePolicyNoCache;
	request.contentType = @"application/x-www-form-urlencoded";
	request.httpMethod = @"POST";
	request.httpBody = [[NSString stringWithFormat:@"dir=%d&uh=%@&id=%@&_=", story.dislikes ? 0 : -1, 
						 [[LoginController sharedLoginController] modhash], story.name] 
						dataUsingEncoding:NSASCIIStringEncoding];
	
	[request send];
	
	
	story.likes = NO;
	story.dislikes = !story.dislikes;
	
	[self setScore:story.score];
	 
	 //[[Beacon shared] startSubBeaconWithName:@"votedDown" timeSession:NO];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	
	if (flag){
		
		if (anim == [self.contentView.layer animationForKey:@"reveal"]){
			[self.contentView.layer removeAnimationForKey:@"reveal"];
			NSLog(@"did appear");
			contentViewMoving = NO;
		}
		
		if (anim == [self.contentView.layer animationForKey:@"bounce"]){
			
			[self.contentView.layer removeAnimationForKey:@"bounce"];
			[self resetViews];
		}
		
		if (anim == [backView.layer animationForKey:@"hide"]){
			[backView.layer removeAnimationForKey:@"hide"];
		}
	}
}

- (CAAnimationGroup *)bounceAnimationWithHideDuration:(CGFloat)hideDuration initialXOrigin:(CGFloat)originalX; {
	
	CABasicAnimation * animation0 = [CABasicAnimation animationWithKeyPath:@"position.x"];
	[animation0 setFromValue:[NSNumber numberWithFloat:originalX]];
	[animation0 setToValue:[NSNumber numberWithFloat:0]];
	[animation0 setDuration:hideDuration];
	[animation0 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	[animation0 setBeginTime:0];
	
	CAAnimationGroup * hideAnimations = [CAAnimationGroup animation];
	[hideAnimations setAnimations:[NSArray arrayWithObject:animation0]];
	
	CGFloat fullDuration = hideDuration;
	
	if (YES){
		
		CGFloat bounceDuration = 0.04;
		
		CABasicAnimation * animation1 = [CABasicAnimation animationWithKeyPath:@"position.x"];
		[animation1 setFromValue:[NSNumber numberWithFloat:0]];
		[animation1 setToValue:[NSNumber numberWithFloat:-20]];
		[animation1 setDuration:bounceDuration];
		[animation1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
		[animation1 setBeginTime:hideDuration];
		
		CABasicAnimation * animation2 = [CABasicAnimation animationWithKeyPath:@"position.x"];
		[animation2 setFromValue:[NSNumber numberWithFloat:-20]];
		[animation2 setToValue:[NSNumber numberWithFloat:15]];
		[animation2 setDuration:bounceDuration];
		[animation2 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
		[animation2 setBeginTime:(hideDuration + bounceDuration)];
		
		CABasicAnimation * animation3 = [CABasicAnimation animationWithKeyPath:@"position.x"];
		[animation3 setFromValue:[NSNumber numberWithFloat:15]];
		[animation3 setToValue:[NSNumber numberWithFloat:0]];
		[animation3 setDuration:bounceDuration];
		[animation3 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
		[animation3 setBeginTime:(hideDuration + (bounceDuration * 2))];
		
		[hideAnimations setAnimations:[NSArray arrayWithObjects:animation0, animation1, animation2, animation3, nil]];
		
		fullDuration = hideDuration + (bounceDuration * 3);
	}
	
	[hideAnimations setDuration:fullDuration];
	[hideAnimations setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	[hideAnimations setDelegate:self];
	[hideAnimations setRemovedOnCompletion:NO];
	
	return hideAnimations;
}


@end
