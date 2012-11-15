//
//  UIListView.m
//  UIListView
//
//  Created by SeeKool on 11/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIListView.h"
#import "UIListViewCell.h"

//  Default Value
#ifndef DEFAULTVALUE
#define DEFAULTVALUE

//  defaul height/width for row
#define DEFAULT_ROWHEIGHT               44.0f
#define DEFAULT_ROWWIDTH                44.0f

//  timeInterval is 5.0f by default, if auto scroll
#define DEFAULT_TIMEINTERVAL            5.0f

// pageControl's frame is CGRectMake((self.frame.size.width - _numberOfRows * 10) / 2, self.frame.size.height - 10.0f, _numberOfRows * 10, 20.0f);
#define DEFAULT_PAGECONTROLHEIGHT                   20.0f
#define DEFAULT_SEPERATORBETWEENPAGECONTROLINDEXS   20.0f
#define DEFAULT_BOTTOMMARGINEOFPAGECONTROL          10.0f
#define DEFAULT_PAGECONTROLFRAME    CGRectMake((self.frame.size.width - _numberOfRows * DEFAULT_SEPERATORBETWEENPAGECONTROLINDEXS) / 2, self.frame.size.height - DEFAULT_BOTTOMMARGINEOFPAGECONTROL - DEFAULT_PAGECONTROLHEIGHT, _numberOfRows * DEFAULT_SEPERATORBETWEENPAGECONTROLINDEXS, DEFAULT_PAGECONTROLHEIGHT)

// specifical size for loadMoreData
#define DEFAULT_SPECIFICALSIZEFORLOADMOREDATA       80.0f

#endif


@interface UIListView ()

@property (nonatomic, retain) UIScrollView              *scrollView;
@property (nonatomic, retain) UITapGestureRecognizer    *tapGestureRecognizerForSelectedIndex;
- (void)actionForTapGestureRecognizerForSelectedIndex:(UITapGestureRecognizer *)tapGestureRecognizer;

@property (nonatomic, assign) UIListViewScrollType      scrollType;
//  if scrollType == UIListViewScrollTypeCycle, should use 'contentViews' to contain cells and reset cells' frame on scroll view.
@property (nonatomic, retain) NSMutableArray            *contentViews;
//  And a array is needed to store the cells index on scroll view.
@property (nonatomic, retain) NSMutableArray            *cellsIndexOnScrollView;
- (void)updateRowsFrameForCycleScrollingListViewToScrollToPreRow;
- (void)updateRowsFrameForCycleScrollingListViewToScrollToNextRow;

@property (nonatomic, assign) UIListViewScrollDirection scrollDirectioin;

//  set List view by delegate and data source
- (void)setListViewByDataSource;
- (void)setListViewByDelegate;


@property (nonatomic, assign) BOOL                      isNumberOfRowsFixed;
@property (nonatomic, assign) BOOL                      shouldLoadMoreData;
@property (nonatomic, assign) CGFloat                   specificalForLoadMoreData;
@property (nonatomic, assign) UIListViewLoadMoreDataState   loadMoreDataState;
//  load more data state manage
- (void)updateLoadMoreDataState;
//  load more data
- (void)loadMoreData;

@property (nonatomic, assign) BOOL                      isBlockingScroll;
@property (nonatomic, assign) BOOL                      doesAlignByMostVisiblePartRow;
@property (nonatomic, assign) BOOL                      isPagingScroll;
@property (nonatomic, retain) UIView                    *coverViewForPagingScroll;
@property (nonatomic, retain) UISwipeGestureRecognizer  *swipeGestureRecognizerForCoverViewToScrollToPreRow;
@property (nonatomic, retain) UISwipeGestureRecognizer  *swipeGestureRecognizerForCoverViewToScrollToNextRow;
//  scrollView will always align left/top when stopping scroll.
- (void)alignRowsAfterDidEndDecelerating;
//  swipeGestureRecognizerAction
- (void)actionForSwipeGestureRecognizer:(UISwipeGestureRecognizer *)swipeGestureRecognizer;
//  didScrolledToTheEndOfScrollView
- (BOOL)didScrolledToTheEndOfScrollView;

@property (nonatomic, assign) BOOL                      doesAutoScroll;
@property (nonatomic, retain) NSTimer                   *timer;
@property (nonatomic, assign) NSTimeInterval            timeInterval;

@property (nonatomic, assign) BOOL                      doesUsePageControl;
@property (nonatomic, retain) UIPageControl             *pageControl;
@property (nonatomic, assign) CGRect                    pageControlFrame;
- (void)setPageControlFrame;
@property (nonatomic, retain) UIColor                   *backgroundColorOfPageControl;
@property (nonatomic, retain) UIImage                   *normalIndexImage;
@property (nonatomic, retain) UIImage                   *highlightIndexImage;

@property (nonatomic, assign) NSInteger                 numberOfRows;

@property (nonatomic, assign) CGFloat                   rowHeight;
@property (nonatomic, assign) CGFloat                   rowWidth;

//  current index is equal to first index at most of time.
@property (nonatomic, assign) NSInteger                 currentIndex;

@property (nonatomic, assign) NSInteger                 selectedIndex;
@property (nonatomic, assign) NSInteger                 hiddenIndex;

//  Appearance
@property (nonatomic, assign) UIListViewCellSeperatorStyle  seperatorStyle;
@property (nonatomic, assign) CGFloat                       seperatorWidth;
@property (nonatomic, retain, readwrite) UIColor            *separatorColor;
@property (nonatomic, retain, readwrite) UIView             *customSeparatorView;


//  Scrolling Process

//  scroll state
@property (nonatomic, assign) BOOL                      didBeginScrolling;
@property (nonatomic, assign) BOOL                      isScrolling;
@property (nonatomic, assign) BOOL                      didEndScrolling;

- (void)listViewIsScrolling;
- (void)listViewDidEndScrolling;

//  drag state
@property (nonatomic, assign) BOOL                      willBeginDragging;
@property (nonatomic, assign) BOOL                      willEndDragging;
@property (nonatomic, assign) BOOL                      didEndDragging;

- (void)listViewWillBeginDragging;
- (void)listViewWillEndDragging;
- (void)listViewDidEndDragging;

//  decelerate state
@property (nonatomic, assign) BOOL                      willBeginDecelerating;
@property (nonatomic, assign) BOOL                      didBeginDecelerating;
@property (nonatomic, assign) BOOL                      didEndDecelerating;

- (void)listViewWillBeginDecelerating;
- (void)listViewDidBeginDecelerating;
- (void)listViewDidEndDecelerating;

- (void)listViewDidScrollToTop;



//  update ListView's rows
- (void)updateListViewRows;

//  Auto Scroll
- (void)selectorForAutoScrollTimer;

//  PageControl
- (void)updatePageControlIndexStyle;

@end

@implementation UIListView

@synthesize listViewDelegate = _listViewDelegate;
@synthesize dataSource = _dataSource;

@synthesize background = _background;

@synthesize showHorizontalScrollIndicator = _showHorizontalScrollIndicator;
@synthesize showsVerticalScrollIndicator = _showsVerticalScrollIndicator;

