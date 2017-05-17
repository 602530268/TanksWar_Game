//
//  HomeScene.m
//  TanksWar_Game
//
//  Created by double on 2017/5/16.
//  Copyright © 2017年 double. All rights reserved.
//

#import "HomeScene.h"
#import "CreateTankScene.h"

@implementation HomeScene

#pragma mark - 系统方法
- (void)didMoveToView:(SKView *)view {
    
    [self createTitleNode];
    [self createOptions];
}

#pragma mark - 交互事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touches.anyObject locationInNode:self];
    SKNode *node = [self nodeAtPoint:touchPoint];
    if ([node isKindOfClass:[SKLabelNode class]]) {
        SKLabelNode *labelNode = (SKLabelNode *)node;
        if ([labelNode.text isEqualToString:@"开始游戏"]) {
            CreateTankScene *createTankScene = [[CreateTankScene alloc] initWithSize:self.size];
            createTankScene.lastScene = self;
            [self.view presentScene:createTankScene transition:[SKTransition doorsOpenHorizontalWithDuration:0.5]];
        }else if ([labelNode.text isEqualToString:@"游戏设置"]) {
            
        }
        NSLog(@"%@",labelNode.text);
    }
}

#pragma mark - UI
- (void)createTitleNode {
    
    SKLabelNode *titleNode = [[SKLabelNode alloc] initWithFontNamed:@"Bradley Hand"];
    titleNode.text = @"Tanks War!!!";
    titleNode.fontSize = 100.0;
    titleNode.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetHeight(self.frame) - titleNode.fontSize/3);
    titleNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    
    [self addChild:titleNode];
}

- (void)createOptions {
    NSArray *optionsTitle = @[@"开始游戏",
                              @"游戏设置(暂不能用)"];
    for (int i = 0; i < optionsTitle.count; i++) {
        SKLabelNode *itemNode = [SKLabelNode labelNodeWithText:optionsTitle[i]];
        itemNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        itemNode.fontSize = 50.0;
        itemNode.position = CGPointMake(CGRectGetMidX(self.frame),
                                        CGRectGetMidY(self.frame) - i * (itemNode.fontSize + 20));
        itemNode.name = optionsTitle[i];
        [self addChild:itemNode];
    }
}

@end
