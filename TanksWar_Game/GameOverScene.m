//
//  GameOverScene.m
//  TanksWar_Game
//
//  Created by double on 2017/5/17.
//  Copyright © 2017年 double. All rights reserved.
//

#import "GameOverScene.h"
#import "CreateTankScene.h"
#import "GameScene.h"
#import "MCManager.h"

@implementation GameOverScene

- (instancetype)initWithSize:(CGSize)size won:(BOOL)won {
    if (self = [super initWithSize:size]) {
        NSString * message;
        if (won) {
            message = @"You Won !";
        } else {
            message = @"You Lose ~";
        }
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Bradley Hand"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor whiteColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        
        [self mcManagerDelegateCallback];
    }
    return self;
}

- (void)mcManagerDelegateCallback {
    [MCManager shareInstance].sessionState = ^(MCSessionState state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CreateTankScene *createTankScene = [[CreateTankScene alloc] initWithSize:self.size];
            switch (state) {
                case MCSessionStateConnecting:
                    NSLog(@"正在连接...");
                    break;
                case MCSessionStateConnected:
                    NSLog(@"连接成功!");
                    break;
                case MCSessionStateNotConnected:
                default:
                    NSLog(@"连接失败~");
                    [self.view presentScene:createTankScene transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]]; //返回上一页面
                    
                    break;
            }
            
        });
    };
    [MCManager shareInstance].receiveData = ^(NSData *data) {
        NSDictionary *dataPacket = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        //收到重新开始的请求，同步执行
        if (dataPacket[@"startAgainPacket"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
                SKScene * gameScene = [[GameScene alloc] initWithSize:self.size];
                [self.view presentScene:gameScene transition: reveal];
            });

        }
    };
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSDictionary *startAgainPacket = @{@"startAgain":@YES};
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"startAgainPacket":startAgainPacket} options:NSJSONWritingPrettyPrinted error:nil];
    [[MCManager shareInstance] sendData:data finish:nil];
    
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    SKScene * gameScene = [[GameScene alloc] initWithSize:self.size];
    [self.view presentScene:gameScene transition: reveal];
}

@end
