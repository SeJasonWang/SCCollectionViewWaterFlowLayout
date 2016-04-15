//
//  SCCollectionViewWaterFlowLayout.m
//  SCCollectionViewWaterFlowLayout
//
//  Created by sichenwang on 16/4/8.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCCollectionViewWaterFlowLayout.h"
#import "SCPinHeader.h"
#import "SCSectionBackgroundView.h"

static const CGSize kSCDefaultItemSize = {50, 50};
static const NSInteger kSCDefaultNumberOfColumns = 2;
static const NSInteger kSCDefaultNumberOfHeaders = 0;
static const NSInteger kSCDefaultNumberOfFooters = 0;
static const CGFloat kSCDefaultLineSpacing      = 5;
static const CGFloat kSCDefaultInteritemSpacing = 5;
static const UIEdgeInsets kSCDefaultSectionInsets    = {0, 0, 0, 0};
static const UIEdgeInsets kSCDefaultBackgroundInsets = {0, 0, 0, 0};
static const UIEdgeInsets kSCDefaultHeaderInsets     = {0, 0, 0, 0};
static const UIEdgeInsets kSCDefaultFooterInsets     = {0, 0, 0, 0};
static const CGFloat kSCDefaultHeaderReferenceHeight = 0.0;
static const CGFloat kSCDefaultFooterReferenceHeight = 0.0;
static const BOOL kSCDefaultShouldShowBackgroundView = NO;
static const BOOL kSCDefaultPinToVisibleBounds = NO;
static const NSInteger kUnionCount = 20;

NSString *const SCCollectionViewWaterFlowSectionHeader = @"SCCollectionViewWaterFlowSectionHeader";
NSString *const SCCollectionViewWaterFlowSectionFooter = @"SCCollectionViewWaterFlowSectionFooter";
NSString *const SCCollectionViewWaterFlowSectionBackgroundView = @"SCCollectionViewWaterFlowSectionBackgroundView";

#define fequalzero(a) (fabs(a) < FLT_EPSILON)

struct {
    BOOL itemSize;
    BOOL numberOfColumns;
    BOOL lineSpacing;
    BOOL interitemSpacing;
    BOOL insetsForSection;
    BOOL shouldShowBackground;
    BOOL insetsForBackground;
    BOOL heightForHeader;
    BOOL heightForFooter;
    BOOL insetsForHeader;
    BOOL insetsForFooter;
    BOOL numberOfHeaders;
    BOOL numberOfFooters;
    BOOL heightForHeaderAtIndexPath;
    BOOL heightForFooterAtIndexPath;
    BOOL insetsForHeaderAtIndexPath;
    BOOL insetsForFooterAtIndexPath;
    BOOL scaleForItemWidth;
    BOOL numberExtraOfColumns;
    BOOL pinToHeaderVisibleBounds;
    BOOL didChangeHeaderPinnedStatus;
} respondsToSelector;

@interface SCCollectionViewWaterFlowLayout()

@property (nonatomic, weak) id<SCCollectionViewDelegateWaterFlowLayout> delegate;

@property (nonatomic, assign) CGFloat y;
@property (nonatomic, strong) NSMutableArray *ys;
@property (nonatomic, strong) NSMutableArray *itemAttrs;
@property (nonatomic, strong) NSMutableArray *unionRects;
@property (nonatomic, strong) NSMutableArray *showingAttrs;

// PinToVisibleBounds
@property (nonatomic, strong) NSMutableArray *pinHeaders;
@property (nonatomic, strong) NSMutableArray *showingPinHeaders;
@property (nonatomic, assign, getter=isUpdatingPinHeader) BOOL updatingPinHeader;
@property (nonatomic, assign) CGRect preRect;

@end

@implementation SCCollectionViewWaterFlowLayout

