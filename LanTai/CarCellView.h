//
//  CarCellView.h
//  LanTai
//
//  Created by david on 13-10-15.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {CARNOTHING,CARWAITTING,CARBEGINNING,CARPAYING,CARFINISHED} CarState;
@protocol CarCellViewDelegate;
@interface CarCellView : UIView 
@property (nonatomic,assign) CGRect beforeMoiveRect;
@property (nonatomic,assign) CGRect parentViewRect;
@property (nonatomic,strong) NSString *carNumber;
@property (nonatomic,assign) CarState state;
@property(nonatomic,assign) int posionID;
@property (nonatomic,strong) UIView *coverView;
@property (nonatomic,weak) id <CarCellViewDelegate> delegate;
-(CarCellView*)copyCarCellView;
@end

@protocol CarCellViewDelegate <NSObject>

-(void)carCellViewDidSelected:(CarCellView*)view;
@end