//
//  ServeItemView.h
//  LanTai
//
//  Created by david on 13-10-15.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ServeItemViewDelegate;
@interface ServeItemView : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *serveBt;
@property (nonatomic,strong) NSIndexPath *path;
@property (nonatomic,assign) BOOL isSelected;
@property (nonatomic,weak) id<ServeItemViewDelegate> delegate;
@end

@protocol ServeItemViewDelegate <NSObject>

-(void)serveItemView:(ServeItemView*)itemView didSelectedItemAtIndexPath:(NSIndexPath*)path;

@end