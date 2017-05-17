//
//  CreateTankScene.m
//  TanksWar_Game
//
//  Created by double on 2017/5/16.
//  Copyright © 2017年 double. All rights reserved.
//

#import "CreateTankScene.h"
#import "TankNode.h"
#import "CreateVC.h"
#import "JoinVC.h"
#import "GameScene.h"

@interface CreateTankScene ()


@end

@implementation CreateTankScene

#pragma mark - 系统方法
- (void)didMoveToView:(SKView *)view {
    [self createTank];
    [self createCreateOrSearchUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mcConnectSuccess) name:@"MCConnectSuccess" object:nil];
}

#pragma mark - 交互事件
- (void)backEvent:(UIButton *)sender {
    NSLog(@"back");
    if (self.lastScene) {
        [sender removeFromSuperview];
        [self.view presentScene:self.lastScene];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touches.anyObject locationInNode:self];
    SKNode *node = [self nodeAtPoint:touchPoint];
    if ([node isKindOfClass:[SKLabelNode class]]) {
        SKLabelNode *labelNode = (SKLabelNode *)node;
        
        UIViewController *presentVC;
        if ([labelNode.text isEqualToString:@"创建房间"]) {
            CreateVC *createVC = [[CreateVC alloc] init];
            presentVC = createVC;
        }else if ([labelNode.text isEqualToString:@"搜索房间"]) {
            JoinVC *joinVC = [[JoinVC alloc] init];
            presentVC = joinVC;
        }
        
        UIViewController *vc = [self viewController];
        if (vc) {
            [vc presentViewController:presentVC animated:YES completion:nil];
        }else {
            NSLog(@"无法获取当前控制器");
        }
        NSLog(@"%@",labelNode.text);
    }
}

#pragma mark - 触发事件

#pragma mark - 通知
//mc连接成功广播
- (void)mcConnectSuccess {
    GameScene *gameScene = [[GameScene alloc] initWithSize:self.size];
    [self.view presentScene:gameScene transition:[SKTransition doorsOpenVerticalWithDuration:0.5]];
}

#pragma mark - 私有方法
- (UIViewController *)viewController {
    for (UIView* next = self.view; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark - UI
- (void)createTank {

    NSArray *colorArr = @[[UIColor redColor],
                          [UIColor blueColor]];
    for (int i = 0; i < colorArr.count; i++) {

        TankNode *tank = [TankNode tankWith:colorArr[i] bodyColor:[UIColor lightGrayColor] size:CGSizeMake(80, 100)];
        tank.position = CGPointMake(self.size.width/4 + i * self.size.width/2,
                                     CGRectGetMidY(self.frame) + tank.size.height/2);
        [self addChild:tank];
    }
}

- (void)createCreateOrSearchUI {
    NSArray *optionsTitle = @[@"创建房间",
                              @"搜索房间"];
    
    for (int i = 0; i < optionsTitle.count; i++) {
        SKLabelNode *itemNode = [SKLabelNode labelNodeWithText:optionsTitle[i]];
        itemNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        itemNode.fontSize = 40.0;
        itemNode.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame) - i * (itemNode.fontSize + 20));
        itemNode.name = optionsTitle[i];
        [self addChild:itemNode];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MCConnectSuccess" object:nil];
}

@end
