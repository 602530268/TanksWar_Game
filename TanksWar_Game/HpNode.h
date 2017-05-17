//
//  HpNode.h
//  TanksWar_Game
//
//  Created by double on 2017/5/17.
//  Copyright © 2017年 double. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface HpNode : SKSpriteNode

@property(nonatomic,assign) CGFloat hpPercent;

- (instancetype)hpWithColor:(UIColor *)hpColor bgColor:(UIColor *)bgColor size:(CGSize)size;

@end
