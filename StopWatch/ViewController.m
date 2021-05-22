//
//  ViewController.m
//  StopWatch
//
//  Created by Shaik A S on 28/11/18.
//  Copyright © 2018 SHAIK AS. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property(nonatomic)NSTimeInterval stoppedTimeInterval;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *lapButton;
@property(strong,nonatomic)NSDate * startTime;
@property(strong,nonatomic) NSMutableArray * lapDetails;
@property(nonatomic)NSTimeInterval lastLapDuration;
@property(nonatomic)BOOL isEnd;
@property(nonatomic)NSInteger countOfLaps;
@end

@implementation ViewController
#define START @"start"
#define STOP @"pause"
#define RESET @"reset"
#define RESUME @"resume"
#define LAP @"lap"
#define TIMESINCEBEGINNING @"timelapsedfromstart"
#define TIMESINCELASTLAP @"timelapsedfrompause"
-(NSMutableArray *)lapDetails
{
    if(!_lapDetails)
    {
        _lapDetails = [[NSMutableArray alloc]init];
    }
    return _lapDetails;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isEnd = true;
    self.stoppedTimeInterval = 0;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.lapButton.hidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startWatch:(UIButton *)sender {
    
    if([self.startButton.titleLabel.text isEqualToString:STOP])
    {  [self.lapButton setTitle:RESET forState:UIControlStateNormal];
        [self watchIsStopped];
    }
    
    else
    {     self.lapButton.hidden = NO;
        self.isEnd = false;
        [self.startButton setTitle:STOP forState:UIControlStateNormal];
        [self.lapButton setTitle:LAP forState:UIControlStateNormal];
        dispatch_queue_t  otherQ = dispatch_queue_create("timeRunningQ", NULL);
        
        dispatch_async(otherQ, ^{
            [self startStopWatch];
        });
    }
    
    
}
-(void) watchIsStopped
{
    self.isEnd = true;
    [self.startButton setTitle:@"resume" forState:UIControlStateNormal];
    self.stoppedTimeInterval +=  ([self.startTime timeIntervalSinceNow] ) * -1;
}
- (IBAction)recordLap:(UIButton *)sender {
    if([sender.titleLabel.text isEqualToString:RESET])
    {
        [self resetWatch:sender];
    }
    else
    {  NSTimeInterval TimeSinceLastPause = [self.startTime timeIntervalSinceNow] * -1 + self.stoppedTimeInterval;
        NSDictionary * lapTime = @{  TIMESINCEBEGINNING :   [self convertTimeInterval: TimeSinceLastPause],      TIMESINCELASTLAP  : [self convertTimeInterval:TimeSinceLastPause - self.lastLapDuration]
                                   
                                         };
        self.lastLapDuration = TimeSinceLastPause;
        [self.lapDetails addObject:lapTime];
        self.countOfLaps = [self.lapDetails count] -1;
        [self.tableView reloadData];
    }
    
}
- (IBAction)resetWatch:(UIButton *)sender {
    self.isEnd = true;
    [self.startButton setTitle:@"start" forState:UIControlStateNormal];
    self.stoppedTimeInterval =0;
    self.lapDetails=nil;
    [self.tableView reloadData];
    self.lapButton.hidden = YES;
    self.TimeLabel.text = @"0:00:000";
   
}

-(void)startStopWatch
{ self.startTime = [NSDate date];
   
    for(;!self.isEnd ;)
    {
        NSTimeInterval  timeInterval =   [self.startTime timeIntervalSinceNow];
        [self setTime:(timeInterval *-1) + self.stoppedTimeInterval];
        [NSThread sleepForTimeInterval:0.008];
    }
    
        }
-(void)setTime : (NSTimeInterval) seconds
{    NSLog(@"%f",seconds);
    NSString * TimeToSet = [self convertTimeInterval:seconds];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.TimeLabel.text = TimeToSet;
    });
    
    
}
-(NSString *)convertTimeInterval : (NSTimeInterval) interval
{
    int min;
    int sec;
    int milliSec;
    milliSec = (interval - (int)interval ) * 1000;
    min = interval/60;
    sec = ((int)interval)%60;
    return  [NSString stringWithFormat:@"%d:%d:%d",min,sec,milliSec];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lapDetails count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Lap display cell"];
    NSDictionary * lapTime = [self.lapDetails objectAtIndex:self.countOfLaps - indexPath.row];
    NSString * title = [lapTime valueForKey:TIMESINCEBEGINNING];
    NSString * subtitle = [lapTime valueForKey:TIMESINCELASTLAP];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"LAPS";
}
@end