@synthesize scrollView = _scrollView;
@synthesize tapGestureRecognizerForSelectedIndex = _tapGestureRecognizerForSelectedIndex;

@synthesize scrollType = _scrollType;
@synthesize contentViews = _contentViews;
@synthesize cellsIndexOnScrollView = _cellsIndexOnScrollView;

@synthesize scrollDirectioin = _scrollDirectioin;

@synthesize isNumberOfRowsFixed = _isNumberOfRowsFixed;
@synthesize shouldLoadMoreData = _shouldLoadMoreData;
@synthesize specificalForLoadMoreData = _specificalForLoadMoreData;
@synthesize loadMoreDataState = _loadMoreDataState;

@synthesize isBlockingScroll = _isBlockingScroll;
@synthesize doesAlignByMostVisiblePartRow = _doesAlignByMostVisiblePartRow;
@synthesize isPagingScroll = _isPagingScroll;
@synthesize coverViewForPagingScroll = _coverViewForPagingScroll;
@synthesize swipeGestureRecognizerForCoverViewToScrollToPreRow = _swipeGestureRecognizerForCoverViewToScrollToPreRow;
@synthesize swipeGestureRecognizerForCoverViewToScrollToNextRow = _swipeGestureRecognizerForCoverViewToScrollToNextRow;

@synthesize doesAutoScroll = _doesAutoScroll;
@synthesize timer = _timer;
@synthesize timeInterval = _timeInterval;

@synthesize doesUsePageControl = _doesUsePageControl;
@synthesize pageControl = _pageControl;
@synthesize pageControlFrame = _pageControlFrame;
@synthesize backgroundColorOfPageControl = _backgroundColorOfPageControl;
@synthesize normalIndexImage = _normalIndexImage;
@synthesize highlightIndexImage = _highlightIndexImage;

@synthesize numberOfRows = _numberOfRows;
@synthesize currentIndex = _currentIndex;

@synthesize selectedIndex = _selectedIndex;
@synthesize hiddenIndex = _hiddenIndex;

@synthesize rowHeight = _rowHeight;
@synthesize rowWidth = _rowWidth;


@synthesize seperatorStyle = _seperatorStyle;
@synthesize seperatorWidth = _seperatorWidth;
@synthesize separatorColor = _separatorColor;
@synthesize customSeparatorView = _customSeparatorView;


@synthesize didBeginScrolling = _didBeginScrolling;
@synthesize isScrolling = _isScrolling;
@synthesize didEndScrolling = _didEndScrolling;
@synthesize willBeginDragging = _willBeginDragging;
@synthesize willEndDragging = _willEndDragging;
@synthesize didEndDragging = _didEndDragging;
@synthesize willBeginDecelerating = _willBeginDecelerating;
@synthesize didBeginDecelerating = _didBeginDecelerating;
@synthesize didEndDecelerating  = _didEndDecelerating;

#pragma mark -
#pragma mark - dealloc (Memory manager)
- (void)dealloc
{
    [_scrollView release];
    [_tapGestureRecognizerForSelectedIndex release];
    
    [_contentViews release];
    [_cellsIndexOnScrollView release];
    
    [_coverViewForPagingScroll release];
    [_swipeGestureRecognizerForCoverViewToScrollToPreRow release];
    [_swipeGestureRecognizerForCoverViewToScrollToNextRow release];
    
    [_timer invalidate];
    _timer = nil;
    
    [_pageControl release];
    [_backgroundColorOfPageControl release];
    [_normalIndexImage release];
    [_highlightIndexImage release];
    
    [_background release];
    [_separatorColor release];
    [_customSeparatorView release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark - initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        _scrollView.contentSize = frame.size;
        [self addSubview:_scrollView];
        
        _contentViews = [[NSMutableArray alloc] init];
        
        _background = [[UIView alloc] initWithFrame:self.bounds];
        _background.backgroundColor = [UIColor clearColor];
        [self addSubview:_background];
        [self sendSubviewToBack:_background];
        
        _seperatorStyle = UIListViewCellSeperatorStyleNone;
        _separatorColor = [UIColor clearColor];
        
        _scrollType = UIListViewScrollTypeSwing;
        _cellsIndexOnScrollView = nil;
                
        _scrollDirectioin = UIListViewScrollDirectionVertical;
        
        _isBlockingScroll = NO;
        _isPagingScroll = NO;
        _isNumberOfRowsFixed = NO;
        _shouldLoadMoreData = NO;
        _specificalForLoadMoreData = DEFAULT_SPECIFICALSIZEFORLOADMOREDATA;
        _loadMoreDataState = UIListViewLoadMoreDataStateIdle;
        
        _doesAutoScroll = NO;
        _timer = nil;
        _timeInterval = DEFAULT_TIMEINTERVAL;
        
        _doesUsePageControl = NO;
        _pageControl = nil;
        _pageControlFrame = DEFAULT_PAGECONTROLFRAME;
        _backgroundColorOfPageControl = nil;
        _normalIndexImage = nil;
        _highlightIndexImage = nil;
        
        _rowHeight = DEFAULT_ROWHEIGHT;
        _rowWidth = DEFAULT_ROWWIDTH;
        
        _numberOfRows = 0;
        _currentIndex = 0;
        
        _selectedIndex = _currentIndex;
        _hiddenIndex = _currentIndex;
    }
    return self;
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    return nil;
}

#pragma mark -
#pragma mark - Class Extensions

#pragma mark - tapGestureRecognizer for selected index
- (void)actionForTapGestureRecognizerForSelectedIndex:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UIView *touchView = tapGestureRecognizer.view;
    CGPoint touchPoint = [tapGestureRecognizer locationInView:touchView];
    CGPoint realTouchPoint = CGPointMake(_scrollView.contentOffset.x + touchPoint.x, _scrollView.contentOffset.y + touchPoint.y);
    
    NSInteger selectedRowIndex = [self indexForRowAtPoint:realTouchPoint];
    if (selectedRowIndex >= 0) {
        self.selectedIndex = selectedRowIndex;
    }
}