#pragma mark - <Override Methods>

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(self.collectionView.bounds)) {
        return YES;
    } else if (self.pinHeaders.count) {
        self.updatingPinHeader = YES;
        [self.showingPinHeaders removeAllObjects];
        for (SCPinHeader *pinHeader in self.pinHeaders) {
            if (CGRectIntersectsRect(pinHeader.rect, newBounds)) {
                [self layoutPinHeader:pinHeader offsetY:newBounds.origin.y];
                [self.showingPinHeaders addObject:pinHeader.attributes];
            } else {
                if (self.showingPinHeaders.count) break;
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (void)prepareLayout {
    [super prepareLayout];
    
    NSInteger numOfSections = [self.collectionView numberOfSections];
    if (numOfSections && !self.isUpdatingPinHeader) {
        self.delegate = (id<SCCollectionViewDelegateWaterFlowLayout>)self.collectionView.delegate;
        [self registerClass:[SCSectionBackgroundView class] forDecorationViewOfKind:SCCollectionViewWaterFlowSectionBackgroundView];
        self.y = 0.0;
        self.ys = [NSMutableArray array];
        self.itemAttrs = [NSMutableArray array];
        self.showingAttrs = [NSMutableArray array];
        self.unionRects = [NSMutableArray array];
        self.pinHeaders = [NSMutableArray array];
        self.showingPinHeaders = [NSMutableArray array];
        for (NSUInteger section = 0; section < numOfSections; section++) {
            [self layoutHeadersInSection:section];
            [self layoutItemsInSection:section];
            [self layoutFootersInSection:section];
        }
        [self uniteRects];
    }
}

- (CGSize)collectionViewContentSize {
    CGFloat contentHeight = MAX(self.y, [self maxYFromYs]);
    CGSize contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, contentHeight);
    if (self.pinHeaders.count) {
        SCPinHeader *lastSectionPinned = self.pinHeaders.lastObject;
        lastSectionPinned.endY = contentHeight - lastSectionPinned.attributes.frame.size.height;
        lastSectionPinned.rect = CGRectMake(0, lastSectionPinned.startY, self.collectionView.frame.size.width, contentHeight - lastSectionPinned.startY);
        if (CGRectIntersectsRect(lastSectionPinned.rect, CGRectMake(0, self.collectionView.contentOffset.y, self.collectionView.frame.size.width, self.collectionView.frame.size.height))) {
            [self layoutPinHeader:lastSectionPinned offsetY:self.collectionView.contentOffset.y];
            [self.showingPinHeaders addObject:lastSectionPinned.attributes];
        }
    }
    return contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attrs = [NSMutableArray array];
    if (self.showingPinHeaders.count) {
        [attrs addObjectsFromArray:self.showingPinHeaders];
    }
    if (!CGRectEqualToRect(self.preRect, rect) || !self.isUpdatingPinHeader) {
        self.preRect = rect;
        [self.showingAttrs removeAllObjects];
        NSInteger i;
        NSInteger begin = 0, end = self.unionRects.count;
        for (i = 0; i < self.unionRects.count; i++) {
            if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
                begin = i * kUnionCount;
                break;
            }
        }
        for (i = self.unionRects.count - 1; i >= 0; i--) {
            if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
                end = MIN((i + 1) * kUnionCount, self.itemAttrs.count);
                break;
            }
        }
        for (i = begin; i < end; i++) {
            UICollectionViewLayoutAttributes *attr = self.itemAttrs[i];
            if (CGRectIntersectsRect(rect, attr.frame)) {
                [self.showingAttrs addObject:attr];
            }
        }
    }
    [attrs addObjectsFromArray:self.showingAttrs];
    self.updatingPinHeader = NO;
    return attrs;
}

#pragma mark - <Private Method>

