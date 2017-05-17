//
//  SKHandle.m
//  TanksWar_Game
//
//  Created by double on 2017/5/17.
//  Copyright © 2017年 double. All rights reserved.
//

#import "SKHandle.h"

@implementation SKHandle

//根据类名判断数组内的元素是否为碰撞的两个物体
+ (BOOL)checkContactWithClass:(NSArray <Class>*)objs contact:(SKPhysicsContact *)contact {
    BOOL flag = NO;
    if (objs.count != 2) return NO;
    
    NSString *className1 = NSStringFromClass(objs[0]);
    NSString *className2 = NSStringFromClass(objs[1]);
    
    NSString *bodyAClassName = NSStringFromClass([contact.bodyA.node class]);
    NSString *bodyBClassName = NSStringFromClass([contact.bodyB.node class]);
    
    if ([className1 isEqualToString:bodyAClassName] && [className2 isEqualToString:bodyBClassName]) {
        return YES;
    }else if ([className1 isEqualToString:bodyBClassName] && [className2 isEqualToString:bodyAClassName]) {
        return YES;
    }
    
    return flag;
}

//根据node.name判断数组内的元素是否为碰撞的两个物体
+ (BOOL)checkContactWithNodeName:(NSArray <NSString*>*)objs contact:(SKPhysicsContact *)contact {
    BOOL flag = NO;
    if (objs.count != 2) return NO;
    
    NSString *nodeName1 = objs[0];
    NSString *nodeName2 = objs[1];
    
    NSString *bodyANodeName = contact.bodyA.node.name;
    NSString *bodyBNodeName = contact.bodyB.node.name;
    
    if ([nodeName1 isEqualToString:bodyANodeName] && [nodeName2 isEqualToString:bodyBNodeName]) {
        return YES;
    }else if ([nodeName1 isEqualToString:bodyBNodeName] && [nodeName2 isEqualToString:bodyANodeName]) {
        return YES;
    }
    
    return flag;
}

//根据node.name获取碰撞体，如果没有返回nil
+ (SKNode *)getNodeWithNodeName:(NSString *)nodeName contact:(SKPhysicsContact *)contact {
    SKNode *node;
    if ([contact.bodyA.node.name isEqualToString:nodeName]) {
        node = contact.bodyA.node;
    }else if ([contact.bodyB.node.name isEqualToString:nodeName]) {
        node = contact.bodyB.node;
    }
    
    return node;
}

@end