#pragma mark - update list view's cells
//  update ListView's rows
- (void)updateListViewRows
{
    if (_shouldLoadMoreData && [_listViewDelegate respondsToSelector:@selector(tryToLoadMoreDataForListView:)]) {
        if (_contentViews && _contentViews.count > 0) {
            for (UIListViewCell *cell in _contentViews) {
                [cell removeFromSuperview];
            }
            
            [_contentViews removeAllObjects];
        }
    }
    
    for (NSInteger i = 0; i < _numberOfRows; i++) {
        
        CGRect cellFrame;
        UIListViewCell *cell;
        if ([_dataSource respondsToSelector:@selector(listView:cellForRowAtIndex:)]) {
            cell = [_dataSource listView:self cellForRowAtIndex:i];
        }
        
        if (cell) {
            //  if scrollType == UIListViewScrollTypeCycle, numberOfRows will be fixed. So, there is no need to worray about the changing of rows.
            if (_scrollType == UIListViewScrollTypeCycle) {
                if (!_cellsIndexOnScrollView) {
                    _cellsIndexOnScrollView = [[NSMutableArray alloc] init];
                    [_cellsIndexOnScrollView insertObject:[NSNumber numberWithInteger:(_numberOfRows - 1)] atIndex:0];
                    
                    //  set selected/hidden index
                    self.hiddenIndex = _numberOfRows - 1;
                }
                
                if (i != (_numberOfRows - 1)) {
                    [_cellsIndexOnScrollView insertObject:[NSNumber numberWithInteger:i] atIndex:(i + 1)];
                }
            }
            
            switch (self.scrollDirectioin) {
                case UIListViewScrollDirectionHorizontal:
                {
                    if (_scrollType == UIListViewScrollTypeCycle && i == (_numberOfRows - 1)) {
                        cellFrame = CGRectMake((-1) * self.rowWidth, 0.0f, self.rowWidth, self.rowHeight);
                    } else {
                        cellFrame = CGRectMake(i * self.rowWidth, 0.0f, self.rowWidth, self.rowHeight);
                    }
                    
                    break;
                }
                    
                case UIListViewScrollDirectionVertical:
                {
                    if (_scrollType == UIListViewScrollTypeCycle && i == (_numberOfRows - 1)) {
                        cellFrame = CGRectMake(0.0f, (-1) * self.rowHeight, self.rowWidth, self.rowHeight);
                    } else {
                        cellFrame = CGRectMake(0.0f, i * self.rowHeight, self.rowWidth, self.rowHeight);
                    }
                    
                    break;
                }
                    
                default:
                {
                    cellFrame = CGRectZero;
                    
                    break;
                }
            }
            
            cell.frame = cellFrame;
            [_scrollView addSubview:cell];
            [_contentViews insertObject:cell atIndex:i];
        }
    }
    
    
    switch (_scrollDirectioin) {
        case UIListViewScrollDirectionVertical:
        {
            CGFloat rowsHeight = self.rowHeight * _numberOfRows;
            CGFloat contentSizeHeight = (self.frame.size.height > rowsHeight) ? (self.frame.size.height + 1.0f) : rowsHeight;
            _scrollView.contentSize = CGSizeMake(self.frame.size.width, contentSizeHeight);
            
            break;
        }
            
        case UIListViewScrollDirectionHorizontal:
        {
            CGFloat rowsWidth = self.rowWidth * _numberOfRows;
            CGFloat contentSizeWidth = (self.frame.size.width > rowsWidth) ? (self.frame.size.width + 1.0f) : rowsWidth;
            _scrollView.contentSize = CGSizeMake(contentSizeWidth, self.frame.size.height);
            
            break;
        }
            
        default:
        {
            break;
        }
    }
}


#pragma mark - blocking-scroll
// scrollView will always align left/top when stopping scroll.
- (void)alignRowsAfterDidEndDecelerating
{
    [self scrollToNearestSelectedRowAnimated:YES];
}

//  didScrolledToTheEndOfScrollView
- (BOOL)didScrolledToTheEndOfScrollView
{
    switch (self.scrollDirectioin) {
        case UIListViewScrollDirectionHorizontal:
        {
            CGFloat contentWidth = _scrollView.contentSize.width;
            CGFloat offsetX = _scrollView.contentOffset.x;
            CGFloat scrollViewWidth = _scrollView.frame.size.width;
            if (contentWidth <= offsetX + scrollViewWidth) {
                return YES;
            } else {
                return NO;
            }
            
            break;
        }
        case UIListViewScrollDirectionVertical:
        {
            CGFloat contentHeight = _scrollView.contentSize.height;
            CGFloat offsetY = _scrollView.contentOffset.y;
            CGFloat scrollViewHeight = _scrollView.frame.size.height;
            if (contentHeight <= offsetY + scrollViewHeight) {
                return YES;
            } else {
                return NO;
            }
            
            break;
        }
            
        default:
        {
            return YES;
            
            break;
        }
    }
}

#pragma mark - delegate
//  set List view by delegate and data source
- (void)setListViewByDelegate
{
    if ([_listViewDelegate respondsToSelector:@selector(scrollTypeOfListView:)]) {
        self.scrollType = [_listViewDelegate scrollTypeOfListView:self];
    }
    
    if ([_listViewDelegate respondsToSelector:@selector(scrollDirectonOfListView:)]) {
        self.scrollDirectioin = [_listViewDelegate scrollDirectonOfListView:self];
    }
    
    if ([_listViewDelegate respondsToSelector:@selector(isNumberOfRowsFixedInListView:)]) {
        self.isNumberOfRowsFixed = [_listViewDelegate isNumberOfRowsFixedInListView:self];
    } else {
        self.isNumberOfRowsFixed = NO;
    }
    
    if ([_listViewDelegate respondsToSelector:@selector(isBlockingScrollForListView:)]) {
        self.isBlockingScroll = [_listViewDelegate isBlockingScrollForListView:self];
    }
    

    if ([_listViewDelegate respondsToSelector:@selector(isPagingScrollForListView:)]) {
        self.isPagingScroll = [_listViewDelegate isPagingScrollForListView:self];
    }
    
    if ([_listViewDelegate respondsToSelector:@selector(heightForRowInListView:)]) {
        self.rowHeight = [_listViewDelegate heightForRowInListView:self];
    }
    
    if ([_listViewDelegate respondsToSelector:@selector(widthForRowInlistView:)]) {
        self.rowWidth = [_listViewDelegate widthForRowInlistView:self];
    }
    
    if ([_listViewDelegate respondsToSelector:@selector(doesAutoScrollForListView:)]) {
        self.doesAutoScroll = [_listViewDelegate doesAutoScrollForListView:self];
    }
    
    if ([_listViewDelegate respondsToSelector:@selector(doesUsePageControlInListView:)]) {
        self.doesUsePageControl = [_listViewDelegate doesUsePageControlInListView:self];
    }
}

#pragma mark - data source
- (void)setListViewByDataSource
{
    if ([_dataSource respondsToSelector:@selector(numberOfRowsInListView:)]) {
        self.numberOfRows = [_dataSource numberOfRowsInListView:self];
    }
    
    [self updateListViewRows];
}


#pragma mark - auto scroll
//  Auto Scroll
- (void)selectorForAutoScrollTimer
{    
    if (_scrollType == UIListViewScrollTypeCycle) {
        [self updateRowsFrameForCycleScrollingListViewToScrollToNextRow];
    } else if (_scrollType == UIListViewScrollTypeSwing) {
        //  YES: scroll To Next; NO: scroll To Pre
        static BOOL scrollToPreOrNext = YES;
        if (scrollToPreOrNext) {
            if (_currentIndex < _numberOfRows - 1) {
                [self scrollToRowAtIndex:_currentIndex + 1 animated:YES];
            } else {
                scrollToPreOrNext = NO;
                [self scrollToRowAtIndex:_currentIndex - 1 animated:YES];
            }
        } else {
            if (_currentIndex > 0) {
                [self scrollToRowAtIndex:_currentIndex - 1 animated:YES];
            } else {
                scrollToPreOrNext = YES;
                [self scrollToRowAtIndex:_currentIndex + 1 animated:YES];
            }
        }
    }
}

