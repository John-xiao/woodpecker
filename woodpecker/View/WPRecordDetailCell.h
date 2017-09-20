//
//  WPRecordDetailCell.h
//  woodpecker
//
//  Created by QiWL on 2017/9/20.
//  Copyright © 2017年 goldsmith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPRecordDetailCell : UITableViewCell
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)NSArray *titles;
@property(nonatomic, strong)NSString *theme;
@property(nonatomic, strong)NSString *selectedTitle;
@property(nonatomic, strong)UIView *line;
@property(nonatomic, strong)UIView *selectionView;

@end