//
//  PlateVViewController.m
//  LanTai
//
//  Created by comdosoft on 13-10-16.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "PlateVViewController.h"

@interface PlateVViewController ()

@end

@implementation PlateVViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [self.dataArray objectAtIndex:indexPath.row];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:str,@"name", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"palteSelect" object:dic];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}
@end
