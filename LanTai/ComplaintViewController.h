//
//  ComplaintViewController.h
//  LanTaiOrder
//
//  Created by Ruby on 13-3-3.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComplaintViewController : UIViewController <UITextViewDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) IBOutlet UILabel *lblName,*lblCarNum,*lblCode,*lblProduct;

@property (nonatomic,strong) IBOutlet UIView *infoBgView;

@property (nonatomic,strong) NSMutableDictionary *info;
@property (nonatomic,strong) IBOutlet UIScrollView *scView;
@property (nonatomic,strong) IBOutlet UITextView *reasonView,*requestView;
@property (nonatomic,strong) IBOutlet UILabel *resonLab,*requestLab;
@property (nonatomic,strong) IBOutlet UIButton *sureBtn,*cancleBtn;

- (IBAction)clickSubmit:(id)sender;

@end
