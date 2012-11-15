//
//  ViewController.m
//  UIListView
//
//  Created by SeeKool on 11/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#ifndef PROPAGEDATACOUNT
#define PROPAGEDATACOUNT    6
#endif

@interface ViewController ()

@property (nonatomic, retain) UIListView *listView;

@property (nonatomic, assign) NSInteger pageCount;

- (void)loadNextPageData;

@end

@implementation ViewController

@synthesize listView = _listView;

@synthesize pageCount = _pageCount;


#pragma mark -
#pragma mark - dealloc
- (void)dealloc
{
    [_listView release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark - init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _pageCount = 0;
    }
    return self;
}


#pragma mark -
#pragma mark - view did load/unload
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _listView = [[UIListView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_listView];
    
    [_listView setShowsVerticalScrollIndicator:NO];
    [_listView setShowHorizontalScrollIndicator:NO];
    
    _listView.listViewDelegate = self;
    _listView.dataSource = self;
    _listView.backgroundColor = [UIColor grayColor];
    
    self.pageCount = 1;
    [_listView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


#pragma mark -
#pragma mark - Class Extensions
- (void)loadNextPageData
{    
    self.pageCount++;
    [self.listView reloadData];
    
    [self.listView loadMoreDataIsDone];
}

#pragma mark -
#pragma mark - UIListViewDelegate
- (UIListViewScrollDirection)scrollDirectonOfListView:(UIListView *)listView
{
    return UIListViewScrollDirectionHorizontal;
}


#pragma mark - scroll type
- (UIListViewScrollType)scrollTypeOfListView:(UIListView *)listView
{
    return UIListViewScrollTypeSwing;
}

- (BOOL)isBlockingScrollForListView:(UIListView *)listView
{
    return NO;
}

- (BOOL)doesAlignByMostVisiblePartRowForListView:(UIListView *)listView
{
    return YES;
}

- (BOOL)isPagingScrollForListView:(UIListView *)listView
{
    return YES;
}

#pragma mark - select cell
- (void)listView:(UIListView *)listView didSelectRowAtIndex:(NSInteger)index
{
    NSLog(@"selected: %i", index);
}

- (void)listView:(UIListView *)listView didHiddenRowAtIndex:(NSInteger)index
{
    NSLog(@"hidden: %i", index);
}

#pragma mark - load more data
- (BOOL)shouldLoadMoreDataForListView:(UIListView *)listView
{
    return NO;
}

- (void)tryToLoadMoreDataForListView:(UIListView *)listView
{    
    [self performSelector:@selector(loadNextPageData) withObject:nil afterDelay:3.0f];
}

#pragma mark - cell size
- (CGFloat)widthForRowInlistView:(UIListView *)listView
{
    return 80.0f;
}

- (CGFloat)heightForRowInListView:(UIListView *)listView
{
    return 160.0f;
}


#pragma mark - auto scroll
- (BOOL)doesAutoScrollForListView:(UIListView *)listView
{
    return NO;
}

- (NSTimeInterval)timeIntervalForListView:(UIListView *)listView
{
    return 2.0f;
}

#pragma mark - page control

- (BOOL)doesUsePageControlInListView:(UIListView *)listView
{
    return NO;
}

- (UIListViewPageControlPosition)pageControlPositionInListView:(UIListView *)listView
{
    return UIListViewPageControlPositionRightWithMarginThirdOfPageControlWidth;
}

- (CGRect)pageControlFrameInListView:(UIListView *)listView
{
    return CGRectMake(50.0f, 140.0f, 200.0f, 20.0f);
}

- (UIColor *)backgroundColorOfPageControlInListView:(UIListView *)listView
{
    return [UIColor clearColor];
}

- (UIImage *)normalIndexImageOfPageControlInListView:(UIListView *)listView
{
    return [UIImage imageNamed:@"pageControllerIndexNormal"];
}

- (UIImage *)highlightIndexImageOfPageControlInListView:(UIListView *)listView
{
    return [UIImage imageNamed:@"pageControllerIndexActivity"];
}

#pragma mark -
#pragma mark - UIListViewDataSource
- (NSInteger)numberOfRowsInListView:(UIListView *)listView
{
    return self.pageCount * PROPAGEDATACOUNT;
}

- (UIListViewCell *)listView:(UIListView *)listVIew cellForRowAtIndex:(NSInteger)index
{
    UIListViewCell *cell = [[UIListViewCell alloc] init];

    cell.textLabel.text = [NSString stringWithFormat:@"%i", index];
    
    return cell;
}

@end
