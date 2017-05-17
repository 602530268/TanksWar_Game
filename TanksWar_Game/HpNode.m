//
//  HpNode.m
//  TanksWar_Game
//
//  Created by double on 2017/5/17.
//  Copyright © 2017年 double. All rights reserved.
//

#import "HpNode.h"

@interface HpNode ()

@property(nonatomic,strong) SKSpriteNode *hpProgress;

@end

@implementation HpNode

- (instancetype)hpWithColor:(UIColor *)hpColor bgColor:(UIColor *)bgColor size:(CGSize)size {
    if (!bgColor) bgColor = [UIColor clearColor];
    if (!hpColor) hpColor = [UIColor redColor];
    
    HpNode *hpNode = [HpNode spriteNodeWithColor:bgColor size:size];
    hpNode.hpProgress = [SKSpriteNode spriteNodeWithColor:hpColor size:size];
    hpNode.hpProgress.anchorPoint = CGPointZero;
    hpNode.hpProgress.position = CGPointMake(-size.width/2, -size.height/2);
    [hpNode addChild:hpNode.hpProgress];
    
    return hpNode;
}

- (void)setHpPercent:(CGFloat)hpPercent {
    _hpPercent = hpPercent;
    if (_hpPercent > 1.0) _hpPercent = 1.0;
    
    self.hpProgress.size = CGSizeMake(self.size.width * hpPercent, self.size.height);
}

@end
