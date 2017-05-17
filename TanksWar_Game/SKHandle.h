//
//  SKHandle.h
//  TanksWar_Game
//
//  Created by double on 2017/5/17.
//  Copyright © 2017年 double. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface SKHandle : NSObject

//根据类名判断数组内的元素是否为碰撞的两个物体
+ (BOOL)checkContactWithClass:(NSArray <Class>*)objs contact:(SKPhysicsContact *)contact;

//根据node.name判断数组内的元素是否为碰撞的两个物体
+ (BOOL)checkContactWithNodeName:(NSArray <NSString*>*)objs contact:(SKPhysicsContact *)contact;

//根据node.name获取碰撞体，如果没有返回nil
+ (SKNode *)getNodeWithNodeName:(NSString *)nodeName contact:(SKPhysicsContact *)contact;

@end