/** 初始化所有header属性 */
- (void)layoutHeadersInSection:(NSInteger)section {
    CGFloat headerHeight = [self referenceHeightForHeaderInSection:section];
    NSInteger numOfHeaders = [self numberOfHeadersInSection:section];
    NSInteger number = numOfHeaders ? : (headerHeight ? 1 : 0);
    if (number) {
        for (NSInteger item = 0; item < number; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SCCollectionViewWaterFlowSectionHeader withIndexPath:indexPath];
            attr.zIndex = 10;
            UIEdgeInsets insets = UIEdgeInsetsZero;
            CGFloat h = 0;
            if (item == 0) {
                UIEdgeInsets insetsInSection = [self insetsForHeaderInSection:section];
                UIEdgeInsets insetsAtIndexPath = [self insetsForHeaderAtIndexPath:indexPath];
                insets = !UIEdgeInsetsEqualToEdgeInsets(insetsInSection, UIEdgeInsetsZero) ? insetsInSection : insetsAtIndexPath;
                h = headerHeight ? : [self referenceHeightForHeaderAtIndexPath:indexPath];
            } else {
                insets = [self insetsForHeaderAtIndexPath:indexPath];
                h = [self referenceHeightForHeaderAtIndexPath:indexPath];
            }
            CGFloat x = insets.left;
            CGFloat y = self.y + insets.top;
            CGFloat w = [UIScreen mainScreen].bounds.size.width - insets.left - insets.right;
            attr.frame = CGRectMake(x, y, w, h);
            self.y = y + h + insets.bottom;
            if ([self pinToHeaderVisibleBoundsInSection:section] && item == 0) {
                attr.zIndex = 20;
                SCPinHeader *sectionPinned = [[SCPinHeader alloc] init];
                sectionPinned.attributes = attr;
                sectionPinned.startY = y;
                if (self.pinHeaders.count) {
                    SCPinHeader *preSectionPinned = self.pinHeaders.lastObject;
                    preSectionPinned.endY = sectionPinned.startY - preSectionPinned.attributes.frame.size.height;
                    preSectionPinned.rect = CGRectMake(0, preSectionPinned.startY, self.collectionView.frame.size.width, sectionPinned.startY - preSectionPinned.startY);
                    if (CGRectIntersectsRect(preSectionPinned.rect, CGRectMake(0, self.collectionView.contentOffset.y, self.collectionView.frame.size.width, self.collectionView.frame.size.height))) {
                        [self layoutPinHeader:preSectionPinned offsetY:self.collectionView.contentOffset.y];
                        [self.showingPinHeaders addObject:preSectionPinned.attributes];
                    }
                }
                [self.pinHeaders addObject:sectionPinned];
            } else {
                [self.itemAttrs addObject:attr];
            }
        }
    }
}

/** 初始化所有item和background属性 */
- (void)layoutItemsInSection:(NSInteger)section {
    CGFloat startY = self.y;
    [self updateY:startY numOfColumns:[self numberOfColumnsForSectionAtIndex:section]];
    NSInteger columns = [self numberOfColumnsForSectionAtIndex:section];
    UIEdgeInsets insets = [self insetsForSectionAtIndex:section];
    CGFloat interitemSpacing = [self interitemSpacingForSectionAtIndex:section];
    CGFloat totalW = (self.collectionView.bounds.size.width - insets.left - insets.right - (columns - 1) * interitemSpacing);
    NSUInteger numOfItems = [self.collectionView numberOfItemsInSection:section];
    NSMutableArray *scales = nil;
    if (respondsToSelector.scaleForItemWidth) {
        scales = [NSMutableArray array];
        for (NSInteger column = 0; column < columns; column++) {
            [scales addObject:@([self scaleForItemInColumn:column section:section])];
        }
    }
    BOOL isFirstRow = YES; // 第一行不需要行距
    NSInteger negativeCount = 0;
    for (NSUInteger item = 0; item < numOfItems; item++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
        CGSize itemSize = [self sizeForItemAtIndexPath:indexPath];
        if (fequalzero(itemSize.height) || fequalzero(itemSize.width)) {
            NSLog(@"negative or zero sizes in the %zd section %zd item. We're considering the collapse unintentional and ignoring the collection view cell.", section, item);
            if (isFirstRow) negativeCount++;
            continue;
        }
        // 找到最短的那列
        CGFloat minY = [self.ys.firstObject doubleValue];
        NSInteger columnOfMinY = 0;
        for (NSNumber *y in self.ys) {
            CGFloat temp = [y doubleValue];
            if (temp < minY) {
                minY = temp;
                columnOfMinY = [self.ys indexOfObject:y];
            }
        }
        // 计算itemW和itemX
        CGFloat itemW = 0.0;
        CGFloat itemX = insets.left;
        CGFloat scale = 0.0;
        if (scales.count) {
            scale = [scales[columnOfMinY] doubleValue];
        }
        if (scale) {
            itemW = totalW * scale;
            for (NSInteger column = 0; column < columnOfMinY; column++) {
                itemX += totalW * [scales[column] doubleValue] + interitemSpacing;
            }
        } else {
            itemW = totalW / columns;
            itemX += columnOfMinY * (itemW + interitemSpacing);
        }
        NSInteger numOfUnitedItems = [self numberOfExtraColumnsAtIndexPath:indexPath];
        if (numOfUnitedItems) {
            if (columnOfMinY + 1 + numOfUnitedItems > columns) {
                numOfUnitedItems = columns - columnOfMinY - 1;
            }
            for (NSInteger column = columnOfMinY + 1; column < columnOfMinY + 1 + numOfUnitedItems; column++) {
                if (scale) {
                    itemW += totalW * [scales[column] doubleValue] + interitemSpacing;
                } else {
                    itemW += totalW / columns + interitemSpacing;
                }
            }
        }
        // 计算itemY
        if (isFirstRow) {
            NSInteger flag = - negativeCount;
            for (NSInteger column = 0; column < indexPath.item; column++) {
                flag += [self numberOfExtraColumnsAtIndexPath:[NSIndexPath indexPathForItem:column inSection:indexPath.section]];
            }
            if (indexPath.item + flag >= columns) isFirstRow = NO;
        }
        CGFloat itemY = isFirstRow ? minY + insets.top : minY + [self lineSpacingForSectionAtIndex:indexPath.section];
        // 计算itemH
        CGFloat itemH = itemSize.height * itemW / itemSize.width;
        // 创建属性
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attr.frame = CGRectMake(itemX, itemY, itemW, itemH);
        // 更新y
        self.ys[columnOfMinY] = @(CGRectGetMaxY(attr.frame));
        // item跨列后，更新数组对应的y值
        if (numOfUnitedItems) {
            for (NSInteger column = columnOfMinY + 1; column < columnOfMinY + 1 + numOfUnitedItems; column++) {
                self.ys[column] = @(CGRectGetMaxY(attr.frame));
            }
        }
        [self.itemAttrs addObject:attr];
    }
    CGFloat endY = [self maxYFromYs] + [self insetsForSectionAtIndex:section].bottom;
    self.y = endY;
    // background
    if ([self needsBackgroundViewInSection:section]) {
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SCCollectionViewWaterFlowSectionBackgroundView withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        UIEdgeInsets insets = [self insetsForBackgroundViewInSection:section];
        CGFloat x = insets.left;
        CGFloat y = startY + insets.top;
        CGFloat w = [UIScreen mainScreen].bounds.size.width - insets.left - insets.right;
        CGFloat h = endY - startY - insets.top - insets.bottom;
        attr.frame = CGRectMake(x, y, w, h);
        attr.zIndex = -1;
        [self.itemAttrs addObject:attr];
    }
}

