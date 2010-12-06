//
//  SubredditViewController.m
//  Reddit2
//
//  Created by Ross Boucher on 6/8/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "SubredditViewController.h"
#import "SubredditDataSource.h"
#import "StoryViewController.h"
#import "iRedditAppDelegate.h"
#import "Constants.h"
#import "StoryCell.h"

@implementation SubredditViewController
@synthesize indexOfVisibleBackView;

- (void)dealloc 
{
	[self.dataSource cancel];
	[subredditItem release];
	[tabBar release];
	[savedLocation release];

    [super dealloc];
}

- (id)initWithField:(TTTableTextItem*)anItem
{
    if (self = [super init])
	{
		subredditItem = [anItem retain];
		showTabBar = ![subredditItem.URL isEqual:@"/saved/"] && ![subredditItem.URL isEqual:@"/recommended/"];
		
        self.title = [anItem.URL isEqual:@"/"] ? @"Front Page" : anItem.text;
		
		if (showTabBar && ![subredditItem.URL isEqual:@"/randomrising/"])
		{
			[[NSUserDefaults standardUserDefaults] setObject:subredditItem.URL forKey:initialRedditURLKey];
			[[NSUserDefaults standardUserDefaults] setObject:self.title forKey:initialRedditTitleKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}

		self.hidesBottomBarWhenPushed = YES;
		self.variableHeightRows = YES;
		
		self.navigationBarTintColor = [iRedditAppDelegate redditNavigationBarTintColor];
	}

	return self;
}

- (void)loadView
{
	[super loadView];

    // create the tableview
    self.view = [[[UIView alloc] initWithFrame:TTApplicationFrame()] autorelease];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	if (tabBar)
	{
		[tabBar release];
		tabBar = nil;
	}
			
	if (showTabBar)
	{
		tabBar = [[TTTabStrip alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];

		tabBar.tabItems = [NSArray arrayWithObjects:
							 [[[TTTabItem alloc] initWithTitle:@"   Hot   "] autorelease],
							 [[[TTTabItem alloc] initWithTitle:@"  New  "] autorelease],
							 [[[TTTabItem alloc] initWithTitle:@"  Top  "] autorelease],
							 [[[TTTabItem alloc] initWithTitle:@"Controversial"] autorelease],
						   nil];

		tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		tabBar.delegate = (id <TTTabDelegate>)self;
	}

	CGRect aFrame = self.view.frame;
	
	aFrame.origin.y = tabBar ? CGRectGetHeight(tabBar.frame) : 0.0;
	aFrame.size.height -= aFrame.origin.y;
	
	//UIView *wrapper = [[[UIView alloc] initWithFrame:aFrame] autorelease];
    //wrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	//aFrame.origin.y	= 0;
	
	self.tableView = [[[UITableView alloc] initWithFrame:aFrame style:UITableViewStylePlain] autorelease];
    self.tableView.rowHeight = 80.f;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	//self.tableView.tableHeaderView = tabBar;
	
	//[wrapper addSubview:self.tableView];
	
	if (tabBar)
		[self.view addSubview:tabBar];

    [self.view addSubview:self.tableView];
	UISwipeGestureRecognizer *recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(performSwipe:)] autorelease];
	[self.tableView addGestureRecognizer:recognizer];
}

/*- (void)unloadView
{
	[tabBar release];
	tabBar = nil;
	
	[super unloadView];
}*/

- (void)restoreSavedState
{
	if (!savedLocation)
		return;

	if (savedLocation.row < [self.tableView numberOfRowsInSection:savedLocation.section])
	{
		[self.tableView scrollToRowAtIndexPath:savedLocation atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
		[savedLocation release];
		savedLocation = nil;
	}
	else if (![self.dataSource isLoadingMore] && ![self.dataSource isLoading])
	{
		if ([(SubredditDataSource *)(self.dataSource) totalStories] < 500)
			[self.dataSource load:TTURLRequestCachePolicyNoCache nextPage:YES];
		else
		{
			[savedLocation release];
			savedLocation = nil;
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView reloadData];

	if (savedLocation && !(self.viewState & TTViewLoadingStates))
		[self restoreSavedState];
}

- (void)setViewState:(TTViewState)aState
{
	[super setViewState:aState];
	
	if (aState & TTViewDataStates && savedLocation)
		[self restoreSavedState];
}

- (id<TTTableViewDataSource>)createDataSource
{
	SubredditDataSource *source = [[[SubredditDataSource alloc] initWithURL:subredditItem.URL title:subredditItem.text] autorelease];

	source.viewController = self;
	source.newsModeIndex = tabBar.selectedTabIndex;
		
	return source;
}

- (NSString *)titleForError:(NSError*)error
{
	return @"Connection Error";
}

- (NSString *)subtitleForError:(NSError*)error
{
	return @"iReddit requires an active Internet connection";
}

- (UIImage*)imageForError:(NSError*)error
{
	return [UIImage imageNamed:@"error.png"];
}

- (UIImage*)imageForNoData
{
	return [UIImage imageNamed:@"error.png"];
}

- (NSString*)titleForNoData
{
	return @"No Stories";
}

#pragma mark Swiping stuff

- (void)performSwipe:(UISwipeGestureRecognizer*)sender {
	NSIndexPath *path = [self.tableView indexPathForRowAtPoint:[sender locationInView:self.tableView]];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
	if ([cell isKindOfClass:[StoryCell class]]) {
		[self hideVisibleBackView:YES];
		[self setIndexOfVisibleBackView:path];
		[(StoryCell *)cell showBackView];
	}
}

- (void)hideVisibleBackView:(BOOL)animated {
	
	if (indexOfVisibleBackView != nil){
		
		if (animated){
			[(StoryCell *)[self.tableView cellForRowAtIndexPath:indexOfVisibleBackView] hideBackView];
		}
		else
		{
			[(StoryCell *)[self.tableView cellForRowAtIndexPath:indexOfVisibleBackView] resetViews];
		}
		
		[self setIndexOfVisibleBackView:nil];
	}
}

- (void)didBeginDragging {
	[self hideVisibleBackView:YES];
}

#pragma mark tab bar stuff

- (void)tabBar:(id)tabBar tabSelected:(int)selectedIndex
{
	[self.dataSource cancel];
	[self.dataSource invalidate:YES];
	[self.tableView reloadData];
	[self updateView];
	//[self reloadContent];
}

#pragma mark orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:allowLandscapeOrientationKey] && (interfaceOrientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadData];
}

#pragma mark Table view methods

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
	if (indexOfVisibleBackView == indexPath){
		// Selecting an object that's swiped, do nothing
		return;
	}

	[super didSelectObject:object atIndexPath:indexPath];

	if ([object isKindOfClass:[Story class]])
	{
		[self hideVisibleBackView:NO];
		[savedLocation release];
		savedLocation = [indexPath retain];
		
		StoryViewController *controller = [[StoryViewController alloc] init];
		[[self navigationController] pushViewController:controller animated:YES];

		controller.story = object;
		[controller release];

		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)didSelectAccessoryForObject:(id)object atIndexPath:(NSIndexPath*)indexPath 
{
	if ([object isKindOfClass:[Story class]])
	{
		[self hideVisibleBackView:NO];
		StoryViewController *controller = [[StoryViewController alloc] initForComments];
		[[self navigationController] pushViewController:controller animated:YES];
		
		controller.story = object;
		[controller release];
		
		[self.tableView reloadData];
	}
}

/*
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[super scrollViewDidEndDecelerating:scrollView];	
}
*/

@end

