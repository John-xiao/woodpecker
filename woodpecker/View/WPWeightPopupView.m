//
//  WPWeightPopupView.m
//  woodpecker
//
//  Created by QiWL on 2017/9/24.
//  Copyright © 2017年 goldsmith. All rights reserved.
//

#import "WPWeightPopupView.h"
@interface WPWeightPopupView()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *markView;

@end
@implementation WPWeightPopupView
- (instancetype)init
{
    self = [super init];
    
    if ( self )
    {
        self.titleView.backgroundColor = kColor_5;
        self.titleLabel.text = @"体重";
        self.titleLabel.font = kFont_1(14);
        self.titleLabel.textColor = kColor_10;
        self.contentView.backgroundColor = kColor_9_With_Alpha(0.1);
    }
    
    return self;
}

- (void)setupViews{
    [super setupViews];
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.backgroundColor = kColor_1;
    _pickerView.showsSelectionIndicator = YES;
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    [self.contentView addSubview:_pickerView];
    _markView = [[UIView alloc] init];
    _markView.backgroundColor = kColor_5;
    [self.contentView addSubview:_markView];
    MJWeakSelf;
    [_pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.bottom.equalTo(@(-0.5));
        make.left.equalTo(@6);
        make.right.equalTo(@0);
    }];
    [_markView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.centerY.equalTo(weakSelf.contentView.mas_centerY);
        make.width.equalTo(@6);
        make.height.equalTo(@55);
    }];
}


#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 100;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%ld",(long)row];
}

#pragma mark UIPickerViewDelegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* titleLabel = (UILabel*)view;
    if (!titleLabel){
        titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = kColor_9;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = kFont_3(18);
        titleLabel.backgroundColor = [UIColor clearColor];
    }
    titleLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return titleLabel;
}

//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
//
//    NSDictionary * attrDic = @{NSForegroundColorAttributeName:kColor_9,
//                               NSFontAttributeName:kFont_3(18)};
//    NSAttributedString * attrString = [[NSAttributedString alloc] initWithString: [self pickerView:pickerView titleForRow:row forComponent:component] attributes:attrDic];
//    return attrString;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return pickerView.frame.size.width/2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 53;
}

- (void)cancelBtnPressed{
    [super cancelBtnPressed];
}

- (void)confirmBtnPressed{
    [self hide];
    NSInteger weight1 = [_pickerView selectedRowInComponent:0];
    NSInteger weight2 = [_pickerView selectedRowInComponent:1];
    if (_weightBlock) {
        _weightBlock(self, weight1,weight2);
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end