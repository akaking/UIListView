//
//  UIListView.h
//  UIListView
//
//  Created by SeeKool on 11/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


//  ------------Scroll Type-------------
typedef enum {
    UIListViewScrollTypeInvalid,
    UIListViewScrollTypeStatic,
    UIListViewScrollTypeCycle,
    UIListViewScrollTypeSwing,
} UIListViewScrollType;

//  -----------Scroll Direction-----------
typedef enum {
    UIListViewScrollDirectionInvalid,
    UIListViewScrollDirectionVertical,
    UIListViewScrollDirectionHorizontal,
} UIListViewScrollDirection;


//  ---------Cell Seperator Style---------
typedef enum {
    UIListViewCellSeperatorStyleNone,
    UIListViewCellSeperatorStyleSingleLine,
} UIListViewCellSeperatorStyle;


//  -------Page Control's position--------
typedef enum {
    UIListViewPageControlPositionLeft,
    UIListViewPageControlPositionLeftWithMarginQuarterOfPageControlWidth,
    UIListViewPageControlPositionLeftWithMarginThirdOfPageControlWidth,
    UIListViewPageControlPositionLeftWithMarginHalfOfPageControlWidth,
    UIListViewPageControlPositionLeftWithMarginPageControlWidth,
    UIListViewPageControlPositionMiddle,
    UIListViewPageControlPositionRight,
    UIListViewPageControlPositionRightWithMarginQuarterOfPageControlWidth,
    UIListViewPageControlPositionRightWithMarginThirdOfPageControlWidth,
    UIListViewPageControlPositionRightWithMarginHalfOfPageControlWidth,
    UIListViewPageControlPositionRightWithMarginPageControlWidth,
} UIListViewPageControlPosition;


//  --------loading more data state--------
typedef enum {
    UIListViewLoadMoreDataStateIdle = 0,
    UIListViewLoadMoreDataStatePull,
    UIListViewLoadMoreDataStateRelease,
    UIListViewLoadMoreDataStateLoading,
} UIListViewLoadMoreDataState;


@protocol UIListViewDataSource;
@class UIListView, UIListViewCell;


//  ------------UIListViewDelegate------------
//  Define the style of the scroll view
//  
@protocol UIListViewDelegate <NSObject>

@optional
//  scroll type of list view
//  if UIListViewScrollType is UIListViewScrollTypeCycle,  the number of rows in list view will be fixed, and blocking-scroll will be choiced.
- (UIListViewScrollType)scrollTypeOfListView:(UIListView *)listView;

//  scroll direction of list view
- (UIListViewScrollDirection)scrollDirectonOfListView:(UIListView *)listView;

//  is number of rows fixed?
- (BOOL)isNumberOfRowsFixedInListView:(UIListView *)listView;
//  should load more data
- (BOOL)shouldLoadMoreDataForListView:(UIListView *)listView;
//  custom the specifical size for load more data
- (CGFloat)specificalSizeForLoadMoreDataInListView:(UIListView *)listView;
//  try to load more data for list view
- (void)tryToLoadMoreDataForListView:(UIListView *)listView;

//  blocking-scroll: scrollView will always align left/top when stopping scroll.
- (BOOL)isBlockingScrollForListView:(UIListView *)listView;
//  for blocking-scroll: align by row who has the most visible part.
- (BOOL)doesAlignByMostVisiblePartRowForListView:(UIListView *)listView;

//  pageing-scroll: only scroll one row after once scroll event.
- (BOOL)isPagingScrollForListView:(UIListView *)listView;

//  height for row at index in list view
- (CGFloat)heightForRowInListView:(UIListView *)listView;
//  width for row at index in list view
- (CGFloat)widthForRowInlistView:(UIListView *)listView;


//  Event

//  cell is selected 
- (void)listView:(UIListView *)listView didSelectRowAtIndex:(NSInteger)index;
//  cell is hidden
- (void)listView:(UIListView *)listView didHiddenRowAtIndex:(NSInteger)index;


//  Autoscroll

//  If YES is returned, blocking-scroll will be choiced.
- (BOOL)doesAutoScrollForListView:(UIListView *)listView;
//  time interval between two blocks
- (NSTimeInterval)timeIntervalForListView:(UIListView *)listView;


//  page control

//  does use page control
- (BOOL)doesUsePageControlInListView:(UIListView *)listView;
//  pageControl's positon
- (UIListViewPageControlPosition)pageControlPositionInListView:(UIListView *)listView;
//  frame of page control. if page control's frame is setted, page control's position will be not used.
- (CGRect)pageControlFrameInListView:(UIListView *)listView;
//  page control's background color
- (UIColor *)backgroundColorOfPageControlInListView:(UIListView *)listView;
//  paging control index style
- (UIImage *)normalIndexImageOfPageControlInListView:(UIListView *)listView;
- (UIImage *)highlightIndexImageOfPageControlInListView:(UIListView *)listView;


//  Appearance

//  UIListViewCellSeperatorStyle
- (UIListViewCellSeperatorStyle)seperatorStyleForListView:(UIListView *)listView;
//  seperator width for list view
- (CGFloat)seperatorWidthForListView:(UIListView *)listView;
//  seperator color for list view
- (UIColor *)seperatorColorForListView:(UIListView *)listView;
//  if use custom seperator view, will not use seperator color.
- (UIView *)customSeperatorViewForListView:(UIListView *)listView;


//  UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;                                               // any offset changes

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0);
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;   // called on finger up as we are moving
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;      // called when scroll view grinds to a halt

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView; // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating


- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView;   // return a yes if you want to scroll to the top. if not defined, assumes YES
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;      // called when scrolling animation finished. may be called immediately if already at top


@end


@interface UIListView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) id <UIListViewDataSource> dataSource;
@property (nonatomic, assign) id <UIListViewDelegate>   listViewDelegate;

@property (nonatomic, retain, readwrite) UIView         *background;

//  UITableView
@property (nonatomic, assign) BOOL                      showsVerticalScrollIndicator;
@property (nonatomic, assign) BOOL                      showHorizontalScrollIndicator;

//  Data

//  reloads everything from scratch. redisplays visible rows.
- (void)reloadData;

//  Info

- (NSInteger)numberOfRows;

- (CGRect)rectForRowAtIndex:(NSInteger)index;

- (NSInteger)indexForRowAtPoint:(CGPoint)point;                     // returns nil if point is outside table
- (NSInteger)indexForCell:(UIListViewCell *)cell;                   // returns nil for cell is not visible

- (UIListViewCell *)cellForRowAtIndex:(NSInteger)index;             // returns nil if cell is not visible or index path is out of range

//  scroll to other row
- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollToNearestSelectedRowAnimated:(BOOL)animated;


//  Selection

//  row of selection.
- (NSInteger)indexForSelectedRow;

//  Selects and deselects rows. These methods will not call the delegate methods, nor will it send out a notification.
- (void)selectRowAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)deselectRowAtIndex:(NSInteger)index animated:(BOOL)animated;

//  Used by the delegate to acquire an already allocated cell, in lieu of allocating a new one.
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

//  load more data
- (void)loadMoreDataIsDone;

@end


//  -----------UIListViewDataSource-----------
@protocol UIListViewDataSource <NSObject>

@required
//  number of rows in list view
- (NSInteger)numberOfRowsInListView:(UIListView *)listView;

//  cell for row at index in list view
- (UIListViewCell *)listView:(UIListView *)listVIew cellForRowAtIndex:(NSInteger)index;

@end