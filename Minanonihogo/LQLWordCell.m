//
//  LQLWordCell.m
//  Minanonihogo
//
//  Created by Le Quang Long on 5/13/15.
//  Copyright (c) 2015 Kakaruchi. All rights reserved.
//

#import "LQLWordCell.h"

@implementation LQLWordCell
@synthesize imgWord = _imgWord;
@synthesize lblKanji  = _lblKanji;
@synthesize lblHirakana  = _lblHirakana;
@synthesize lblMeaning  = _lblMeaning;
@synthesize lblSample  = _lblSample;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        [self.contentView addSubview:self.imgWord];
        [self.contentView addSubview:self.lblKanji];
        [self.contentView addSubview:self.lblHirakana];
        [self.contentView addSubview:self.lblMeaning];
        [self.contentView addSubview:self.lblSample];
        
        [self.contentView addConstraints:[self layoutConstraints]];
    }
    return self;
}
#pragma mark - Views

- (UIImageView *)imgWord
{
    if (_imgWord) return _imgWord;
    _imgWord = [UIImageView new];
    [_imgWord setTranslatesAutoresizingMaskIntoConstraints:NO];
    _imgWord.layer.masksToBounds = YES;
    _imgWord.layer.cornerRadius = 10.0f;
    return _imgWord;
}

- (LQLSampleTextLabel *)lblSample
{
    if (_lblSample) return _lblSample;
    _lblSample = [LQLSampleTextLabel new];
    [_lblSample setTranslatesAutoresizingMaskIntoConstraints:NO];
    _lblSample.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    
    _lblSample.lineBreakMode = NSLineBreakByWordWrapping;
    _lblSample.numberOfLines = 0;
    
    return _lblSample;
}

-(LQLSampleTextLabel *)lblMeaning
{
    if (_lblMeaning) return _lblMeaning;
    _lblMeaning = [LQLSampleTextLabel new];
    [_lblMeaning setTranslatesAutoresizingMaskIntoConstraints:NO];
    _lblMeaning.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
//    [_lblMeaning setContentCompressionResistancePriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    _lblMeaning.lineBreakMode = NSLineBreakByWordWrapping;
    _lblMeaning.numberOfLines = 0;
    return _lblMeaning;
}
-(LQLSampleTextLabel *)lblHirakana
{
    if (_lblHirakana) return _lblHirakana;
    _lblHirakana = [LQLSampleTextLabel new];
    [_lblHirakana setTranslatesAutoresizingMaskIntoConstraints:NO];
    _lblHirakana.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
    _lblHirakana.textColor = [UIColor brownColor];
//    [_lblHirakana setContentCompressionResistancePriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    _lblHirakana.lineBreakMode = NSLineBreakByWordWrapping;
    _lblHirakana.numberOfLines = 0;
    return _lblHirakana;
    
}

-(UILabel *)lblKanji
{
    if (_lblKanji) return _lblKanji;
    _lblKanji = [UILabel new];
    [_lblKanji setTranslatesAutoresizingMaskIntoConstraints:NO];
    _lblKanji.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
    _lblKanji.textColor = [UIColor purpleColor];
    [_lblKanji setContentCompressionResistancePriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    
    return _lblKanji;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(NSArray *)layoutConstraints{
    
    NSMutableArray * result = [NSMutableArray array];
    
    NSDictionary * views = @{ @"image": self.imgWord,
                              @"kanji": self.lblKanji,
                              @"hirakana": self.lblHirakana,
                              @"mean" : self.lblMeaning,
                              @"sample" : self.lblSample};
    
    NSDictionary *metrics = @{@"imgSize":@50.0,
                              @"margin" :@12.0};
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[image(imgSize)]-[kanji]-10-|"
                                                                        options:NSLayoutFormatAlignAllTop
                                                                        metrics:metrics
                                                                          views:views]];
    
//    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[kanji]-[hirakana]"
//                                                                        options:NSLayoutFormatAlignAllBaseline
//                                                                        metrics:metrics
//                                                                          views:views]];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[image(imgSize)]"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:views]];
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[kanji]-[hirakana]-[mean]-[sample]-10-|"
                                                                        options:NSLayoutFormatAlignAllLeft
                                                                        metrics:metrics
                                                                          views:views]];
//    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hirakana]-[mean]"
//                                                                        options:NSLayoutFormatAlignAllLeft
//                                                                        metrics:metrics
//                                                                          views:views]];
//    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[mean]-[sample]-10-|"
//                                                                        options:NSLayoutFormatAlignAllLeft
//                                                                        metrics:metrics
//                                                                          views:views]];
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[hirakana]-10-|"
                                                                        options:NSLayoutFormatAlignAllBaseline
                                                                        metrics:metrics
                                                                          views:views]];
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[sample]-10-|"
                                                                        options:NSLayoutFormatAlignAllBaseline
                                                                        metrics:metrics
                                                                          views:views]];
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[mean]-10-|"
                                                                        options:NSLayoutFormatAlignAllBaseline
                                                                        metrics:metrics
                                                                          views:views]];

    return result;
}

@end

@implementation LQLSampleTextLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.preferredMaxLayoutWidth = self.bounds.size.width;
}

@end