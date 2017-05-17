//
//  TankNode.m
//  TanksWar_Game
//
//  Created by double on 2017/5/16.
//  Copyright © 2017年 double. All rights reserved.
//

#import "TankNode.h"
#import "GameOverScene.h"
#import "MCManager.h"

@interface TankNode ()

@property(nonatomic,strong) SKSpriteNode *header; //枪口

@end

@implementation TankNode

+ (TankNode *)tankWith:(UIColor *)headerColor bodyColor:(UIColor *)bodyColor size:(CGSize)size {
    TankNode *tank = [TankNode spriteNodeWithColor:bodyColor size:size];
    tank.header = [SKSpriteNode spriteNodeWithColor:headerColor size:CGSizeMake(size.width/5, size.height/2)];
    tank.header.position = CGPointMake(0, size.height/4);
    [tank addChild:tank.header];
    
    return tank;
}

- (void)changeColor:(UIColor *)headerColor bodyColor:(UIColor *)bodyColor {
    self.header.color = headerColor;
    self.color = bodyColor;
}

- (void)shootBullet {
    
    if (_direction == CCDirectionNone) return;  //玩家开始操控后才有供计算所需数据，没操控前不允许射击
    
    if (!_bullets) {
        _bullets = @[].mutableCopy;
    }
    
    BulletNode *bullet = [BulletNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(2.0, 5.0)];
    bullet.position = self.position;
    bullet.zRotation = self.zRotation;
    bullet.name = @"Bullet";
    bullet.ATK = 20.0;
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.size];
    bullet.physicsBody.affectedByGravity = NO;
    bullet.physicsBody.categoryBitMask = _bulletCategoryBitMask;
    bullet.physicsBody.contactTestBitMask = _bulletContactTestBitMask;
    bullet.physicsBody.collisionBitMask = _bulletCollisionBitMask;
    
    [self.scene addChild:bullet];
    [_bullets addObject:bullet];
    
    /*
     用点斜式计算终点，
     */
    
    CGPoint endPoint = CGPointZero;
    CGFloat x = 0;
    CGFloat y = self.scene.size.height; //已知条件 y
    //点斜式公式:y - y0 = k(x - x0)
    y = self.rotationAngle < 0 ? 0 : self.scene.size.height;
    CGFloat k = _k;
    CGFloat x1 = self.position.x;
    CGFloat y1 = self.position.y;
    x = (y - y1) / k + x1;
    
    //点斜式不适用于k=0的情况
    if (k == 0) {
        x = bullet.position.x;
        y = bullet.position.y;
        switch (_direction) {
            case CCDirectionLeft:
                x = 0;
                break;
            case CCDirectionRight:
                x = self.scene.size.width;
                break;
            default:
                break;
        }
    }
    
    endPoint = CGPointMake(x, y);
    
    //通过路程和指定速度求时间
    CGFloat distance = [Math pointsSpacingWith:@[[NSValue valueWithCGPoint:endPoint],
                                         [NSValue valueWithCGPoint:bullet.position]]];
    
    NSTimeInterval timeInterval = distance / bulletMovementSpeed;
    SKAction *shootAction = [SKAction moveTo:endPoint duration:timeInterval];
    [bullet runAction:shootAction completion:^{
        [bullet removeFromParent];
        [_bullets removeObject:bullet];
    }];
}

//设置器
- (void)setHP:(CGFloat)HP {
    _HP = HP;
    if (HP <= 0) {
        self.isDestroy = YES;
    }
    
    if (self.isDestroy) {
        self.physicsBody = nil;
        [self removeAllActions];
        SKAction *fadeAction = [SKAction fadeOutWithDuration:1.0];
        [self runAction:fadeAction completion:^{
            BOOL win = ![self.name isEqualToString:@"Player"];  //被摧毁的不是玩家则胜
            GameOverScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.scene.size won:win];
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            [self.scene.view presentScene:gameOverScene transition:reveal];
            
            [self removeFromParent];
            
            /*
             //玩家输了发送一个数据告诉对手他赢了,本身两部机子都有监测功能，这一步可以不要
             NSDictionary *gameOverPacket = @{@"result":@(win)};
             NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"gameOverPacket":gameOverPacket} options:NSJSONWritingPrettyPrinted error:nil];
             [[MCManager shareInstance] sendData:data finish:nil];
             */
        }];
        
    }
}



@end
