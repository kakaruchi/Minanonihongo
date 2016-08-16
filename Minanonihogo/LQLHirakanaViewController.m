//
//  LQLHirakanaViewController.m
//  Minanonihogo
//
//  Created by Le Quang Long on 5/14/15.
//  Copyright (c) 2015 Kakaruchi. All rights reserved.
//

#import "LQLHirakanaViewController.h"
#import "GMGridView.h"
#import "FMDB.h"
#import "LQLDefine.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>
#import "DrawView.h"
#import "KGModal.h"

#define NUMBER_ITEMS_ON_LOAD 250
#define NUMBER_ITEMS_ON_LOAD2 30

#define kPaddingIphone 10.0f
#define kPaddingIpad 15.0f
//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ViewController (privates methods)
//////////////////////////////////////////////////////////////
@interface LQLHirakanaViewController ()<GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate,UIActionSheetDelegate>{
    __gm_weak GMGridView *_gmGridView;
    UINavigationController *_optionsNav;
    UIPopoverController *_optionsPopOver;
    
    NSMutableArray *_data;
    NSMutableArray *_data2;
    __gm_weak NSMutableArray *_currentData;
    NSInteger _lastDeleteItemIndexAsked;
     NSMutableArray *datasource;
    OPTION_DISPLAY_DATA currentOption;
    NSInteger selectedIndex;
    DrawView *drawView;
}

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
- (void)addMoreItem;
- (void)removeItem;
- (void)refreshItem;

@end

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ViewController implementation
//////////////////////////////////////////////////////////////
@implementation LQLHirakanaViewController
- (void)hiraganaData{
    
}

- (void)initDataWithOption:(OPTION_DISPLAY_DATA)option{
    selectedIndex = -1;
    datasource = [NSMutableArray array];
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"kotoba" ofType:@"sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    
    // kind of experimentalish.
    [db setShouldCacheStatements:YES];
    
    NSString *statement;
    switch (currentOption) {
        case eHIRAGANA:
        case eKATAKANA:{
             statement = [NSString stringWithFormat:@"SELECT * FROM hirakana"];
        }
            break;
        case eHIRAGANA_EXTENSION1:
        case eKATAKANA_EXTENSION1:{
             statement = [NSString stringWithFormat:@"SELECT * FROM hirakana_ext"];
        }
            break;
        case eHIRAGANA_EXTENSION2:
        case eKATAKANA_EXTENSION2:{
            statement = [NSString stringWithFormat:@"SELECT * FROM hirakana_ext2"];
        }
            break;
        default:
            break;
    }
    FMResultSet *rs = [db executeQuery:statement];
    while ([rs next]) {
        // just print out what we've got in a number of formats.
        NSDictionary *d = [rs resultDictionary];
        [datasource addObject:d];
        
    }
    // close the result set.
    // it'll also close when it's dealloc'd, but we're closing the database before
    // the autorelease pool closes, so sqlite will complain about it.
    [rs close];
    
    _currentData = datasource;
    
}

- (id)initWithOption:(OPTION_DISPLAY_DATA)option
{
    currentOption = option;
    if ((self =[super init]))
    {
        
        [self initDataWithOption:currentOption];
    }
    
    return self;
}

//////////////////////////////////////////////////////////////
#pragma mark controller events
//////////////////////////////////////////////////////////////

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSInteger spacing = INTERFACE_IS_PHONE ? kPaddingIphone : kPaddingIpad;
    
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
   
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gmGridView];
    _gmGridView = gmGridView;
    _gmGridView.disableEditOnEmptySpaceTap = YES;
    _gmGridView.style = GMGridViewStylePush;
    _gmGridView.itemSpacing = spacing;
    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing/2.0, 0, spacing/2.0, 0);
    _gmGridView.centerGrid = YES;
    _gmGridView.actionDelegate = self;
    _gmGridView.dataSource = self;
    _gmGridView.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray * result = [NSMutableArray array];
    NSDictionary * views = @{ @"gmGridView": _gmGridView};
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[gmGridView]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views]];
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[gmGridView]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views]];
    [self.view addConstraints:result];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_gmGridView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _gmGridView.mainSuperView = self.navigationController.view;
    
    UIBarButtonItem *options = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonSystemItemAction target:self action:@selector(didTouchOnOptionsButton:)];
    self.navigationItem.leftBarButtonItem = options;
}

