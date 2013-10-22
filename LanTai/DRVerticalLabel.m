//
//  DRVerticalLabel.m
//  LanTai
//
//  Created by david on 13-10-18.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "DRVerticalLabel.h"
#define TEXT_FONT [UIFont systemFontOfSize:20]
@interface DRVerticalLabel()

@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) NSString *viewText;
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,assign) CGRect textRect;
@end
@implementation DRVerticalLabel


-(void)setText:(NSString*)text withTextColor:(UIColor*)color{
    if (!text) {
        return;
    }
    if (!self.label) {
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.numberOfLines = 0;
        [self addSubview:self.label];
        [self.label setTextAlignment:NSTextAlignmentCenter];
    }
    NSMutableString *newStr = [[NSMutableString alloc] init];
    for (int index = 0; text && index < text.length; index++) {
        [newStr appendFormat:@"%@\n",[text substringWithRange:NSMakeRange(index, 1)]];
    }
    CGSize size = [text sizeWithFont:TEXT_FONT];
    CGRect textRect = (CGRect){CGRectGetWidth(self.frame)/2-size.height/2-self.inset.left,CGRectGetHeight(self.frame)/2 - (size.width+20)/2,size.height,size.width+20};
    UIColor *textColor = color?:[UIColor grayColor];
    self.textColor = textColor;
    self.label.frame = textRect;
    self.textRect = textRect;
    [self.label setTextColor:self.textColor];
    self.label.text = newStr;
    [self setNeedsDisplay];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.label.frame = self.textRect;
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, self.textColor.CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, rect.size.width/2 - 1, self.inset.top);
    CGContextAddLineToPoint(context, rect.size.width/2 - 1, CGRectGetMinY(self.textRect));
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, rect.size.width/2 - 1, CGRectGetMaxY(self.textRect));
    CGContextAddLineToPoint(context, rect.size.width/2 - 1, rect.size.height - self.inset.bottom);
    CGContextStrokePath(context);
    NSLog(@"%@",NSStringFromCGRect(self.label.frame));
}


@end