/** 初始化所有footer属性 */
- (void)layoutFootersInSection:(NSInteger)section {
    CGFloat footerHeight = [self referenceHeightForFooterInSection:section];
    NSInteger numOfFooters = [self numberOfFootersInSection:section];
    NSInteger number = numOfFooters ? : (footerHeight ? 1 : 0);
    if (number) {
        for (NSInteger item = 0; item < number; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SCCollectionViewWaterFlowSectionFooter withIndexPath:indexPath];
            attr.zIndex = 10;
            UIEdgeInsets insets = UIEdgeInsetsZero;
            CGFloat h = 0;
            if (footerHeight) {
                UIEdgeInsets insetsInSection = [self insetsForFooterInSection:section];
                UIEdgeInsets insetsAtIndexPath = [self insetsForFooterAtIndexPath:indexPath];
                insets = !UIEdgeInsetsEqualToEdgeInsets(insetsInSection, UIEdgeInsetsZero) ? insetsInSection : insetsAtIndexPath;
                h = footerHeight ? : [self referenceHeightForHeaderAtIndexPath:indexPath];
            } else {
                insets = [self insetsForFooterAtIndexPath:indexPath];
                h = [self referenceHeightForFooterAtIndexPath:indexPath];
            }
            CGFloat x = insets.left;
            CGFloat y = self.y + insets.top;
            CGFloat w = [UIScreen mainScreen].bounds.size.width - insets.left - insets.right;
            attr.frame = CGRectMake(x, y, w, h);
            self.y = y + h + insets.bottom;
            [self.itemAttrs addObject:attr];
        }
    }
}

/** 联合rect，用来快速定位 */
- (void)uniteRects {
    NSInteger idx = 0;
    NSInteger itemCounts = [self.itemAttrs count];
    while (idx < itemCounts) {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)self.itemAttrs[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + kUnionCount, itemCounts);
        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)self.itemAttrs[i]).frame);
        }
        idx = rectEndIndex;
        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
}

