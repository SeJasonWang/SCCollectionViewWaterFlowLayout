//
//  ViewController.m
//  SCCollectionViewWaterFlowLayout
//
//  Created by sichenwang on 16/4/8.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "ViewController.h"
#import "SCCollectionViewWaterFlowLayout.h"
#import "SCTestCell.h"
#import "SCTestModel.h"
#import "JSONModel.h"
#import "SCCollectionReusableView.h"

static NSString * const CellId = @"CellId";
static NSString * const ReusableViewID = @"ReusableView";

@interface ViewController ()<UICollectionViewDataSource, SCCollectionViewDelegateWaterFlowLayout>

@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createDataList];
    [self createCollectionView];
}

- (void)createDataList {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"2.plist" ofType:nil];
    [self.dataList addObjectsFromArray:[SCTestModel arrayOfModelsFromDictionaries:[NSArray arrayWithContentsOfFile:file]]];
}

- (void)createCollectionView {
    SCCollectionViewWaterFlowLayout *layout = [[SCCollectionViewWaterFlowLayout alloc] init];
    // 设置默认值
    //    layout.numberOfColumns = 4;
    layout.lineSpacing = 8.0;
    layout.interitemSpacing = 8.0;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.shouldShowBackground = YES;
    layout.backgroundInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.headerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.footerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerReferenceHeight = 40.0;
    layout.footerReferenceHeight = 20.0;
    layout.numberOfHeaders = 2;
    layout.numberOfFooters = 3;
    //    layout.sectionHeadersPinToVisibleBounds = YES;
    layout.sectionHeadersPinToVisibleBoundsInsetTop = 50;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.contentOffset = CGPointMake(0, 720);
    [collectionView registerNib:[UINib nibWithNibName:@"SCTestCell" bundle:nil] forCellWithReuseIdentifier:CellId];
    [collectionView registerNib:[UINib nibWithNibName:@"SCCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:SCCollectionViewWaterFlowSectionHeader withReuseIdentifier:@"ReusableView"];
    [collectionView registerNib:[UINib nibWithNibName:@"SCCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:SCCollectionViewWaterFlowSectionFooter withReuseIdentifier:@"ReusableView"];
    [self.view addSubview:collectionView];
}

#pragma mark - <Getter Setter>

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 5000;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ((section < 6 ? section : 5) + 5) * 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SCTestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellId forIndexPath:indexPath];
    cell.model = self.dataList[indexPath.item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SCCollectionReusableView *reusableView = nil;
    if ([kind isEqualToString:SCCollectionViewWaterFlowSectionHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:ReusableViewID forIndexPath:indexPath];
        reusableView.titleLabel.text = [NSString stringWithFormat:@"Header%zd",indexPath.item+1];
        reusableView.backgroundColor = [UIColor brownColor];
        if (indexPath.section == 0) {
            reusableView.backgroundColor = [UIColor redColor];
        } else if (indexPath.section == 1) {
            reusableView.backgroundColor = [UIColor greenColor];
        } else if (indexPath.section == 2) {
            reusableView.backgroundColor = [UIColor grayColor];
        } else if (indexPath.section == 3) {
            reusableView.backgroundColor = [UIColor blueColor];
        } else if (indexPath.section == 4) {
            reusableView.backgroundColor = [UIColor purpleColor];
        }
    } else if ([kind isEqualToString:SCCollectionViewWaterFlowSectionFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:ReusableViewID forIndexPath:indexPath];
        reusableView.titleLabel.text = [NSString stringWithFormat:@"Footer%zd",indexPath.item+1];
        reusableView.backgroundColor = [UIColor brownColor];
        if (indexPath.section == 0) {
            reusableView.backgroundColor = [UIColor purpleColor];
        } else if (indexPath.section == 1) {
            reusableView.backgroundColor = [UIColor yellowColor];
        } else if (indexPath.section == 2) {
            reusableView.backgroundColor = [UIColor blueColor];
        } else if (indexPath.section == 3) {
            reusableView.backgroundColor = [UIColor grayColor];
        } else if (indexPath.section == 4) {
            reusableView.backgroundColor = [UIColor redColor];
        }
    }
    return reusableView;
}

#pragma mark - <SCCollectionViewFlowLayoutDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 如果传入非法的size，layout会忽略对应的cell，并打印如下警告，建议不要传入非法的size
    // negative or zero sizes in the section 0 item 0. We're considering the collapse unintentional and ignoring the collection view cell.
    if (indexPath.section == 0 && indexPath.item == 0) {
        return CGSizeZero;
    }
    SCTestModel *model = self.dataList[indexPath.item];
    return CGSizeMake(model.w, model.h);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout numberOfColumnsForSectionAtIndex:(NSInteger)section {
    return (section < 6 ? section : 5) + 2;
}

// 为某个section的每一列设置特定的列宽
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout scaleForItemInColumn:(NSInteger)column section:(NSInteger)section {
    if (section == 0) {
        switch (column) {
            case 0:
                return 0.4;
                break;
            case 1:
                return 0.6;
                break;
        }
    }
    if (section == 1) {
        switch (column) {
            case 0:
                return 0.5;
                break;
            case 1:
                return 0.2;
                break;
            case 2:
                return 0.3;
                break;
        }
    }
    return 0;
}

// 为某个item额外往右侧跨几列的区域来显示
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout numberOfExtraColumnsAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return 2; // 如果把传入非法size对应的cell进行跨列，则无效
    }
    if (indexPath.section == 0 && indexPath.item == 2) {
        return 30; // 当前cell已经是最右侧那列，此时额外跨的行数超出最大的限制，则按最大可跨列数0计算
    }
    if (indexPath.section == 1 && indexPath.item == 0) {
        return 1;
    }
    if (indexPath.section == 2 && indexPath.item == 1) {
        return 1;
    }
    if (indexPath.section == 3 && indexPath.item == 2) {
        return 1;
    }
    if (indexPath.section == 4 && indexPath.item == 0) {
        return 2;
    }
    if (indexPath.section == 4 && indexPath.item == 2) {
        return 1;
    }
    if (indexPath.section == 4 && indexPath.item == 9) {
        return 1;
    }
    return 0;
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout pinToVisibleBoundsForHeaderInSection:(NSInteger)section {
    //    if (section < 3) {
    return YES;
    //    }
    //    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout pinToVisibleBoundsForFooterInSection:(NSInteger)section {
    return YES;
}

//- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout shouldShowBackgroundViewInSection:(NSInteger)section {
//    if (section % 2 == 1) {
//        return NO;
//    } else {
//        return YES;
//    }
//}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceHeightForHeaderInSection:(NSInteger)section {
//    return 40.0;
//}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceHeightForFooterInSection:(NSInteger)section {
//    return 20.0;
//}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceHeightForHeaderAtIndexPath:(NSIndexPath *)indexPath {
//    return 50.0;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceHeightForFooterAtIndexPath:(NSIndexPath *)indexPath {
//    return 50.0;
//}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetsForHeaderAtIndexPath:(NSIndexPath *)indexPath {
//    return UIEdgeInsetsMake(0, 0, 5, 0);
//}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetsForFooterAtIndexPath:(NSIndexPath *)indexPath {
//    return UIEdgeInsetsMake(0, 0, 5, 0);
//}

//- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout numberOfHeadersInSection:(NSInteger)section {
//    return 1;
//}

//- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout numberOfFootersInSection:(NSInteger)section {
//    return 3;
//}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didChangeHeaderPinnedStatus:(BOOL)isPinned inSection:(NSInteger)section {
    NSLog(@"当前section 为 %zd，吸附状态改变为 %zd", section, isPinned);
}

@end
