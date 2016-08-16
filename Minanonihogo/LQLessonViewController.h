//
//  LQLessonViewController.h
//  Minanonihogo
//
//  Created by Le Quang Long on 5/12/15.
//  Copyright (c) 2015 Kakaruchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVSpeechSynthesizerFacade.h"
@interface LQLessonViewController : UIViewController {
     AVSpeechSynthesizerFacade* mySpeechSynthesizer;
}
- (instancetype)initWithLesson:(NSInteger)lesson;

@end
