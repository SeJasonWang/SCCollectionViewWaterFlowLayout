//
//  SCCollectionViewWaterFlowLayout.h
//  SCCollectionViewWaterFlowLayout
//
//  Created by sichenwang on 16/4/8.
//  Copyright © 2016年 sichenwang. All rights reserved.
//  从上往下布局，指定列数

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const SCCollectionViewWaterFlowSectionHeader;
UIKIT_EXTERN NSString *const SCCollectionViewWaterFlowSectionFooter;

@protocol SCCollectionViewDelegateWaterFlowLayout <UICollectionViewDelegate>
@optional

/** The size in the specified item. default is {50, 50}. */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
/** The number of columns in the specified section. default is 2. */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout numberOfColumnsForSectionAtIndex:(NSInteger)section;
/** The horizontal spacing between items in the specified section. default is 5.0. */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section;
/** The vertical spacing between items in the specified section. default is 5.0. */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section;
/** The margins to apply to content in the specified section. default is {0, 0, 0, 0}. */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetsForSectionAtIndex:(NSInteger)section;
/** The height of the header view in the specified section. default is 0. */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceHeightForHeaderInSection:(NSInteger)section;
/** The height of the footer view in the specified section. default it 0. */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceHeightForFooterInSection:(NSInteger)section;
/** The margins to apply to header view in the specified section. default is {0, 0, 0, 0}. */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetsForHeaderInSection:(NSInteger)section;
/** The margins to apply to footer view in the specified section. default is {0, 0, 0, 0}. */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetsForFooterInSection:(NSInteger)section;
/** Set the property to YES to show background view in the specified section. default is NO. */
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout shouldShowBackgroundViewInSection:(NSInteger)section;
/** The margins to apply to background view in the specified section. default is {0, 0, 0, 0}. */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetsForBackgroundViewInSection:(NSInteger)section;

// more than one header or footer
/** The number of header views in the specified section, if you want to display more than one header. default is 0. */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout numberOfHeadersInSection:(NSInteger)section;
/** The number of footer views in the specified section, if you want to display more than one footer. default is 0. */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout numberOfFootersInSection:(NSInteger)section;
/** The height of the header view in the specified item. default is 0.0. */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceHeightForHeaderAtIndexPath:(NSIndexPath *)indexPath;
/** The height of the footer view in the specified item. default is 0.0. */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceHeightForFooterAtIndexPath:(NSIndexPath *)indexPath;
/** The margins to apply to header view in the specified item. default is {0, 0, 0, 0}. */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetsForHeaderAtIndexPath:(NSIndexPath *)indexPath;
/** The margins to apply to footer view in the specified item. default is {0, 0, 0, 0}. */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetsForFooterAtIndexPath:(NSIndexPath *)indexPath;

// PinToVisibleBounds
/** Set the property to YES to get header in the specified section that pin to the top of the screen while scrolling (similar to UITableView and just support to item 0). */
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout pinToVisibleBoundsForHeaderInSection:(NSInteger)section;
/** Call the method when the header pinned status did change while scrolling. */
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout didChangeHeaderPinnedStatus:(BOOL)isPinned inSection:(NSInteger)section;

// extra function
/** The scale of width devided by collection view width without margins and gaps in the specified item. default is devided averagely. */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout scaleForItemInColumn:(NSInteger)column section:(NSInteger)section;
/** The number of extra columns that occupies except current column in the specified item. default is 0. */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout numberOfExtraColumnsAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SCCollectionViewWaterFlowLayout : UICollectionViewLayout

/** The size to use for cells. default is {50, 50}. */
@property (nonatomic, assign) CGSize itemSize;
/** The number of columns. default is 2. */
@property (nonatomic, assign) NSInteger numberOfColumns;
/** The horizontal spacing between items. default is 5.0. */
@property (nonatomic, assign) CGFloat lineSpacing;
/** The vertical spacing between items. default is 5.0. */
@property (nonatomic, assign) CGFloat interitemSpacing;
/** The margins to apply to content in sections. default is {0, 0, 0, 0}. */
@property (nonatomic, assign) UIEdgeInsets sectionInset;
/** The sizes to use for section headers. default is 0. */
@property (nonatomic, assign) CGFloat headerReferenceHeight;
/** The sizes to use for section footers. default is 0. */
@property (nonatomic, assign) CGFloat footerReferenceHeight;
/** The margins to apply to header view. default is {0, 0, 0, 0}. */
@property (nonatomic, assign) UIEdgeInsets headerInset;
/** The margins to apply to footer view. default is {0, 0, 0, 0}. */
@property (nonatomic, assign) UIEdgeInsets footerInset;
/** The if content needs background view in sections. default is NO. */
@property (nonatomic, assign) BOOL shouldShowBackground;
/** The margins to apply to background view. default is {0, 0, 0, 0}. */
@property (nonatomic, assign) UIEdgeInsets backgroundInset;

// more than one headers or footers
/** The number of headers. if you want to display more than one header. default is 0. */
@property (nonatomic, assign) NSInteger numberOfHeaders;
/** The number of footers. if you want to display more than one footer. default is 0. */
@property (nonatomic, assign) NSInteger numberOfFooters;

// PinToVisibleBounds
@property (nonatomic, assign) CGFloat sectionHeadersPinToVisibleBoundsInsetTop;
/** Set the property to YES to get headers that pin to the top of the screen while scrolling (similar to UITableView and just support to item 0). */
@property (nonatomic) BOOL sectionHeadersPinToVisibleBounds;

@end