- (void)didTouchOnOptionsButton:(id)sender{
    switch (currentOption) {
        case eHIRAGANA:
        {
            
            UIActionSheet *actionSheet =[ [UIActionSheet alloc] initWithTitle:@"Hiragana extension" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Extension 1",@"Extension 2", nil];
            [actionSheet showInView:self.view];

        }
            break;
        case eKATAKANA:{
            
            UIActionSheet *actionSheet =[ [UIActionSheet alloc] initWithTitle:@"Katakana extension" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Katakana 1",@"Katakana 2", nil];
            [actionSheet showInView:self.view];

        }
        default:
            break;
    }}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _gmGridView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

//////////////////////////////////////////////////////////////
#pragma mark memory management
//////////////////////////////////////////////////////////////

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}

//////////////////////////////////////////////////////////////
#pragma mark orientation management
//////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [_currentData count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (INTERFACE_IS_PHONE)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(([UIScreen mainScreen].bounds.size.width)/5.0f-3*kPaddingIphone/2.0, 135);
        }
        else
        {
            return CGSizeMake(([UIScreen mainScreen].bounds.size.width)/5.0f-3*kPaddingIphone/2.0f, 70);
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake([UIScreen mainScreen].bounds.size.width/5.0f, 205);
        }
        else
        {
            return CGSizeMake([UIScreen mainScreen].bounds.size.width/5.0f, 175);
        }
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor lightGrayColor];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
        
        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *character = [[UILabel alloc] initWithFrame:(CGRect){0,5,cell.contentView.bounds.size.width,cell.contentView.bounds.size.height-30}];
    character.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    NSString *strChar ;
    switch (currentOption) {
        case eHIRAGANA:
        {
            strChar = (NSString *)[_currentData objectAtIndex:index][@"character"];
            
        }
            break;
        case eHIRAGANA_EXTENSION1:
        {
            strChar = (NSString *)[_currentData objectAtIndex:index][@"hiraji"];
            
        }
            break;
        case eHIRAGANA_EXTENSION2:
        {
            strChar = (NSString *)[_currentData objectAtIndex:index][@"hiraji"];
            
        }
            break;
        case eKATAKANA:
        {
            strChar = (NSString *)[_currentData objectAtIndex:index][@"kanaji"];
            
        }
            break;
        case eKATAKANA_EXTENSION1:
        {
            strChar = (NSString *)[_currentData objectAtIndex:index][@"kanaji"];
            
        }
            break;
        case eKATAKANA_EXTENSION2:
        {
            strChar = (NSString *)[_currentData objectAtIndex:index][@"kanaji"];
            
        }
            break;
            
        default:
            break;
    }
    character.text = strChar;
    character.textAlignment = NSTextAlignmentCenter;
    character.backgroundColor = [UIColor clearColor];
    character.textColor = [UIColor yellowColor];
    character.highlightedTextColor = [UIColor whiteColor];
    character.font = [UIFont boldSystemFontOfSize:30];
    [cell.contentView addSubview:character];
    
    //romaji character
    UILabel *romaji = [[UILabel alloc] initWithFrame:(CGRect){cell.contentView.bounds.origin.x,CGRectGetMaxY(character.frame),cell.contentView.bounds.size.width,20}];
    romaji.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    romaji.text = (NSString *)[_currentData objectAtIndex:index][@"romaji"];
    romaji.textAlignment = NSTextAlignmentCenter;
    romaji.backgroundColor = [UIColor clearColor];
    romaji.textColor = [UIColor blueColor];
    romaji.highlightedTextColor = [UIColor whiteColor];
    romaji.font = [UIFont boldSystemFontOfSize:16];
    [cell.contentView addSubview:romaji];
    
    if (index==selectedIndex&&selectedIndex!=-1) {
        cell.contentView.backgroundColor = [UIColor redColor];
    }
    else{
         cell.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES; //index % 2 == 0;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    /*
    NSLog(@"Did tap at index %ld", (long)position);
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:NULL];
    
    NSString *fileName = (NSString *)[_currentData objectAtIndex:position][@"mp3"];
    if (![fileName isEqualToString:@"_"]) {
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle]
                                                              pathForResource:fileName
                                                              ofType:@"mp3"]];
        
        self.audioPlayer= [[AVAudioPlayer alloc]
                           initWithContentsOfURL:fileURL
                           error:nil];
        
        [self.audioPlayer play];
    }
    if (selectedIndex!=position) {
        selectedIndex = position;
    }
    
    [_gmGridView reloadData];
    */
    UIView *contentView = [[UIView alloc] initWithFrame:(CGRect){20,64,[UIScreen mainScreen].bounds.size.width-20*2,[UIScreen mainScreen].bounds.size.height-64-50}];
    UIButton *animation = [[UIButton alloc]initWithFrame:(CGRect){contentView.bounds.size.width-60,0,60,60}];
    animation.backgroundColor = [UIColor blueColor];
    [animation setTitle:@"Play" forState:UIControlStateNormal];
    [animation addTarget:self action:@selector(didTapOnPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *clear = [[UIButton alloc]initWithFrame:(CGRect){0,0,60,60}];
    clear.backgroundColor = [UIColor blueColor];
    [clear setTitle:@"Clear" forState:UIControlStateNormal];
    [clear addTarget:self action:@selector(didTapOnClearButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (!drawView) {
        drawView = [self createDrawViewFromView:contentView];
    }
    [contentView addSubview:drawView];
    
    [contentView addSubview:animation];
     [contentView addSubview:clear];
    [[KGModal sharedInstance] showWithContentView:contentView andAnimated:YES];
}
- (void)didTapOnPlayButton:(id)sender{
    [drawView animatePath];
}

- (void)didTapOnClearButton:(id)sender{
    [drawView clearDrawing];
}

- (DrawView *)createDrawViewFromView:(UIView *)view{
    DrawView *drawViewing = [[DrawView alloc] initWithFrame:view.bounds];
    drawViewing.strokeColor = [UIColor redColor];
    drawViewing.mode = DrawingModeDefault;
    drawViewing.canEdit = YES;
    drawViewing.strokeWidth = 25.0f;
    return drawViewing;
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    NSLog(@"Tap on empty space");
}

- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this item?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    
    [alert show];
    
    _lastDeleteItemIndexAsked = index;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [_currentData removeObjectAtIndex:_lastDeleteItemIndexAsked];
        [_gmGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor orangeColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor redColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return YES;
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    NSObject *object = [_currentData objectAtIndex:oldIndex];
    [_currentData removeObject:object];
    [_currentData insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [_currentData exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}


//////////////////////////////////////////////////////////////
#pragma mark DraggableGridViewTransformingDelegate
//////////////////////////////////////////////////////////////

- (CGSize)GMGridView:(GMGridView *)gridView sizeInFullSizeForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index inInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (INTERFACE_IS_PHONE)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(320, 210);
        }
        else
        {
            return CGSizeMake(300, 310);
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(700, 530);
        }
        else
        {
            return CGSizeMake(600, 500);
        }
    }
}

- (UIView *)GMGridView:(GMGridView *)gridView fullSizeViewForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    UIView *fullView = [[UIView alloc] init];
    fullView.backgroundColor = [UIColor yellowColor];
    fullView.layer.masksToBounds = NO;
    fullView.layer.cornerRadius = 8;
    
    CGSize size = [self GMGridView:gridView sizeInFullSizeForCell:cell atIndex:index inInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    fullView.bounds = CGRectMake(0, 0, size.width, size.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:fullView.bounds];
    label.text = [NSString stringWithFormat:@"Fullscreen View for cell at index %ld", (long)index];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (INTERFACE_IS_PHONE)
    {
        label.font = [UIFont boldSystemFontOfSize:15];
    }
    else
    {
        label.font = [UIFont boldSystemFontOfSize:20];
    }
    
    [fullView addSubview:label];
    
    
    return fullView;
}

- (void)GMGridView:(GMGridView *)gridView didStartTransformingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor blueColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEndTransformingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor redColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEnterFullSizeForCell:(UIView *)cell
{
    
}


//////////////////////////////////////////////////////////////
#pragma mark private methods
//////////////////////////////////////////////////////////////

- (void)addMoreItem
{
    // Example: adding object at the last position
    NSString *newItem = [NSString stringWithFormat:@"%d", (int)(arc4random() % 1000)];
    
    [_currentData addObject:newItem];
    [_gmGridView insertObjectAtIndex:[_currentData count] - 1 withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
}

- (void)removeItem
{
    // Example: removing last item
    if ([_currentData count] > 0)
    {
        NSInteger index = [_currentData count] - 1;
        
        [_gmGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
        [_currentData removeObjectAtIndex:index];
    }
}

- (void)refreshItem
{
    // Example: reloading last item
    if ([_currentData count] > 0)
    {
        NSInteger index = [_currentData count] - 1;
        
        NSString *newMessage = [NSString stringWithFormat:@"%d", (arc4random() % 1000)];
        
        [_currentData replaceObjectAtIndex:index withObject:newMessage];
        [_gmGridView reloadObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
}
@end
