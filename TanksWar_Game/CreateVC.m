//
//  CreateVC.m
//  MC_Demo2
//
//  Created by double on 2017/5/13.
//  Copyright © 2017年 double. All rights reserved.
//

#import "CreateVC.h"
#import "MCManager.h"
#import "CreateTankScene.h"

@interface CreateVC ()

@property (weak, nonatomic) IBOutlet UIButton *openRoomBtn;

@end

@implementation CreateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[MCManager shareInstance] setType:MCTypeCreate];
    if ([[MCManager shareInstance] getSessionState] == MCSessionStateConnected) {

    }
    [self mcManagerDelegateCallback];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[MCManager shareInstance] stop];
}

#pragma mark - UI
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

- (IBAction)openOrCloseBtnAction:(id)sender {
    if ([self.openRoomBtn.titleLabel.text isEqualToString:@"打开房间"]) {
        [self.openRoomBtn setTitle:@"关闭房间" forState:UIControlStateNormal];        
        [[MCManager shareInstance] create:^(MCPeerID *peerID) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"%@请求加入房间",peerID.displayName] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[MCManager shareInstance] handleJoinRequest:NO];
                }];
                UIAlertAction *agreeAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[MCManager shareInstance] handleJoinRequest:YES];
                }];
                [alertController addAction:cancelAction];
                [alertController addAction:agreeAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }];
        }];
    }else {
        [self.openRoomBtn setTitle:@"打开房间" forState:UIControlStateNormal];
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
                    [self.openRoomBtn setTitle:@"打开房间" forState:UIControlStateNormal];
                    [self navBarUI];
                    [self backEvent:nil];

                    break;
                case MCSessionStateNotConnected:
                default:
                    NSLog(@"连接失败~");
                    [self.openRoomBtn setTitle:@"打开房间" forState:UIControlStateNormal];
                    self.navigationItem.rightBarButtonItem = nil;
                    break;
            }
            
        });
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
