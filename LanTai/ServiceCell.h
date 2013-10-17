//
//  ServiceCell.h
//  LanTaiOrder
//
//  Created by Ruby on 13-3-12.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceCell : UITableViewCell<UITextFieldDelegate>
{
    IBOutlet UILabel *lblName,*lblPrice,*lblCount;
}

@property (nonatomic,strong) IBOutlet UILabel *lblName,*lblCount,*lblPrice,*total;
@property (nonatomic,strong) IBOutlet UIStepper *stepBtn;
@property (nonatomic,strong) NSMutableDictionary *product;
@property (nonatomic,strong) NSIndexPath *index;
@property (nonatomic,strong) IBOutlet UITextField *txtPrice;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier with:(NSMutableDictionary *)prod indexPath:(NSIndexPath *)idx type:(NSInteger)type;
- (IBAction)stepCount:(UIStepper *)sender;

@end
