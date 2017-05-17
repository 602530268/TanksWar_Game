//
//  CCMacro.h
//  Zombie_Demo2
//
//  Created by double on 2017/5/5.
//  Copyright © 2017年 double. All rights reserved.
//

#ifndef CCMacro_h
#define CCMacro_h

typedef NS_ENUM(NSUInteger,DirectionType) {
    DirectionTypeNone,  
    DirectionTypeTBLR,  //上下左右
    DirectionTypeEight, //八个方向
};

//方向
typedef NS_ENUM(NSUInteger,CCDirection) {
    CCDirectionNone,
    CCDirectionTop,
    CCDirectionBottom,
    CCDirectionLeft,
    CCDirectionRight,
    CCDirectionTopLeft,
    CCDirectionTopRight,
    CCDirectionBottomLeft,
    CCDirectionBottomRight,
};

static const CGFloat playerMovementSpeed = 150.0;   //玩家移动速度
static const CGFloat bulletMovementSpeed = 300.0;   //子弹移动速度

static const uint32_t playerBitMask = 0x1 << 1;    //物理体参数
static const uint32_t enemyBitMask = 0x1 << 2;

static const uint32_t playerBulletBitMask = 0x1 << 3;
static const uint32_t enemyBulletBitMask = 0x1 << 4;

static const uint32_t wallBitMask = 0x1 << 5;   //墙壁



#endif /* CCMacro_h */