- (void)setDoesAutoScroll:(BOOL)doesAutoScroll
{
    _doesAutoScroll = doesAutoScroll;
    if (_doesAutoScroll) {
        self.isNumberOfRowsFixed = YES;
        
        self.currentIndex = 0;
        
        if ([_listViewDelegate respondsToSelector:@selector(timeIntervalForListView:)]) {
            _timeInterval = [_listViewDelegate timeIntervalForListView:self];
        }
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                                  target:self
                                                selector:@selector(selectorForAutoScrollTimer)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    _timeInterval = timeInterval;
    if (_timeInterval < 0.00001f) {
        _timeInterval = DEFAULT_TIMEINTERVAL;
    }
}

#pragma mark - Page Control
//  PageControl
- (void)updatePageControlIndexStyle
{    
    if (_normalIndexImage || _highlightIndexImage) {
        for (NSInteger i = 0; i < _numberOfRows; i++) {
            if (i != _pageControl.currentPage && _normalIndexImage) {
                [((UIImageView *)[_pageControl.subviews objectAtIndex:i]) setImage:_normalIndexImage];
            } else if (_highlightIndexImage) {
                [((UIImageView *)[_pageControl.subviews objectAtIndex:i]) setImage:_highlightIndexImage];
            }
        }
    }
}

- (void)setDoesUsePageControl:(BOOL)doesUsePageControl
{
    _doesUsePageControl = doesUsePageControl;
    if (_doesUsePageControl) {
        self.isNumberOfRowsFixed = YES;
        
        _pageControl = [[UIPageControl alloc] init];
                
        if ([_listViewDelegate respondsToSelector:@selector(backgroundColorOfPageControlInListView:)]) {
            _backgroundColorOfPageControl = [[_listViewDelegate backgroundColorOfPageControlInListView:self] retain];
        } else {
            _backgroundColorOfPageControl = [[UIColor alloc] initWithWhite:0.1f alpha:0.8f];
        }
        
        if ([_listViewDelegate respondsToSelector:@selector(normalIndexImageOfPageControlInListView:)]) {
            _normalIndexImage = [[_listViewDelegate normalIndexImageOfPageControlInListView:self] retain];
        }
        
        if ([_listViewDelegate respondsToSelector:@selector(highlightIndexImageOfPageControlInListView:)]) {
            _highlightIndexImage = [[_listViewDelegate highlightIndexImageOfPageControlInListView:self] retain];
        }
        
        _pageControl.backgroundColor = _backgroundColorOfPageControl;
        [self addSubview:_pageControl];
        [_pageControl setEnabled:NO];
        _pageControl.currentPage = self.currentIndex;
        
        [self setPageControlFrame];
    }
}

- (void)setPageControlFrame
{    
    if ([_listViewDelegate respondsToSelector:@selector(pageControlFrameInListView:)]) {
        _pageControlFrame = [_listViewDelegate pageControlFrameInListView:self];
    } else if ([_listViewDelegate respondsToSelector:@selector(pageControlPositionInListView:)]) {
        
        CGFloat pageControlWidth = _numberOfRows * DEFAULT_SEPERATORBETWEENPAGECONTROLINDEXS > self.frame.size.width ? self.frame.size.width : _numberOfRows * DEFAULT_SEPERATORBETWEENPAGECONTROLINDEXS;
        
        switch ([_listViewDelegate pageControlPositionInListView:self]) {
            case UIListViewPageControlPositionLeft:
            {
                _pageControlFrame = CGRectMake(0.0f, self.frame.size.height - DEFAULT_BOTTOMMARGINEOFPAGECONTROL - DEFAULT_PAGECONTROLHEIGHT, pageControlWidth, DEFAULT_PAGECONTROLHEIGHT);
                
                break;
            }
                
            case UIListViewPageControlPositionLeftWithMarginQuarterOfPageControlWidth:
            {
                _pageControlFrame = CGRectMake((pageControlWidth) / 4, self.frame.size.height - DEFAULT_BOTTOMMARGINEOFPAGECONTROL - DEFAULT_PAGECONTROLHEIGHT, pageControlWidth, DEFAULT_PAGECONTROLHEIGHT);
                
                break;
            }
                
            case UIListViewPageControlPositionLeftWithMarginThirdOfPageControlWidth:
            {
                _pageControlFrame = CGRectMake((pageControlWidth) / 3, self.frame.size.height - DEFAULT_BOTTOMMARGINEOFPAGECONTROL - DEFAULT_PAGECONTROLHEIGHT, pageControlWidth, DEFAULT_PAGECONTROLHEIGHT);
                
                break;
            }
                
            case UIListViewPageControlPositionLeftWithMarginHalfOfPageControlWidth:
            {
                _pageControlFrame = CGRectMake((pageControlWidth) / 2, self.frame.size.height - DEFAULT_BOTTOMMARGINEOFPAGECONTROL - DEFAULT_PAGECONTROLHEIGHT, pageControlWidth, DEFAULT_PAGECONTROLHEIGHT);
                
                break;
            }
                
            case UIListViewPageControlPositionLeftWithMarginPageControlWidth:
            {
                _pageControlFrame = CGRectMake(pageControlWidth, self.frame.size.height - DEFAULT_BOTTOMMARGINEOFPAGECONTROL - DEFAULT_PAGECONTROLHEIGHT, pageControlWidth, DEFAULT_PAGECONTROLHEIGHT);
                
                break;
            }
                
            case UIListViewPageControlPositionMiddle:
            {
                _pageControlFrame = DEFAULT_PAGECONTROLFRAME;
                
                break;
            }
                
            case UIListViewPageControlPositionRightWithMarginPageControlWidth:
            {
                _pageControlFrame = CGRectMake(((self.frame.size.width - (pageControlWidth) * 2) < 0.0f ? 0.0f : (self.frame.size.width - (pageControlWidth) * 2)), self.frame.size.height - DEFAULT_BOTTOMMARGINEOFPAGECONTROL - DEFAULT_PAGECONTROLHEIGHT, pageControlWidth, DEFAULT_PAGECONTROLHEIGHT);
                
                break;
            }
                
            case UIListViewPageControlPositionRightWithMarginHalfOfPageControlWidth:
            {
                _pageControlFrame = CGRectMake((self.frame.size.width - pageControlWidth / 2 * 3) < 0.0f ? 0.0f : (self.frame.size.width - pageControlWidth / 2 * 3), self.frame.size.height - DEFAULT_BOTTOMMARGINEOFPAGECONTROL - DEFAULT_PAGECONTROLHEIGHT, pageControlWidth, DEFAULT_PAGECONTROLHEIGHT);
                
                break;
            }
                
            case UIListViewPageControlPositionRightWithMarginThirdOfPageControlWidth:
            {
                _pageControlFrame = CGRectMake((self.frame.size.width - pageControlWidth / 3 * 4) < 0.0f ? 0.0f : (self.frame.size.width - pageControlWidth / 3 * 4), self.frame.size.height - DEFAULT_BOTTOMMARGINEOFPAGECONTROL - DEFAULT_PAGECONTROLHEIGHT, pageControlWidth, DEFAULT_PAGECONTROLHEIGHT);
                
                break;
            }
                
            case UIListViewPageControlPositionRightWithMarginQuarterOfPageControlWidth:
            {
                _pageControlFrame = CGRectMake((self.frame.size.width - pageControlWidth / 4 * 5) < 0.0f ? 0.0f : (self.frame.size.width - pageControlWidth / 4 * 5), self.frame.size.height - DEFAULT_BOTTOMMARGINEOFPAGECONTROL - DEFAULT_PAGECONTROLHEIGHT, pageControlWidth, DEFAULT_PAGECONTROLHEIGHT);
                
                break;
            }
                
            case UIListViewPageControlPositionRight:
            {
                _pageControlFrame = CGRectMake(self.frame.size.width - pageControlWidth, self.frame.size.height - DEFAULT_BOTTOMMARGINEOFPAGECONTROL - DEFAULT_PAGECONTROLHEIGHT, pageControlWidth, DEFAULT_PAGECONTROLHEIGHT);
                
                break;
            }
                
            default:
                break;
        }
    } else {
        _pageControlFrame = DEFAULT_PAGECONTROLFRAME;
    }
    
    if (_doesUsePageControl && _pageControl) {
        _pageControl.numberOfPages = _numberOfRows;
        _pageControl.frame = _pageControlFrame;
        [self updatePageControlIndexStyle];
    }
}

- (void)setNormalIndexImage:(UIImage *)normalIndexImage
{
    if (normalIndexImage) {
        [_normalIndexImage release];
        
        _normalIndexImage = [normalIndexImage retain];
    }
}

- (void)setHighlightIndexImage:(UIImage *)highlightIndexImage
{
    if (highlightIndexImage) {
        [_highlightIndexImage release];
        
        _highlightIndexImage = [highlightIndexImage retain];
    }
}


#pragma mark - Scroll state
//  Scroll state
- (void)listViewDidBeginScrolling
{
    
}

- (void)listViewIsScrolling
{        
    // if shouldLoadMoreData == YES, try to load more data when scroll to the end of scroll's content view and scroll a specifical size too.
    if (_shouldLoadMoreData && [_listViewDelegate respondsToSelector:@selector(tryToLoadMoreDataForListView:)]) {
        if (_loadMoreDataState == UIListViewLoadMoreDataStateIdle) {
            self.loadMoreDataState = UIListViewLoadMoreDataStatePull;
            [self updateLoadMoreDataState];
        }
        
    }

}

- (void)listViewDidEndScrolling
{}

//  drag state
- (void)listViewWillBeginDragging
{}

- (void)listViewWillEndDragging
{}

- (void)listViewDidEndDragging
{    
    //  if blocking-scroll
    if (!self.willBeginDecelerating) {
        if (self.isBlockingScroll) {
            [self alignRowsAfterDidEndDecelerating];
        }
    }
    
    if (_shouldLoadMoreData && [_listViewDelegate respondsToSelector:@selector(tryToLoadMoreDataForListView:)] && _loadMoreDataState == UIListViewLoadMoreDataStatePull) {
        switch (self.scrollDirectioin) {
            case UIListViewScrollDirectionHorizontal:
            {                
                CGFloat contentWidth = _scrollView.contentSize.width;
                CGFloat offsetX = _scrollView.contentOffset.x;
                CGFloat scrollViewWidth = _scrollView.frame.size.width;
                if ((contentWidth + _specificalForLoadMoreData) <= (offsetX + scrollViewWidth)) {
                    self.loadMoreDataState = UIListViewLoadMoreDataStateLoading;
                    [self updateLoadMoreDataState];
                }
                
                break;
            }
            case UIListViewScrollDirectionVertical:
            {
                CGFloat contentHeight = _scrollView.contentSize.height;
                CGFloat offsetY = _scrollView.contentOffset.y;
                CGFloat scrollViewHeight = _scrollView.frame.size.height;
                if ((contentHeight + _specificalForLoadMoreData) <= (offsetY + scrollViewHeight)) {
                    self.loadMoreDataState = UIListViewLoadMoreDataStateLoading;
                    [self updateLoadMoreDataState];
                }
                
                break;
            }
                
            default:
            {                
                break;
            }
        }
    }
}

//  decelerate state
- (void)listViewWillBeginDecelerating
{}

- (void)listViewDidBeginDecelerating
{}

- (void)listViewDidEndDecelerating
{
    //  if blocking-scroll
    if (self.isBlockingScroll) {
        [self alignRowsAfterDidEndDecelerating];
    }
}

- (void)listViewDidScrollToTop
{}

#pragma mark -
#pragma mark - setting methods
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _scrollView.frame = frame;
    _background.frame = frame;
    
    if (_coverViewForPagingScroll) {
        _coverViewForPagingScroll.frame = frame;
    }
    
    if (_doesUsePageControl && _pageControl) {
        [self setPageControlFrame];
    }
}