/** 定位吸附位置 */
- (void)layoutPinHeader:(SCPinHeader *)pinHeader offsetY:(CGFloat)offsetY {
    offsetY += self.sectionHeadersPinToVisibleBoundsInsetTop;
    if (respondsToSelector.didChangeHeaderPinnedStatus) {
        if (offsetY <= pinHeader.startY || offsetY >= pinHeader.endY) {
            if (pinHeader.y > pinHeader.startY && pinHeader.y < pinHeader.endY) {
                [self.delegate collectionView:self.collectionView layout:self didChangeHeaderPinnedStatus:NO inSection:pinHeader.attributes.indexPath.section];
            }
        } else {
            if (pinHeader.y <= pinHeader.startY || pinHeader.y >= pinHeader.endY) {
                [self.delegate collectionView:self.collectionView layout:self didChangeHeaderPinnedStatus:YES inSection:pinHeader.attributes.indexPath.section];
            }
        }
    }
    if (offsetY <= pinHeader.startY) {
        pinHeader.y = pinHeader.startY;
    } else if (offsetY >= pinHeader.endY) {
        pinHeader.y = pinHeader.endY;
    } else {
        pinHeader.y = offsetY;
    }
}

/**
 *  获取最长的那一列的y值
 */
- (CGFloat)maxYFromYs {
    if (!self.ys.count) {
        [self.ys addObject:@(self.y)];
        return self.y;
    }
    CGFloat maxY = [self.ys[0] doubleValue];
    if (self.ys.count > 1) {
        for (NSNumber *y in self.ys) {
            CGFloat temp = [y doubleValue];
            if (temp > maxY) {
                maxY = temp;
            }
        }
    }
    return maxY;
}

/**
 *  更新每列的y值
 */
- (void)updateY:(CGFloat)y {
    for (NSInteger i = 0; i < self.ys.count; i++) {
        self.ys[i] = @(y);
    }
}

/**
 *  更新每列的y值，并重置列数
 */
- (void)updateY:(CGFloat)y numOfColumns:(NSInteger)numOfColumns {
    if (numOfColumns) {
        [self.ys removeAllObjects];
        for (NSInteger i = 0; i < numOfColumns; i++) {
            [self.ys addObject:@(y)];
        }
    } else {
        [self updateY:y];
    }
}

#pragma mark - <Getter>

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (respondsToSelector.itemSize) {
        return [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
    } else if (!CGSizeEqualToSize(self.itemSize, CGSizeZero)) {
        return self.itemSize;
    }
    return kSCDefaultItemSize;
}

- (NSInteger)numberOfColumnsForSectionAtIndex:(NSInteger)section {
    if (respondsToSelector.numberOfColumns) {
        return [self.delegate collectionView:self.collectionView layout:self numberOfColumnsForSectionAtIndex:section];
    } else if (self.numberOfColumns) {
        return self.numberOfColumns;
    }
    return kSCDefaultNumberOfColumns;
}

- (CGFloat)lineSpacingForSectionAtIndex:(NSInteger)section {
    if (respondsToSelector.lineSpacing) {
        return [self.delegate collectionView:self.collectionView layout:self lineSpacingForSectionAtIndex:section];
    } else if (self.lineSpacing) {
        return self.lineSpacing;
    }
    return kSCDefaultLineSpacing;
}

- (CGFloat)interitemSpacingForSectionAtIndex:(NSInteger)section {
    if (respondsToSelector.interitemSpacing) {
        return [self.delegate collectionView:self.collectionView layout:self interitemSpacingForSectionAtIndex:section];
    } else if (self.interitemSpacing) {
        return self.interitemSpacing;
    }
    return kSCDefaultInteritemSpacing;
}

- (UIEdgeInsets)insetsForSectionAtIndex:(NSInteger)section {
    if (respondsToSelector.insetsForSection) {
        return [self.delegate collectionView:self.collectionView layout:self insetsForSectionAtIndex:section];
    } else if (!UIEdgeInsetsEqualToEdgeInsets(self.sectionInset, UIEdgeInsetsZero)) {
        return self.sectionInset;
    }
    return kSCDefaultSectionInsets;
}

- (BOOL)needsBackgroundViewInSection:(NSInteger)section {
    if (respondsToSelector.shouldShowBackground) {
        return [self.delegate collectionView:self.collectionView layout:self shouldShowBackgroundViewInSection:section];
    } else if (self.shouldShowBackground) {
        return self.shouldShowBackground;
    }
    return kSCDefaultShouldShowBackgroundView;
}

- (UIEdgeInsets)insetsForBackgroundViewInSection:(NSInteger)section {
    if (respondsToSelector.insetsForBackground) {
        return [self.delegate collectionView:self.collectionView layout:self insetsForBackgroundViewInSection:section];
    } else if (!UIEdgeInsetsEqualToEdgeInsets(self.backgroundInset, UIEdgeInsetsZero)) {
        return self.backgroundInset;
    }
    return kSCDefaultBackgroundInsets;
}

