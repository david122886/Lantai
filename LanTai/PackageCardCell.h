//
//  PackageCardCell.h
//  LanTaiOrder
//
//  Created by Ruby on 13-3-12.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageCardCell : UITableViewCell

@property (nonatomic,strong) UILabel *lblName,*lblPrice;
@property (nonatomic,strong) NSMutableArray *selectedArr;
@property (nonatomic,strong) NSMutableDictionary *product;
@property (nonatomic,strong) NSIndexPath *index;
@property (nonatomic,assign) NSInteger cellType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier with:(NSMutableDictionary *)prod indexPath:(NSIndexPath *)idx type:(NSInteger)type;

@end