- (void)setListViewDelegate:(id<UIListViewDelegate>)listViewDelegate
{
    _listViewDelegate = listViewDelegate;
    
    [self setListViewByDelegate];
}

- (void)setDataSource:(id<UIListViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self setListViewByDataSource];
}

- (void)setShowHorizontalScrollIndicator:(BOOL)showHorizontalScrollIndicator
{
    [_scrollView setShowsHorizontalScrollIndicator:showHorizontalScrollIndicator];
}

- (void)setShowsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator
{
    [_scrollView setShowsVerticalScrollIndicator:showsVerticalScrollIndicator];
}


//  scroll type: cycle scroll or swing scroll

- (void)setScrollType:(UIListViewScrollType)scrollType
{
    _scrollType = scrollType;
    switch (_scrollType) {
        case UIListViewScrollTypeInvalid:
        {
            [_scrollView setUserInteractionEnabled:NO];
            
            break;
        }
            
        case UIListViewScrollTypeStatic:
        {
            [_scrollView setUserInteractionEnabled:NO];
            
            break;
        }   
        
        case UIListViewScrollTypeCycle:
        {
            self.isNumberOfRowsFixed = YES;
            self.isPagingScroll = YES;
            
            break;
        }
            
        case UIListViewScrollTypeSwing:
        {
            if ([_listViewDelegate respondsToSelector:@selector(shouldLoadMoreDataForListView:)]) {
                self.shouldLoadMoreData = [_listViewDelegate shouldLoadMoreDataForListView:self];
            }
            
            break;
        }
            
        default:
        {
            [_scrollView setUserInteractionEnabled:NO];
            
            break;
        }
    }
}


//  for cycle scroll

