//
//  LQLHirakanaViewController.h
//  Minanonihogo
//
//  Created by Le Quang Long on 5/14/15.
//  Copyright (c) 2015 Kakaruchi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    eHIRAGANA,
    eHIRAGANA_EXTENSION1,
    eHIRAGANA_EXTENSION2,
    eKATAKANA,
    eKATAKANA_EXTENSION1,
    eKATAKANA_EXTENSION2
    
}OPTION_DISPLAY_DATA;

@interface LQLHirakanaViewController : UIViewController
- (id)initWithOption:(OPTION_DISPLAY_DATA)option;
@end
