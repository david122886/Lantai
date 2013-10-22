//
//  DRVerticalLabel.h
//  LanTai
//
//  Created by david on 13-10-18.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRVerticalLabel : UIView
@property (nonatomic,assign) UIEdgeInsets inset;
-(void)setText:(NSString*)text withTextColor:(UIColor*)color;
@end
