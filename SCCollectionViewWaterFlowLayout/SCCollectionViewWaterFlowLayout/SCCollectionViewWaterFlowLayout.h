//
//  SCCollectionViewWaterFlowLayout.h
//  SCCollectionViewWaterFlowLayout
//
//  Created by sichenwang on 16/4/8.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const SCCollectionViewWaterFlowSectionHeader;
UIKIT_EXTERN NSString *const SCCollectionViewWaterFlowSectionFooter;

@protocol SCCollectionViewDelegateWaterFlowLayout <UICollectionViewDelegate>
@optional

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout numberOfColumnsForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetsForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceHeightForHeaderInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceHeightForFooterInSection:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetsForHeaderInSection:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetsForFooterInSection:(NSInteger)section;
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout shouldShowBackgroundViewInSection:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetsForBackgroundViewInSection:(NSInteger)section;

// more than one headers or footers
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout numberOfHeadersInSection:(NSInteger)section;
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout numberOfFootersInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceHeightForHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceHeightForFooterAtIndexPath:(NSIndexPath *)indexPath;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetsForHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetsForFooterAtIndexPath:(NSIndexPath *)indexPath;

// PinToVisibleBounds
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout pinToVisibleBoundsForHeaderInSection:(NSInteger)section;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout didChangeHeaderPinnedStatus:(BOOL)isPinned inSection:(NSInteger)section;

// extra function
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout scaleForItemInColumn:(NSInteger)column section:(NSInteger)section;
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout numberOfExtraColumnsAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SCCollectionViewWaterFlowLayout : UICollectionViewLayout

@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) NSInteger numberOfColumns;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) CGFloat interitemSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;
@property (nonatomic, assign) CGFloat headerReferenceHeight;
@property (nonatomic, assign) CGFloat footerReferenceHeight;
@property (nonatomic, assign) UIEdgeInsets headerInset;
@property (nonatomic, assign) UIEdgeInsets footerInset;
@property (nonatomic, assign) BOOL shouldShowBackground;
@property (nonatomic, assign) UIEdgeInsets backgroundInset;

// more than one headers or footers
@property (nonatomic, assign) NSInteger numberOfHeaders;
@property (nonatomic, assign) NSInteger numberOfFooters;

// PinToVisibleBounds
@property (nonatomic) BOOL sectionHeadersPinToVisibleBounds;

@end
