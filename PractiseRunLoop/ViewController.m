//
//  ViewController.m
//  PractiseRunLoop
//
//  Created by robot on 4/24/16.
//  Copyright © 2016 codeFighter.com. All rights reserved.
//  QQ:1500190761 欢迎交流学习

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,strong) NSThread *myThread;
@property(nonatomic,assign) BOOL runLoopThreadDidFinishFlag;
@property(nonatomic,strong) dispatch_source_t timer;
@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic,strong) NSString *lastMode;
@property(nonatomic,assign) int  lastActivity;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
//    CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
//
//    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
//    CFRunLoopAddSource(runloop, source, kCFRunLoopCommonModes);
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
//        if (![self.lastMode isEqualToString:[[NSRunLoop currentRunLoop] currentMode]]) {
//            NSLog(@"lastMode:%@,lastActivity:%@",self.lastMode,[self stringWithActivity:self.lastActivity]);
//            NSLog(@"currentMode:%@,currentActivity:%@",[[NSRunLoop currentRunLoop] currentMode],[self stringWithActivity:activity]);
//
//        }
//        NSLog(@"lastMode:%@,lastActivity:%@",self.lastMode,[self stringWithActivity:self.lastActivity]);
        NSLog(@"currentMode:%@,currentActivity:%@",[[NSRunLoop currentRunLoop] currentMode],[self stringWithActivity:activity]);
        if (activity == kCFRunLoopExit) {
            NSLog(@"lastActivity:%@",[self stringWithActivity:self.lastActivity]);
        }
        self.lastMode = [[NSRunLoop currentRunLoop] currentMode];
        self.lastActivity = activity;
    });
    CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
//    CFRunLoopRun();
//    
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.view.backgroundColor = [UIColor redColor];
//    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view, typically from a nib.

//     [self simplePractiseBackGround];
//     [self simplePractiseMain];
    
    // [self tryPerformSelectorOnMianThread];
    // [self tryPerformSelectorOnBackGroundThread];
    
    // [self alwaysLiveBackGoundThread];
//     [self tryTimerOnMainThread];
    // [self tryTimerOnBackGrondThread];
    
//    [self runLoopAddDependance];
//    [self gcdTimer];
    
//    CFRunLoopWakeUp(runloop);
}

- (NSString *)stringWithActivity:(CFRunLoopActivity)activity
{
    NSString *str = nil;
    switch (activity) {
        case kCFRunLoopBeforeTimers:
            str = [NSString stringWithFormat:@"kCFRunLoopBeforeTimers:%@",@(activity)];
            break;
        case kCFRunLoopBeforeSources:
            str = [NSString stringWithFormat:@"kCFRunLoopBeforeSources:%@",@(activity)];
            break;
        case kCFRunLoopBeforeWaiting:
            str = [NSString stringWithFormat:@"kCFRunLoopBeforeWaiting:%@",@(activity)];
            break;
        case kCFRunLoopAfterWaiting:
            str = [NSString stringWithFormat:@"kCFRunLoopAfterWaiting:%@",@(activity)];
            break;
        case kCFRunLoopExit:
            str = [NSString stringWithFormat:@"kCFRunLoopExit:%@",@(activity)];
            break;
        case kCFRunLoopEntry:
            str = [NSString stringWithFormat:@"kCFRunLoopEntry:%@",@(activity)];
            break;
        default:
            
            break;
    }
    return str;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",@(indexPath.row)];
    return cell;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"%@",self.myThread);
    [self performSelector:@selector(doBackGroundThreadWork) onThread:self.myThread withObject:nil waitUntilDone:NO];
}

- (void)simplePractiseMain{

    while (1) {
        
        NSLog(@"while begin");
        // the thread be blocked here
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        NSLog(@"%@",runLoop);
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        // this will not be executed

        NSLog(@"while end");
        
    }

}
- (void)simplePractiseBackGround{

 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {

//
            NSPort *macPort = [NSPort port];
//            NSLog(@"while begin");
            NSRunLoop *subRunLoop = [NSRunLoop currentRunLoop];
            [subRunLoop addPort:macPort forMode:NSDefaultRunLoopMode];
            [subRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            [subRunLoop run];
            NSLog(@"while end");
            NSLog(@"%@",subRunLoop);
            
        }

    });

}

