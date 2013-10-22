//
//  ServiceCell.m
//  LanTaiOrder
//
//  Created by Ruby on 13-3-12.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "ServiceCell.h"

@implementation ServiceCell

@synthesize lblPrice,lblName,lblCount,stepBtn,product,txtPrice,total;

static float p_price = 0;

- (NSString *)checkFormWithID:(int)ID andCount:(int)count andPrice:(float)price {
    NSMutableString *prod_count = [NSMutableString string];
    [prod_count appendFormat:@"%d_%d_%.2f,",ID,count,price];
    return prod_count;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier with:(NSMutableDictionary *)prod indexPath:(NSIndexPath *)idx type:(NSInteger)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ServiceCell" owner:self options: nil];
        if(arrayOfViews.count < 1){return nil;}
        if(![[arrayOfViews objectAtIndex:0] isKindOfClass:[ServiceCell class]]){
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
        self.product = [prod mutableCopy];
        self.index = idx;
    
        if (type == 0) {
            self.total.hidden = YES;
            self.txtPrice.hidden = NO;
            self.lblCount.frame = CGRectMake(350, 11, 44, 21);
            self.txtPrice.frame  =CGRectMake(402, 9, 80, 26);
            if ([DataService sharedService].id_count_price.count >0) {
                for (int i =0; i<[DataService sharedService].id_count_price.count; i++) {
                    NSString *str = [[DataService sharedService].id_count_price objectAtIndex:i];
                    NSArray *arr = [str componentsSeparatedByString:@"_"];
                    NSString *p_id = [arr objectAtIndex:0];
                    if ([p_id intValue] == [[product objectForKey:@"id"] intValue]) {
                        self.txtPrice.text = [NSString stringWithFormat:@"%.2f",[[arr objectAtIndex:2]floatValue]];
                    }
                }
            }
            p_price = [self.txtPrice.text floatValue];
        }else {
            self.total.hidden = YES;
            self.txtPrice.hidden = YES;
            self.lblCount.frame = CGRectMake(420, 11, 55, 21);
            self.total.frame  =CGRectMake(482, 9, 80, 26);
            
            if ([DataService sharedService].id_count_price.count>0) {
                for (int i=0; i<[DataService sharedService].id_count_price.count; i++) {
                    NSMutableString *str = [[DataService sharedService].id_count_price objectAtIndex:i];
                    NSArray *arr = [str componentsSeparatedByString:@"_"];
                    NSString *p_id = [arr objectAtIndex:0];//产品id
                    if ([p_id intValue] == [[self.product objectForKey:@"id"]intValue]) {
                        self.total.text = [NSString stringWithFormat:@"%.2f",[[arr objectAtIndex:2]floatValue]];
                    }
                }
            }
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

//增减数量
- (IBAction)stepCount:(UIStepper *)sender{
    [DataService sharedService].first = NO;
    //库存的改变量
    double num_kucun = 0;
    if (![[self.product objectForKey:@"num"] isKindOfClass:[NSNull class]] && [self.product objectForKey:@"num"]!=nil) {
        num_kucun = [[self.product objectForKey:@"num"]doubleValue];
        [self.stepBtn setMaximumValue:num_kucun];
        [self.stepBtn setMinimumValue:1];
    }else {
        [self.stepBtn setMaximumValue:100];
        [self.stepBtn setMinimumValue:1];
    }
     //价格改变量
    double old = [self.lblCount.text doubleValue];
    float p_change = 0;//价格的改变量
    float p_show = [self.txtPrice.text floatValue];//显示的价格
    float p_ture = old *[[product objectForKey:@"price"]floatValue];//实际价格
    if (p_show != p_ture) {
        p_change = p_ture - p_show;//价格的改变量
    }
    //数量的增加与减少
    double val = [sender value];
    self.txtPrice.text = [NSString stringWithFormat:@"%.2f",[[product objectForKey:@"price"]floatValue]*val];
    
    if (val == old) {
        DLog(@"没变化");
    }else {
        //套餐卡
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableView" object:self.product];
        //活动
        [[NSNotificationCenter defaultCenter] postNotificationName:@"saleReloadTableView" object:self.product];
        //打折卡
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scardReloadTableView" object:nil];
        
        NSString * product_id = [self.product objectForKey:@"id"];
        //活动
        int sale_count = [[[DataService sharedService].number_id objectForKey:product_id]intValue];//所选产品 “被” 服务剩余次数
        
        
        self.lblCount.text = [NSString stringWithFormat:@"%d",(int)val];
        NSString *price = [NSString stringWithFormat:@"%.2f",(val - old) * [self.lblPrice.text floatValue] + p_change];
        [self.product setValue:[NSNumber numberWithDouble:val] forKey:@"count"];
        [DataService sharedService].total_count = [DataService sharedService].total_count + [[product objectForKey:@"price"]floatValue]*(val - old) + p_change;
//        DLog(@"%f",[DataService sharedService].total_count);
        //重置id_count_price数据
        if ([DataService sharedService].id_count_price.count>0) {
            for (int i=0; i<[DataService sharedService].id_count_price.count; i++) {
                NSMutableString *str = [[DataService sharedService].id_count_price objectAtIndex:i];
                NSArray *arr = [str componentsSeparatedByString:@"_"];
                NSString *p_id = [arr objectAtIndex:0];//产品id
                
                if ([p_id intValue] == [product_id intValue]) {
                    NSString *string = [self checkFormWithID:[product_id intValue] andCount:[[self.product objectForKey:@"count"]intValue] andPrice:[self.txtPrice.text floatValue]];
                    
                    [[DataService sharedService].id_count_price replaceObjectAtIndex:i withObject:string];
                }
            }
        }
        
        
        //重置number_id数据
        int num = (val - old);
        [[DataService sharedService].number_id removeObjectForKey:product_id];
        [[DataService sharedService].number_id setObject:[NSString stringWithFormat:@"%d",num+sale_count ] forKey:product_id];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:price,@"object",self.product,@"prod",self.index,@"idx",@"0",@"type", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"update_total" object:dic];
    }
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [DataService sharedService].first = NO;
    p_price = [self.txtPrice.text floatValue];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *string = textField.text;
    NSString *regexCall = @"([1-9]\\d*\\.?\\d*)|(0\\.\\d*[1-9])";
    NSPredicate *predicateCall = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexCall];
    if ([predicateCall evaluateWithObject:string]){
        float price = [string floatValue];
        if (price != p_price) {
            [DataService sharedService].total_count = [DataService sharedService].total_count + (price-p_price) ;
//            DLog(@"%f",[DataService sharedService].total_count);
            //重置id_count_price数据
            if ([DataService sharedService].id_count_price.count>0) {
                for (int i=0; i<[DataService sharedService].id_count_price.count; i++) {
                    NSMutableString *str = [[DataService sharedService].id_count_price objectAtIndex:i];
                    NSArray *arr = [str componentsSeparatedByString:@"_"];
                    NSString *p_id = [arr objectAtIndex:0];//产品id
                    
                    if ([p_id intValue] == [[self.product objectForKey:@"id"]intValue]) {
                        NSString *string = [self checkFormWithID:[[self.product objectForKey:@"id"]intValue]  andCount:[[self.product objectForKey:@"count"]intValue] andPrice:[self.txtPrice.text floatValue]];
                        
                        [[DataService sharedService].id_count_price replaceObjectAtIndex:i withObject:string];
                    }
                }
            }
        
            NSString *p = [NSString stringWithFormat:@"%.2f",price-p_price];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:p,@"object",self.product,@"prod",self.index,@"idx",@"0",@"type", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"update_total" object:dic];
        }
    }else {
        //输入的不是数字
        self.txtPrice.text = [NSString stringWithFormat:@"%.2f",p_price];
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:@"请输入正确的价格。"];
        __block AHAlertView *alert = alertt;
        [alertt setCancelButtonTitle:@"确定" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            alert = nil;
        }];
        [alertt show];
    }
}
@end