- (UIEdgeInsets)insetsForHeaderInSection:(NSInteger)section {
    if (respondsToSelector.insetsForHeader) {
        return [self.delegate collectionView:self.collectionView layout:self insetsForHeaderInSection:section];
    } else if (!UIEdgeInsetsEqualToEdgeInsets(self.headerInset, UIEdgeInsetsZero)) {
        return self.headerInset;
    }
    return kSCDefaultHeaderInsets;
}

- (UIEdgeInsets)insetsForFooterInSection:(NSInteger)section {
    if (respondsToSelector.insetsForFooter) {
        return [self.delegate collectionView:self.collectionView layout:self insetsForFooterInSection:section];
    } else if (!UIEdgeInsetsEqualToEdgeInsets(self.footerInset, UIEdgeInsetsZero)) {
        return self.footerInset;
    }
    return kSCDefaultFooterInsets;
}

- (CGFloat)referenceHeightForHeaderInSection:(NSInteger)section {
    if (respondsToSelector.heightForHeader) {
        return [self.delegate collectionView:self.collectionView layout:self referenceHeightForHeaderInSection:section];
    } else if (self.headerReferenceHeight) {
        return self.headerReferenceHeight;
    }
    return kSCDefaultHeaderReferenceHeight;
}

- (CGFloat)referenceHeightForFooterInSection:(NSInteger)section {
    if (respondsToSelector.heightForFooter) {
        return [self.delegate collectionView:self.collectionView layout:self referenceHeightForFooterInSection:section];
    } else if (self.footerReferenceHeight) {
        return self.footerReferenceHeight;
    }
    return kSCDefaultFooterReferenceHeight;
}

- (NSInteger)numberOfHeadersInSection:(NSInteger)section {
    if (respondsToSelector.numberOfHeaders) {
        return [self.delegate collectionView:self.collectionView layout:self numberOfHeadersInSection:section];
    } else if (self.numberOfHeaders) {
        return self.numberOfHeaders;
    }
    return kSCDefaultNumberOfHeaders;
}

- (NSInteger)numberOfFootersInSection:(NSInteger)section {
    if (respondsToSelector.numberOfFooters) {
        return [self.delegate collectionView:self.collectionView layout:self numberOfFootersInSection:section];
    } else if (self.numberOfFooters) {
        return self.numberOfFooters;
    }
    return kSCDefaultNumberOfFooters;
}

- (CGFloat)referenceHeightForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    if (respondsToSelector.heightForHeaderAtIndexPath) {
        return [self.delegate collectionView:self.collectionView layout:self referenceHeightForHeaderAtIndexPath:indexPath];
    } else if (self.headerReferenceHeight) {
        return self.headerReferenceHeight;
    }
    return kSCDefaultHeaderReferenceHeight;
}

- (CGFloat)referenceHeightForFooterAtIndexPath:(NSIndexPath *)indexPath {
    if (respondsToSelector.heightForFooterAtIndexPath) {
        return [self.delegate collectionView:self.collectionView layout:self referenceHeightForFooterAtIndexPath:indexPath];
    } else if (self.footerReferenceHeight) {
        return self.footerReferenceHeight;
    }
    return kSCDefaultFooterReferenceHeight;
}

- (UIEdgeInsets)insetsForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    if (respondsToSelector.insetsForHeaderAtIndexPath) {
        return [self.delegate collectionView:self.collectionView layout:self insetsForHeaderAtIndexPath:indexPath];
    } else if (!UIEdgeInsetsEqualToEdgeInsets(self.headerInset, UIEdgeInsetsZero)) {
        return self.headerInset;
    }
    return kSCDefaultHeaderInsets;
}

- (UIEdgeInsets)insetsForFooterAtIndexPath:(NSIndexPath *)indexPath {
    if (respondsToSelector.insetsForFooterAtIndexPath) {
        return [self.delegate collectionView:self.collectionView layout:self insetsForFooterAtIndexPath:indexPath];
    } else if (!UIEdgeInsetsEqualToEdgeInsets(self.footerInset, UIEdgeInsetsZero)) {
        return self.footerInset;
    }
    return kSCDefaultFooterInsets;
}

