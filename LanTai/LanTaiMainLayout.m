//
//  LanTaiMainLayout.m
//  LanTai
//
//  Created by david on 13-10-15.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "LanTaiMainLayout.h"
#define CELL_WIDTH 100
#define CELL_PADDING 20
#define CELL_HEIGHT 100
@interface LanTaiMainLayout ()
@property(nonatomic,strong) NSMutableDictionary *attributeDir;
@end
@implementation LanTaiMainLayout
-(void)prepareLayout{
    [super prepareLayout];
    for (int section = 0; section < 3; section++) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
        for (int row = 0; row < 30; row++) {
            UICollectionViewLayoutAttributes *butes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:row inSection:section]];
            butes.frame = (CGRect){row*(CELL_WIDTH+CELL_PADDING),section*(CELL_PADDING+CELL_HEIGHT),CELL_WIDTH,CELL_HEIGHT};
            
            [arr addObject:butes];
            
        }
        [self.attributeDir setObject:arr forKey:[NSNumber numberWithInt:section]];
    }
}

-(CGSize)collectionViewContentSize{
    return (CGSize){2000,900};
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    for (NSArray *subArr in [self.attributeDir allValues]) {
        [arr addObjectsFromArray:subArr];
    }
    return arr;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
      NSArray *number= [[self.attributeDir allValues] objectAtIndex:indexPath.section];
    return [number objectAtIndex:indexPath.item];
}

-(NSMutableDictionary *)attributeDir{
    if (!_attributeDir) {
        _attributeDir = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _attributeDir;
}
@end