- (void)tryPerformSelectorOnMianThread{

    [self performSelector:@selector(mainThreadMethod) withObject:nil];
    

}
- (void)mainThreadMethod{

    NSLog(@"execute %s",__func__);
    // print: execute -[ViewController mainThreadMethod]
}

- (void)tryPerformSelectorOnBackGroundThread{
    
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
   
    [self performSelector:@selector(backGroundThread) onThread:[NSThread currentThread] withObject:nil waitUntilDone:NO];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop run];

});
}
- (void)backGroundThread{

    NSLog(@"%u",[NSThread isMainThread]);
    NSLog(@"execute %s",__FUNCTION__);

}
- (void)alwaysLiveBackGoundThread{

    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(myThreadRun) object:@"etund"];
    self.myThread = thread;
    [self.myThread start];

}
- (void)myThreadRun{

    NSLog(@"my thread run");
    
}

- (void)doBackGroundThreadWork{

    NSLog(@"do some work %s",__FUNCTION__);
}

- (void)tryTimerOnMainThread{

    NSTimer *myTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [myTimer fire];
    
}

- (void)tryTimerOnBackGrondThread{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSTimer *myTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [myTimer fire];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop run];

        
    });


}
- (void)timerAction{

//    sleep(2);
    NSLog(@"timer action");
}
- (void)runLoopAddDependance{
    
    self.runLoopThreadDidFinishFlag = NO;
    NSLog(@"Start a New Run Loop Thread");
    NSThread *runLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(handleRunLoopThreadTask) object:nil];
    [runLoopThread start];
    
    NSLog(@"Exit handleRunLoopThreadButtonTouchUpInside");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        
        while (!_runLoopThreadDidFinishFlag) {
            
            self.myThread = [NSThread currentThread];
            NSLog(@"Begin RunLoop");
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            NSPort *myPort = [NSPort port];
            [runLoop addPort:myPort forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            NSLog(@"End RunLoop");
            [self.myThread cancel];
            self.myThread = nil;
            
        }
    });

}
- (void)handleRunLoopThreadTask
{
    NSLog(@"Enter Run Loop Thread");
    for (NSInteger i = 0; i < 5; i ++) {
        NSLog(@"In Run Loop Thread, count = %ld", i);
        sleep(1);
    }
#if 0
    // 错误示范
    _runLoopThreadDidFinishFlag = YES;
    // 这个时候并不能执行线程完成之后的任务，因为Run Loop所在的线程并不知道runLoopThreadDidFinishFlag被重新赋值。Run Loop这个时候没有被任务事件源唤醒。
    // 正确的做法是使用 "selector"方法唤醒Run Loop。 即如下:
#endif
    NSLog(@"Exit Normal Thread");
    [self performSelector:@selector(tryOnMyThread) onThread:self.myThread withObject:nil waitUntilDone:NO];
    
    // NSLog(@"Exit Run Loop Thread");
}
- (void)tryOnMyThread{
    
    _runLoopThreadDidFinishFlag = YES;
    
}
- (void)gcdTimer{
    
    // get the queue
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    // creat timer
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // config the timer (starting time，interval)
    // set begining time
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    // set the interval
    uint64_t interver = (uint64_t)(1.0 * NSEC_PER_SEC);
    
    dispatch_source_set_timer(self.timer, start, interver, 0.0);
    
    dispatch_source_set_event_handler(self.timer, ^{
        
        // the tarsk needed to be processed async
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            for (int i = 0; i < 100000; i++) {
                
                NSLog(@"gcdTimer");
                
                
            }
            
        });

        
    });
    
    dispatch_resume(self.timer);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
