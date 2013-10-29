//
//  DRScrollView.h
//  LanTai
//
//  Created by david on 13-10-28.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarPosionView.h"
#import "CarCellView.h"
@interface DRScrollView : UIScrollView
-(void)startScrollContentWithStep:(int)step;
-(void)stopScroll;
@end
