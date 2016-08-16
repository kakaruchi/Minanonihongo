//
//  LQLWordCell.h
//  Minanonihogo
//
//  Created by Le Quang Long on 5/13/15.
//  Copyright (c) 2015 Kakaruchi. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface LQLSampleTextLabel : UILabel
@end

@interface LQLWordCell : UITableViewCell
@property (nonatomic) UIImageView * imgWord;
@property (nonatomic) UILabel * lblKanji;
@property (nonatomic) LQLSampleTextLabel * lblSample;
@property (nonatomic) LQLSampleTextLabel * lblHirakana;
@property (nonatomic) LQLSampleTextLabel * lblMeaning;
@end
