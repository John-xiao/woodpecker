//
//  WPCalendarNote.m
//  woodpecker
//
//  Created by QiWL on 2017/9/16.
//  Copyright © 2017年 goldsmith. All rights reserved.
//

#import "WPCalendarNote.h"

@implementation WPCalendarNote
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews{
    _colorNote = [[UIView alloc] initWithFrame:CGRectMake(0, (self.height - 14)/2, 14, 14)];
    _colorNote.backgroundColor = [UIColor clearColor];
    _colorNote.layer.masksToBounds = YES;
    _colorNote.layer.cornerRadius = 7;
    _colorNote.layer.borderColor = [UIColor clearColor].CGColor;
    _colorNote.layer.borderWidth = 0.5;
    [self addSubview:_colorNote];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = kColor_7;
    _titleLabel.font = kFont_2(12);
    [self addSubview:_titleLabel];
}

- (void)setPeriod:(PeriodType)period{
    _period = period;
    switch (period) {
        case kPeriodTypeOfMenstrual:
        case kPeriodTypeOfMenstrualEnd:
        case kPeriodTypeOfMenstrualStart:
            _titleLabel.text = kLocalization(@"period_menstrual");
            _colorNote.layer.borderColor = kColor_13.CGColor;
            _colorNote.backgroundColor = kColor_13;
            break;
        case kPeriodTypeOfPregnancy:
        case kPeriodTypeOfPregnancyEnd:
        case kPeriodTypeOfPregnancyStart:
            _titleLabel.text = kLocalization(@"period_pregnancy");
            _colorNote.layer.borderColor = kColor_14_With_Alpha(0.1).CGColor;
            _colorNote.backgroundColor = kColor_14_With_Alpha(0.1);
            break;
        case kPeriodTypeOfForecast:
        case kPeriodTypeOfForecastEnd:
        case kPeriodTypeOfForecastStart:
            _titleLabel.text = kLocalization(@"period_forecast");
            _colorNote.layer.borderColor = kColor_15.CGColor;
            _colorNote.backgroundColor = [UIColor clearColor];
            break;
        case kPeriodTypeOfOviposit:
            _titleLabel.text = kLocalization(@"period_oviposit");
            _colorNote.layer.borderColor = kColor_15.CGColor;
            _colorNote.backgroundColor = kColor_15;
            break;
        case kPeriodTypeOfSafe:
            _titleLabel.text = kLocalization(@"period_safe");
            _colorNote.layer.borderColor = kColor_17.CGColor;
            _colorNote.backgroundColor = kColor_17;
            break;
    }
   CGSize size = [_titleLabel.text sizeWithFont:kFont_1(12)];
    _colorNote.frame = CGRectMake((self.width - size.width - 21)/2, (self.height - 14)/2, 14, 14);
    _titleLabel.frame = CGRectMake(_colorNote.right + 7, 0, self.width - _colorNote.right - 7, self.height);

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
