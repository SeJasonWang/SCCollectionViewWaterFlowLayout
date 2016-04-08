//
//  SCTestModel.h
//  测试瀑布流框架
//
//  Created by Jason on 14/12/27.
//  Copyright (c) 2014年 Jason’s Application House. All rights reserved.
//

#import "JSONModel.h"

@interface SCTestModel : JSONModel

@property (nonatomic, assign) CGFloat w;
@property (nonatomic, assign) CGFloat h;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *img;

@end
