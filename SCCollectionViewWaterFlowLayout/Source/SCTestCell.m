//
//  SCTestCell.m
//  测试瀑布流框架
//
//  Created by Jason on 14/12/27.
//  Copyright (c) 2014年 Jason’s Application House. All rights reserved.
//

#import "SCTestCell.h"
#import "SCTestModel.h"
#import "UIImageView+WebCache.h"

@interface SCTestCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation SCTestCell

- (void)setModel:(SCTestModel *)model {
    _model = model;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.img] placeholderImage:[UIImage imageNamed:@"loading"]];
    self.priceLabel.text = model.price;
}

@end
