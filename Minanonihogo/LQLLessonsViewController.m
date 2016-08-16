//
//  LQLLessonsViewController.m
//  Minanonihogo
//
//  Created by Le Quang Long on 5/12/15.
//  Copyright (c) 2015 Kakaruchi. All rights reserved.
//
#import "CarbonKit.h"
#import "LQLLessonsViewController.h"
#import "LQLessonViewController.h"
#import "FMDB.h"
#import "LQLHirakanaViewController.h"
#import "LQLDefine.h"

#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }

@interface LQLLessonsViewController () <CarbonTabSwipeDelegate>
{
     CarbonTabSwipeNavigation *tabSwipe;
    
}
@end

@implementation LQLLessonsViewController

- (void)setupTabbar{

    NSMutableArray *tabNames = [NSMutableArray array];
    for (int i=0; i<52; i++) {
        if (i==0) {
            [tabNames addObject:LZ_HIRAGANA_TABNAME];
        }
        else if (i==1){
            [tabNames addObject:LZ_KATAKANA_TABNAME];
        }else{
            NSString *lessonName = [NSString stringWithFormat:@"%@ %d",LZ_LESSON_TEXT,i-1];
            [tabNames addObject:lessonName];
        }
    }

    UIColor *color = self.navigationController.navigationBar.barTintColor;
    tabSwipe = [[CarbonTabSwipeNavigation alloc] createWithRootViewController:self
                                                                     tabNames:tabNames
                                                                    tintColor:color
                                                                     delegate:self];
    tabSwipe.currentTabIndex=4;
    [tabSwipe setNormalColor:[UIColor lightTextColor]];
    [tabSwipe setSelectedColor:[UIColor whiteColor]];
    [tabSwipe setIndicatorHeight:2.f]; // default 3.f
    [tabSwipe addShadow];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Minanonihongo"];
    [self setupTabbar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [tabSwipe setTranslucent:NO]; // remove translucent
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [tabSwipe setTranslucent:YES]; // add translucent
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

# pragma mark - Carbon Tab Swipe Delegate
// required
- (UIViewController *)tabSwipeNavigation:(CarbonTabSwipeNavigation *)tabSwipe viewControllerAtIndex:(NSUInteger)index {
    if (index == 0) {
        LQLHirakanaViewController *hiraVC = [[LQLHirakanaViewController alloc] initWithOption:eHIRAGANA];
        return hiraVC;
    } else if (index == 1) {
        LQLHirakanaViewController *kanaVC = [[LQLHirakanaViewController alloc] initWithOption:eKATAKANA];
        
        return kanaVC;
    }
    else{
        LQLessonViewController * child = [[LQLessonViewController alloc] initWithLesson:index-1];
        return child;
    }
}

// optional
- (void)tabSwipeNavigation:(CarbonTabSwipeNavigation *)tabSwipe didMoveAtIndex:(NSInteger)index {
    NSLog(@"Current tab: %d", (int)index);
}
@end
