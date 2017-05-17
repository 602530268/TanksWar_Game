//
//  TankNode.h
//  TanksWar_Game
//
//  Created by double on 2017/5/16.
//  Copyright © 2017年 double. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BulletNode.h"

@interface TankNode : SKSpriteNode

@property(nonatomic,assign) CGFloat HP;
@property(nonatomic,assign) CGFloat hpUpperLimit;   //血量上限
@property(nonatomic,assign) BOOL isDestroy;   //被摧毁
@property(nonatomic,assign) CGFloat rotationAngle;  //tanθ:以自身原点为中心，tan(旋转角度)，一二象限为正，三四象限为负,则根据正负值判断指向上还是下
@property(nonatomic,assign) CGFloat k;  //斜率
@property(nonatomic,assign) CCDirection direction;
@property(nonatomic,strong) NSMutableArray <BulletNode *> *bullets;

//子弹物理体参数
@property(nonatomic,assign) uint32_t bulletCategoryBitMask;
@property(nonatomic,assign) uint32_t bulletContactTestBitMask;
@property(nonatomic,assign) uint32_t bulletCollisionBitMask;

+ (TankNode *)tankWith:(UIColor *)headerColor bodyColor:(UIColor *)bodyColor size:(CGSize)size;

- (void)changeColor:(UIColor *)headerColor bodyColor:(UIColor *)bodyColor;

- (void)shootBullet;

@end
