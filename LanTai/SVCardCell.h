//
//  SVCardCell.h
//  LanTaiOrder
//
//  Created by Ruby on 13-3-12.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVCardCell : UITableViewCell{
   IBOutlet UILabel *lblName,*lblPrice,*lblCount;
   IBOutlet UIButton *switchBtn;
}

@property (nonatomic,strong) IBOutlet UILabel *lblName,*lblPrice,*lblCount;
@property (nonatomic,strong) IBOutlet UIButton *switchBtn;
@property (nonatomic,strong) NSMutableDictionary *prod;
@property (nonatomic,strong) NSIndexPath *index;
@property (nonatomic,strong) NSMutableArray *selectedArr;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier with:(NSMutableDictionary *)product indexPath:(NSIndexPath *)idx;
- (IBAction)clickSwitch:(UISwitch *)sender;
@end