- (void)updateRowsFrameForCycleScrollingListViewToScrollToPreRow
{
    //  reset last cell's frame
    NSNumber *firstCellIndex = [_cellsIndexOnScrollView objectAtIndex:0];
    NSNumber *lastCellIndex = [_cellsIndexOnScrollView objectAtIndex:(_cellsIndexOnScrollView.count - 1)];
    UIListViewCell *firstCell = [_contentViews objectAtIndex:firstCellIndex.integerValue];
    UIListViewCell *lastCell = [_contentViews objectAtIndex:lastCellIndex.integerValue];
    CGRect newFrame = firstCell.frame;
    
    switch (_scrollDirectioin) {
        case UIListViewScrollDirectionHorizontal:
        {
            self.hiddenIndex = [self indexForRowAtPoint:CGPointMake(_scrollView.contentOffset.x + _scrollView.frame.size.width - 1.0f, 0.0f)];

            break;
        }
            
        case UIListViewScrollDirectionVertical:
        {
            self.hiddenIndex = [self indexForRowAtPoint:CGPointMake(0.0f, _scrollView.contentOffset.y + _scrollView.frame.size.height - 1.0f)];
            
            break;
        }
            
        default:
        {
            self.hiddenIndex = [self indexForRowAtPoint:CGPointMake(_scrollView.contentOffset.x + _scrollView.frame.size.width, _scrollView.contentOffset.y + _scrollView.frame.size.height)];
            
            break;
        }
    }
    
    switch (self.scrollDirectioin) {
        case UIListViewScrollDirectionHorizontal:
        {
            newFrame.origin.x -= _rowWidth;
            
            break;
        }
        case UIListViewScrollDirectionVertical:
        {
            newFrame.origin.y -= _rowHeight;
            
            break;
        }
            
        default:
        {
            
            break;
        }
    }
    
    lastCell.frame = newFrame;
    [_cellsIndexOnScrollView removeObjectAtIndex:(_cellsIndexOnScrollView.count - 1)];
    [_cellsIndexOnScrollView insertObject:lastCellIndex atIndex:0];
    
    
    //  reset scroll view's content offset
    firstCellIndex = [_cellsIndexOnScrollView objectAtIndex:1];
    self.currentIndex = firstCellIndex.integerValue;
    firstCell = [_contentViews objectAtIndex:firstCellIndex.integerValue];
    [_scrollView setContentOffset:firstCell.frame.origin animated:YES];
}

- (void)updateRowsFrameForCycleScrollingListViewToScrollToNextRow
{
    //  reset scroll view's content offset
    NSNumber *secondCellIndex = [_cellsIndexOnScrollView objectAtIndex:2];
    self.currentIndex = secondCellIndex.integerValue;
    UIListViewCell *secondCell = [_contentViews objectAtIndex:secondCellIndex.integerValue];
    [_scrollView setContentOffset:secondCell.frame.origin animated:YES];
    
    //  reset first cell's frame
    NSNumber *firstCellIndex = [_cellsIndexOnScrollView objectAtIndex:0];
    NSNumber *lastCellIndex = [_cellsIndexOnScrollView objectAtIndex:(_cellsIndexOnScrollView.count - 1)];
    UIListViewCell *firstCell = [_contentViews objectAtIndex:firstCellIndex.integerValue];
    UIListViewCell *lastCell = [_contentViews objectAtIndex:lastCellIndex.integerValue];
    CGRect newFrame = lastCell.frame;
    
    self.hiddenIndex = [self indexForRowAtPoint:_scrollView.contentOffset];
    
    switch (self.scrollDirectioin) {
        case UIListViewScrollDirectionHorizontal:
        {
            newFrame.origin.x += _rowWidth;
            
            break;
        }
        case UIListViewScrollDirectionVertical:
        {
            newFrame.origin.y += _rowHeight;
            
            break;
        }
            
        default:
        {
            
            break;
        }
    }
    
    firstCell.frame = newFrame;
    
    [_cellsIndexOnScrollView removeObjectAtIndex:0];
    [_cellsIndexOnScrollView insertObject:firstCellIndex atIndex:_cellsIndexOnScrollView.count];
}



- (void)setScrollDirectioin:(UIListViewScrollDirection)scrollDirectioin
{
    _scrollDirectioin = scrollDirectioin;
    switch (_scrollDirectioin) {
        case UIListViewScrollDirectionInvalid:
        {
            [_scrollView setUserInteractionEnabled:NO];
            
            break;
        }
            
        case UIListViewScrollDirectionVertical:
        {            
            self.rowWidth = self.frame.size.width;
            self.rowHeight = DEFAULT_ROWHEIGHT;
            
            break;
        }
        
        case UIListViewScrollDirectionHorizontal:
        {                        
            self.rowHeight = self.frame.size.height;
            self.rowWidth = DEFAULT_ROWWIDTH;
            
            break;
        }    
        
        default:
        {
            [_scrollView setUserInteractionEnabled:NO];
            
            break;
        }
    }
}

- (void)setNumberOfRows:(NSInteger)numberOfRows
{
    _numberOfRows = numberOfRows;
    
    if (_doesUsePageControl) {
        [self setPageControlFrame];
    }
}

- (void)setIsNumberOfRowsFixed:(BOOL)isNumberOfRowsFixed
{
    _isNumberOfRowsFixed = isNumberOfRowsFixed;
}


#pragma mark - load more data
- (void)setShouldLoadMoreData:(BOOL)shouldLoadMoreData
{
    _shouldLoadMoreData = shouldLoadMoreData;
    if (_shouldLoadMoreData) {
        self.isNumberOfRowsFixed = !_shouldLoadMoreData;
        
        if ([_listViewDelegate respondsToSelector:@selector(specificalSizeForLoadMoreDataInListView:)]) {
            self.specificalForLoadMoreData = [_listViewDelegate specificalSizeForLoadMoreDataInListView:self];
        }
    }
}

- (void)setSpecificalForLoadMoreData:(CGFloat)specificalForLoadMoreData
{
    if (specificalForLoadMoreData < 0.01f) {
        _specificalForLoadMoreData = DEFAULT_SPECIFICALSIZEFORLOADMOREDATA;
    } else {
        _specificalForLoadMoreData = specificalForLoadMoreData;
    }
}

- (void)setLoadMoreDataState:(UIListViewLoadMoreDataState)loadMoreDataState
{
    _loadMoreDataState = loadMoreDataState;
}

- (void)updateLoadMoreDataState
{
    static BOOL readyToLoadMoreData = NO;
    
    switch (_loadMoreDataState) {
        case UIListViewLoadMoreDataStateIdle:
        {
            self.loadMoreDataState = UIListViewLoadMoreDataStatePull;
            
            break;
        }
            
        case UIListViewLoadMoreDataStatePull:
        {
            switch (self.scrollDirectioin) {
                case UIListViewScrollDirectionHorizontal:
                {
                    CGFloat contentWidth = _scrollView.contentSize.width;
                    CGFloat offsetX = _scrollView.contentOffset.x;
                    CGFloat scrollViewWidth = _scrollView.frame.size.width;
                    if ((contentWidth + _specificalForLoadMoreData) <= (offsetX + scrollViewWidth)) {
                        //readyToLoadMoreData = YES;
                    }
                    
                    break;
                }
                case UIListViewScrollDirectionVertical:
                {
                    CGFloat contentHeight = _scrollView.contentSize.height;
                    CGFloat offsetY = _scrollView.contentOffset.y;
                    CGFloat scrollViewHeight = _scrollView.frame.size.height;
                    if ((contentHeight + _specificalForLoadMoreData) <= (offsetY + scrollViewHeight)) {
                        //readyToLoadMoreData = YES;
                    }
                    
                    break;
                }
                    
                default:
                {
                    readyToLoadMoreData = NO;
                    
                    break;
                }
            }
            
            break;
        }
            
        case UIListViewLoadMoreDataStateLoading:
        {
            // loading
            [self loadMoreData];
            
            break;
        }
            
        case UIListViewLoadMoreDataStateRelease:
        {
            // load more data is done
            self.loadMoreDataState = UIListViewLoadMoreDataStateIdle;
            
            break;
        }
            
        default:
        {
            break;
        }
    }
}

