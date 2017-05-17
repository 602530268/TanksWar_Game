//
//  JoinVC.m
//  MC_Demo2
//
//  Created by double on 2017/5/13.
//  Copyright © 2017年 double. All rights reserved.
//

#import "JoinVC.h"
#import "MCManager.h"

static NSString * const JoinCellIdentifier = @"JoinCellIdentifier";

@interface JoinVC ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_roomArr;
}

@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JoinVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self createTableView];
    
    [[MCManager shareInstance] setTypeWith:MCTypeJoin];
    [self mcManagerDelegateCallback];
    
    if ([[MCManager shareInstance] getSessionState] == MCSessionStateConnected) {

    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[MCManager shareInstance] stop];
}

#pragma mark - UI
- (void)createTableView {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:JoinCellIdentifier];
}

- (void)navBarUI {
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"断开连接" style:UIBarButtonItemStylePlain target:self action:@selector(disConnect)];
    self.navigationItem.rightBarButtonItem = barBtnItem;
}

#pragma mark - 交互事件
- (IBAction)backEvent:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (!sender) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MCConnectSuccess" object:nil];
        }
    }];
}

- (IBAction)scanBtnAction:(id)sender {
    if ([self.scanBtn.titleLabel.text isEqualToString:@"开始扫描"]) {
        [self.scanBtn setTitle:@"停止扫描" forState:UIControlStateNormal];
        [[MCManager shareInstance] search:^(NSMutableArray *peerIDs) {
            _roomArr = peerIDs;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [_tableView reloadData];
            }];
        }];
    }else {
        [self.scanBtn setTitle:@"开始扫描" forState:UIControlStateNormal];
        [[MCManager shareInstance] stop];
    }
}

#pragma mark - 触发事件
//MCManager代理事件回调
- (void)mcManagerDelegateCallback {
    
    [MCManager shareInstance].sessionState = ^(MCSessionState state) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (state) {
                case MCSessionStateConnecting:
                    NSLog(@"正在连接...");
                    break;
                case MCSessionStateConnected:
                    NSLog(@"连接成功!");
                    [self.scanBtn setTitle:@"开始扫描" forState:UIControlStateNormal];
                    [self navBarUI];
                    [self backEvent:nil];
                    break;
                case MCSessionStateNotConnected:
                default:
                    NSLog(@"连接失败~");
                    [self.scanBtn setTitle:@"开始扫描" forState:UIControlStateNormal];
                    self.navigationItem.rightBarButtonItem = nil;
                    break;
            }  
        });

    };
    
    [MCManager shareInstance].receiveData = ^(NSData *data) {

    };
    [MCManager shareInstance].receiveResourceProgress = ^(CGFloat progrsss) {
        NSLog(@"receiveResourceProgress: %f",progrsss);
    };
    [MCManager shareInstance].lostPeerID = ^(MCPeerID *peerID) {
        NSLog(@"lost peerID: %@",peerID.displayName);
    };
}

- (void)sendDataWith:(NSData *)data {
    [[MCManager shareInstance] sendData:data finish:^(NSError *error) {
        if (error) {
            NSLog(@"send data fail: %@",error);
        }else {
            NSLog(@"send data success!");
        }
    }];
}

- (void)sendResourceWith:(NSString *)filePath {
    
    [[MCManager shareInstance] sendResource:filePath resourceName:@"fileName" sending:^(CGFloat progress) {
        NSLog(@"progress: %f",progress);

    } finish:^(NSError *error) {
        if (error) {
            NSLog(@"send resource fail: %@",error);
        }else {
            NSLog(@"send resource success!");
        }
    }];
}

- (void)disConnect {
    [[MCManager shareInstance] disconnect];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _roomArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JoinCellIdentifier forIndexPath:indexPath];
    MCPeerID *peerID = _roomArr[indexPath.row];
    cell.textLabel.text = peerID.displayName;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MCPeerID *peerID = _roomArr[indexPath.row];
    [[MCManager shareInstance] connectWithPeerID:peerID];
    NSLog(@"正在申请进入，等待主人同意...");
}

#pragma mark - 懒加载


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

@end