- (CGFloat)scaleForItemInColumn:(NSInteger)column section:(NSInteger)section {
    if (respondsToSelector.scaleForItemWidth) {
        return [self.delegate collectionView:self.collectionView layout:self scaleForItemInColumn:column section:section];
    }
    return 0.0;
}

- (NSInteger)numberOfExtraColumnsAtIndexPath:(NSIndexPath *)indexPath {
    if (respondsToSelector.numberExtraOfColumns) {
        return [self.delegate collectionView:self.collectionView layout:self numberOfExtraColumnsAtIndexPath:indexPath];
    }
    return 0;
}

- (BOOL)pinToHeaderVisibleBoundsInSection:(NSInteger)section {
    if (respondsToSelector.pinToHeaderVisibleBounds) {
        return [self.delegate collectionView:self.collectionView layout:self pinToVisibleBoundsForHeaderInSection:section];
    } else if (self.sectionHeadersPinToVisibleBounds) {
        return self.sectionHeadersPinToVisibleBounds;
    }
    return kSCDefaultPinToVisibleBounds;
}

#pragma mark - <Setter>

- (void)setDelegate:(id<SCCollectionViewDelegateWaterFlowLayout>)delegate {
    _delegate = delegate;
    respondsToSelector.itemSize = [delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)];
    respondsToSelector.numberOfColumns = [delegate respondsToSelector:@selector(collectionView:layout:numberOfColumnsForSectionAtIndex:)];
    respondsToSelector.lineSpacing = [delegate respondsToSelector:@selector(collectionView:layout:lineSpacingForSectionAtIndex:)];
    respondsToSelector.interitemSpacing = [delegate respondsToSelector:@selector(collectionView:layout:interitemSpacingForSectionAtIndex:)];
    respondsToSelector.insetsForSection = [delegate respondsToSelector:@selector(collectionView:layout:insetsForSectionAtIndex:)];
    respondsToSelector.shouldShowBackground = [delegate respondsToSelector:@selector(collectionView:layout:shouldShowBackgroundViewInSection:)];
    respondsToSelector.insetsForBackground = [delegate respondsToSelector:@selector(collectionView:layout:insetsForBackgroundViewInSection:)];
    respondsToSelector.heightForHeader = [delegate respondsToSelector:@selector(collectionView:layout:referenceHeightForHeaderInSection:)];
    respondsToSelector.heightForFooter = [delegate respondsToSelector:@selector(collectionView:layout:referenceHeightForFooterInSection:)];
    respondsToSelector.insetsForHeader = [delegate respondsToSelector:@selector(collectionView:layout:insetsForHeaderInSection:)];
    respondsToSelector.insetsForFooter = [delegate respondsToSelector:@selector(collectionView:layout:insetsForFooterInSection:)];
    respondsToSelector.numberOfHeaders = [delegate respondsToSelector:@selector(collectionView:layout:numberOfHeadersInSection:)];
    respondsToSelector.numberOfFooters = [delegate respondsToSelector:@selector(collectionView:layout:numberOfFootersInSection:)];
    respondsToSelector.heightForHeaderAtIndexPath = [delegate respondsToSelector:@selector(collectionView:layout:referenceHeightForHeaderAtIndexPath:)];
    respondsToSelector.heightForFooterAtIndexPath = [delegate respondsToSelector:@selector(collectionView:layout:referenceHeightForFooterAtIndexPath:)];
    respondsToSelector.insetsForHeaderAtIndexPath = [delegate respondsToSelector:@selector(collectionView:layout:insetsForHeaderAtIndexPath:)];
    respondsToSelector.insetsForFooterAtIndexPath = [delegate respondsToSelector:@selector(collectionView:layout:insetsForFooterAtIndexPath:)];
    respondsToSelector.scaleForItemWidth = [delegate respondsToSelector:@selector(collectionView:layout:scaleForItemInColumn:section:)];
    respondsToSelector.numberExtraOfColumns = [delegate respondsToSelector:@selector(collectionView:layout:numberOfExtraColumnsAtIndexPath:)];
    respondsToSelector.pinToHeaderVisibleBounds = [delegate respondsToSelector:@selector(collectionView:layout:pinToVisibleBoundsForHeaderInSection:)];
    respondsToSelector.didChangeHeaderPinnedStatus = [delegate respondsToSelector:@selector(collectionView:layout:didChangeHeaderPinnedStatus:inSection:)];
}

@end