//  load more data
- (void)loadMoreData
{
    if ([_listViewDelegate respondsToSelector:@selector(tryToLoadMoreDataForListView:)]) {
        [_listViewDelegate tryToLoadMoreDataForListView:self];
    }
}



#pragma mark - scroll type
- (void)setIsBlockingScroll:(BOOL)isBlockingScroll
{
    _isBlockingScroll = isBlockingScroll;
    if (_isBlockingScroll) {
        if ([_listViewDelegate respondsToSelector:@selector(doesAlignByMostVisiblePartRowForListView:)]) {
            self.doesAlignByMostVisiblePartRow = [_listViewDelegate doesAlignByMostVisiblePartRowForListView:self];
        }
    }
}

#pragma mark - paging-scroll
//  swipeGestureRecognizerAction
- (void)actionForSwipeGestureRecognizer:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    //  first Visible row index
    NSInteger firstVisibleRowIndex = [self indexForRowAtPoint:_scrollView.contentOffset];
    NSInteger lastVisibleRowIndex = [self indexForRowAtPoint:CGPointMake(_scrollView.contentOffset.x + _scrollView.frame.size.width, _scrollView.contentOffset.y + _scrollView.frame.size.height)];

    if (_scrollType == UIListViewScrollTypeSwing) {
        if (_swipeGestureRecognizerForCoverViewToScrollToPreRow && [_swipeGestureRecognizerForCoverViewToScrollToPreRow isEqual:swipeGestureRecognizer]) {
            
            if (firstVisibleRowIndex > 0) {
                firstVisibleRowIndex--;
            }
            
            self.hiddenIndex = lastVisibleRowIndex;
            
        } else if (_swipeGestureRecognizerForCoverViewToScrollToNextRow && [_swipeGestureRecognizerForCoverViewToScrollToNextRow isEqual:swipeGestureRecognizer]) {
            
            self.hiddenIndex = firstVisibleRowIndex;
            
            if (![self didScrolledToTheEndOfScrollView]) {
                firstVisibleRowIndex++;
            }
        }
        
        //  scroll to row at index
        [self scrollToRowAtIndex:firstVisibleRowIndex animated:YES];
        
    } else if (_scrollType == UIListViewScrollTypeCycle) {
        if (_swipeGestureRecognizerForCoverViewToScrollToPreRow && [_swipeGestureRecognizerForCoverViewToScrollToPreRow isEqual:swipeGestureRecognizer]) {
            [self updateRowsFrameForCycleScrollingListViewToScrollToPreRow];
        } else if (_swipeGestureRecognizerForCoverViewToScrollToNextRow && [_swipeGestureRecognizerForCoverViewToScrollToNextRow isEqual:swipeGestureRecognizer]) {
            [self updateRowsFrameForCycleScrollingListViewToScrollToNextRow];
        }
    }
}

- (void)setIsPagingScroll:(BOOL)isPagingScroll
{    
    _isPagingScroll = isPagingScroll;
    
    //  tapGestureRecognizerForSelectedIndex
    [_scrollView removeGestureRecognizer:_tapGestureRecognizerForSelectedIndex];
    if (!_coverViewForPagingScroll) {
        [_coverViewForPagingScroll removeGestureRecognizer:_tapGestureRecognizerForSelectedIndex];
    }
    [_tapGestureRecognizerForSelectedIndex release];
    _tapGestureRecognizerForSelectedIndex = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionForTapGestureRecognizerForSelectedIndex:)];
    
    
    if (_isPagingScroll) {
        // paging scroll
        self.isBlockingScroll = _isPagingScroll;
        
        if (!_coverViewForPagingScroll) {
            _coverViewForPagingScroll = [[UIView alloc] initWithFrame:_scrollView.frame];
        }
        _coverViewForPagingScroll.backgroundColor = [UIColor clearColor];
        [self addSubview:_coverViewForPagingScroll];
        [self bringSubviewToFront:_coverViewForPagingScroll];
        
        
        _swipeGestureRecognizerForCoverViewToScrollToPreRow = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionForSwipeGestureRecognizer:)];
        _swipeGestureRecognizerForCoverViewToScrollToNextRow = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionForSwipeGestureRecognizer:)];
        if (self.scrollDirectioin == UIListViewScrollDirectionVertical) {
            [_swipeGestureRecognizerForCoverViewToScrollToPreRow setDirection:UISwipeGestureRecognizerDirectionDown];
            [_swipeGestureRecognizerForCoverViewToScrollToNextRow setDirection:UISwipeGestureRecognizerDirectionUp];
        } else if (self.scrollDirectioin == UIListViewScrollDirectionHorizontal) {
            [_swipeGestureRecognizerForCoverViewToScrollToPreRow setDirection:UISwipeGestureRecognizerDirectionRight];
            [_swipeGestureRecognizerForCoverViewToScrollToNextRow setDirection:UISwipeGestureRecognizerDirectionLeft];
        }
        [_coverViewForPagingScroll addGestureRecognizer:_swipeGestureRecognizerForCoverViewToScrollToPreRow];
        [_coverViewForPagingScroll addGestureRecognizer:_swipeGestureRecognizerForCoverViewToScrollToNextRow];
        
        [_coverViewForPagingScroll addGestureRecognizer:_tapGestureRecognizerForSelectedIndex];
    } else {
        [_scrollView addGestureRecognizer:_tapGestureRecognizerForSelectedIndex];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    if ([_listViewDelegate respondsToSelector:@selector(listView:didSelectRowAtIndex:)]) {
        [_listViewDelegate listView:self didSelectRowAtIndex:_selectedIndex];
    }
}

