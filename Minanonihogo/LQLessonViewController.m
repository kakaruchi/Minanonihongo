//
//  LQLessonViewController.m
//  Minanonihogo
//
//  Created by Le Quang Long on 5/12/15.
//  Copyright (c) 2015 Kakaruchi. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "LQLessonViewController.h"
#import "LQLWordCell.h"
#import "LQLDefine.h"

#import "FMDB.h"
NSString *const kCellIdentifier = @"LQLWordCell";

@interface LQLessonViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger nLesson;
    UITableView *tblLesson;
    NSMutableArray *datasource;
     LQLWordCell * _offScreenCell;
}
@end

@implementation LQLessonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)initData{
    datasource = [NSMutableArray array];
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"kotoba" ofType:@"sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    
    // kind of experimentalish.
    [db setShouldCacheStatements:YES];
    
    NSString *strLesson = [NSString stringWithFormat:@"%@.%@",nLesson<26?@1:@2,nLesson<10?[NSString stringWithFormat:@"0%ld",(long)nLesson]:[NSNumber numberWithInteger:nLesson]];

    NSString *statement = [NSString stringWithFormat:@"SELECT * FROM vocabulary where lesson like '%@'",strLesson];
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

    [tblLesson reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self initData];
}

- (void)initTableLesson{

    //fix frame
    CGRect frame;
    frame.origin.y = 0;
    frame.origin.x = 0;
    frame.size.width =  [UIScreen mainScreen].bounds.size.width;
    frame.size.height = [UIScreen mainScreen].bounds.size.height - 64-50;

    tblLesson = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tblLesson.dataSource = self;
    tblLesson.delegate = self;
    
    [self.view addSubview:tblLesson];
    [tblLesson registerClass:[LQLWordCell class] forCellReuseIdentifier:kCellIdentifier];
    
    
    tblLesson.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray * result = [NSMutableArray array];
    NSDictionary * views = @{ @"tblLesson": tblLesson};
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tblLesson]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views]];
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tblLesson]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views]];
    [self.view addConstraints:result];
}

- (instancetype)initWithLesson:(NSInteger)lesson{
    if (self = [super init]) {
        nLesson = lesson;
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        self.view.backgroundColor = color;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initTableLesson];
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


#pragma mark - TABLE 
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     LQLWordCell *cell = (LQLWordCell *) [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    [self configureBasicCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (void)configureBasicCell:(LQLWordCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSString *kanji = datasource[indexPath.row][@"kanji"];
    NSString *hirakana = datasource[indexPath.row][@"hirakana"];
    NSString *meaning = datasource[indexPath.row][@"en_meaning"];
    NSString *vi_meaning = datasource[indexPath.row][@"vi_meaning"];
    NSString *urlPath = datasource[indexPath.row][@"image_url"];
    cell.lblKanji.text = kanji;
    cell.lblHirakana.text = [NSString stringWithFormat:@"「%@」",hirakana];
    cell.lblMeaning.text = meaning;
    cell.lblSample.text = vi_meaning;
    cell.imgWord.image = [UIImage imageNamed:@"Apu_Nahasapeemapetilon.png"];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static LQLWordCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [tblLesson dequeueReusableCellWithIdentifier:kCellIdentifier];
    });
    
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     NSString *kanji = datasource[indexPath.row][@"kanji"];
    
    if (mySpeechSynthesizer == nil)
    {
        mySpeechSynthesizer = [[AVSpeechSynthesizerFacade alloc] init];
        [mySpeechSynthesizer setMySpeechRate:1.0];
    }
    
    [mySpeechSynthesizer speakText:kanji];
}
@end