- (void)setHiddenIndex:(NSInteger)hiddenIndex
{
    _hiddenIndex = hiddenIndex;
    
    if ([_listViewDelegate respondsToSelector:@selector(listView:didHiddenRowAtIndex:)]) {
        [_listViewDelegate listView:self didHiddenRowAtIndex:_hiddenIndex];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    
    if (_doesUsePageControl) {
        if (_pageControl) {
            _pageControl.currentPage = _currentIndex;
            [self updatePageControlIndexStyle];
        }
    }
}


//  Scrolling

- (void)setDidBeginScrolling:(BOOL)didBeginScrolling
{
    _didBeginScrolling = didBeginScrolling;
    if (_didBeginScrolling) {
        _didEndScrolling = NO;

        [self listViewDidBeginScrolling];
    }
}

- (void)setIsScrolling:(BOOL)isScrolling
{
    _isScrolling = isScrolling;
    if (_isScrolling) {
        [self listViewIsScrolling];
    }
}

- (void)setDidEndScrolling:(BOOL)didEndScrolling
{
    _didEndScrolling = didEndScrolling;
    if (_didEndScrolling) {
        _didBeginScrolling = NO;
        _isScrolling = NO;

        [self listViewDidEndScrolling];
    }
}

- (void)setWillBeginDragging:(BOOL)willBeginDragging
{
    _willBeginDragging = willBeginDragging;
    if (_willBeginDragging) {
        _willEndDragging = NO;
        _didEndDragging = NO;
        
        [self listViewWillBeginDragging];
    }
}

- (void)setWillEndDragging:(BOOL)willEndDragging
{
    _willEndDragging = willEndDragging;
    if (_willEndDragging) {
        [self listViewWillEndDragging];
    }
}

- (void)setDidEndDragging:(BOOL)didEndDragging
{
    _didEndDragging = didEndDragging;
    if (_didEndDragging) {
        _willBeginDragging = NO;
        _willEndDragging = NO;
        
        [self listViewDidEndDragging];
    }
}


- (void)setWillBeginDecelerating:(BOOL)willBeginDecelerating
{
    _willBeginDecelerating = willBeginDecelerating;
    if (_willBeginDecelerating) {
        _didBeginDecelerating = NO;
        _didEndDecelerating  = NO;
        
        [self listViewWillBeginDecelerating];
    }
}

- (void)setDidBeginDecelerating:(BOOL)didBeginDecelerating
{
    _didBeginDecelerating = didBeginDecelerating;
    if (_didBeginDecelerating) {
        [self listViewDidBeginDecelerating];
    }
}

- (void)setDidEndDecelerating:(BOOL)didEndDecelerating
{
    _didEndDecelerating = didEndDecelerating;
    if (_didEndDecelerating) {
        _willBeginDecelerating = NO;
        _didBeginDecelerating = NO;
        
        [self listViewDidEndDecelerating];
    }
}


#pragma mark -
#pragma mark - object methods
//  Data

//  reloads everything from scratch. redisplays visible rows.
- (void)reloadData
{
    [self setListViewByDataSource];
}

//  Info

- (NSInteger)numberOfRows
{
    return _numberOfRows;
}

- (CGRect)rectForRowAtIndex:(NSInteger)index
{
    return ((UIListViewCell *)[_contentViews objectAtIndex:index]).frame;
}


// returns nil if point is outside table
- (NSInteger)indexForRowAtPoint:(CGPoint)point
{
    NSInteger index = -1;
    
    for (NSInteger i = 0; i < _contentViews.count; i++) {
        UIListViewCell *cell = [_contentViews objectAtIndex:i];
        if (CGRectContainsPoint(cell.frame, point)) {
            index = i;
        }
    }
        
    return index;
}

// returns nil for cell is not visible
- (NSInteger)indexForCell:(UIListViewCell *)cell
{
    for (NSInteger index = 0; index < _contentViews.count; index++) {
        UIListViewCell *tmpCell = [_contentViews objectAtIndex:index];
        if ([cell isEqual:tmpCell]) {
            return index;
        }
    }
    
    return -1;
}

// returns nil if cell is not visible or index path is out of range
- (UIListViewCell *)cellForRowAtIndex:(NSInteger)index
{
    return (UIListViewCell *)[_contentViews objectAtIndex:index];
}

//  scroll to other row
- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated
{
    switch (self.scrollDirectioin) {
        case UIListViewScrollDirectionHorizontal:
        {
            CGFloat offsetX = self.rowWidth * index;
            CGPoint newContentOffset = CGPointMake(offsetX, 0.0f);
            [_scrollView setContentOffset:newContentOffset animated:animated];
            
            break;
        }
            
        case UIListViewScrollDirectionVertical:
        {
            CGFloat offsetY = self.rowHeight * index;
            CGPoint newContentOffset = CGPointMake(0.0f, offsetY);
            [_scrollView setContentOffset:newContentOffset animated:animated];
            
            break;
        }
            
        default:
        {
            break;
        }
    }
    
    self.currentIndex = index;
}

- (void)scrollToNearestSelectedRowAnimated:(BOOL)animated
{
    //  nearest selected row
    CGPoint firstVisibleRowPoint;
    NSInteger firstVisibleRowIndex;
    if (_doesAlignByMostVisiblePartRow) {
        firstVisibleRowPoint = CGPointMake(_scrollView.contentOffset.x + (_rowWidth / 2), _scrollView.contentOffset.y + (_rowHeight / 2));
    } else {
        firstVisibleRowPoint = _scrollView.contentOffset;
    }
    
    switch (_scrollDirectioin) {
        case UIListViewScrollDirectionHorizontal:
        {
            firstVisibleRowPoint.y = (_rowHeight / 2);
            
            break;
        }
            
        case UIListViewScrollDirectionVertical:
        {
            firstVisibleRowPoint.x = (_rowWidth / 2);
            
            break;
        }
            
        default:
        {
            
            break;
        }
    }
    
    firstVisibleRowIndex = [self indexForRowAtPoint:firstVisibleRowPoint];
    //  scroll to row at index
    [self scrollToRowAtIndex:firstVisibleRowIndex animated:animated];
}

//  Selection

//  row of selection.
- (NSInteger)indexForSelectedRow
{
    return _selectedIndex;
}

//  Selects and deselects rows. These methods will not call the delegate methods, nor will it send out a notification.
- (void)selectRowAtIndex:(NSInteger)index animated:(BOOL)animated
{
    if (_contentViews.count > 0) {
        if (index >= 0  && index < _contentViews.count) {
            //  select row at index
        }
    }
}

- (void)deselectRowAtIndex:(NSInteger)index animated:(BOOL)animated
{
    if (_contentViews.count > 0) {
        if (index >= 0  && index < _contentViews.count) {
            //  deselect row at index
        }
    }
}

//  load more data
- (void)loadMoreDataIsDone
{
    self.loadMoreDataState = UIListViewLoadMoreDataStateRelease;
    [self updateLoadMoreDataState];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

// any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_listViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_listViewDelegate scrollViewDidScroll:scrollView];
    }
    
    [self listViewIsScrolling];
}



// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_listViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_listViewDelegate scrollViewWillBeginDragging:scrollView];
    }
    
    [self listViewWillBeginDragging];
}

// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([_listViewDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [_listViewDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
    
    [self listViewWillEndDragging];
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([_listViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_listViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    [self listViewDidEndDragging];
}




// called on finger up as we are moving
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([_listViewDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [_listViewDelegate scrollViewWillBeginDecelerating:scrollView];
    }
    
    [self listViewWillBeginDecelerating];
}

// called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([_listViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_listViewDelegate scrollViewDidEndDecelerating:scrollView];
    }
    
    [self listViewDidEndDecelerating];
}



// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([_listViewDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [_listViewDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
    
    [self listViewDidEndScrolling];
}



// return a yes if you want to scroll to the top. if not defined, assumes YES
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if ([_listViewDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [_listViewDelegate scrollViewShouldScrollToTop:scrollView];
    } else {
        return YES;
    }
}

// called when scrolling animation finished. may be called immediately if already at top
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if ([_listViewDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [_listViewDelegate scrollViewDidScrollToTop:scrollView];
    }
    
    [self listViewDidScrollToTop];
}


@end
