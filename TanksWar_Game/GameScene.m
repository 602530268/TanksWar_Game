//
//  GameScene.m
//  TanksWar_Game
//
//  Created by double on 2017/5/16.
//  Copyright © 2017年 double. All rights reserved.
//

#import "GameScene.h"
#import "Joystick.h"
#import "TankNode.h"
#import "MCManager.h"
#import "CreateTankScene.h"
#import "GameOverScene.h"
#import "HpNode.h"

#ifdef DEBUG
#define NSLog(...) printf("%s %d行:%s\n",__FUNCTION__,__LINE__,[[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

@interface GameScene ()<SKPhysicsContactDelegate,JoystickDelegate>
{
    Joystick *_joystick;
    TankNode *_player;
    NSMutableArray *_bullets;
    TankNode *_enemyTank;
    
    HpNode *_playerHPNode;
    HpNode *_enemyHPNode;
}

@end

@implementation GameScene

#pragma mark - 系统方法
- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        self.physicsBody.categoryBitMask = wallBitMask;
        self.physicsBody.contactTestBitMask = playerBulletBitMask | enemyBulletBitMask;
        self.physicsBody.collisionBitMask = 0;
        self.name = @"Wall";
    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
    
    _bullets = @[].mutableCopy;
    
    [self createJoystick];
    [self createTankNode];
    [self addEnemyTank];
    
    [self createMenuBar];
    
    //每隔一段时间检查一遍错误数据并修正
    SKAction *checkErrorAction = [SKAction runBlock:^{
        [self checkErrorData];
    }];
    SKAction *waitCheckErrorAction = [SKAction waitForDuration:5.0];
    [self runAction:[SKAction repeatActionForever:[SKAction group:@[checkErrorAction,waitCheckErrorAction]]]];
    
    [self mcManagerDelegateCallback];
}

- (void)update:(NSTimeInterval)currentTime {
    
    if (_player.isDestroy) return;
    if ([[MCManager shareInstance] getSessionState] != MCSessionStateConnected) return;
    
    if (_joystick.isTracking) {
        
        //状态数据包
        NSDictionary *statePacket = @{@"pointX":@(_player.position.x),
                                      @"pointY":@(_player.position.y),
                                      @"rotationAngle":@(_player.rotationAngle),
                                      @"k":@(_player.k),
                                      @"zRotation":@(_player.zRotation),
                                      @"width":@(self.size.width),  //用作屏幕比值
                                      @"height":@(self.size.height),
                                      @"direction":@(_player.direction)};
        NSDictionary *dataPacket = @{@"statePacket":statePacket};
        NSData *data = [NSJSONSerialization dataWithJSONObject:dataPacket options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%f",(float)data.length/1024);
        [[MCManager shareInstance] sendData:data finish:nil];
    }
    
}

//每次添加新node后保证控制杆在最顶层不被遮盖
- (void)addChild:(SKNode *)node {
    [super addChild:node];
    if (node != _joystick && _joystick) {
        [_joystick removeFromParent];
        [self insertChild:_joystick atIndex:self.children.count];
    }
}

#pragma mark - 交互事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_player.isDestroy) return;
    
    //发射炮弹
    [_player shootBullet];
    
    //命令包
    NSDictionary *attackPacket = @{@"shoot":@"1"};
    NSDictionary *dataPacket = @{@"attackPacket":attackPacket};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataPacket options:NSJSONWritingPrettyPrinted error:nil];
    [[MCManager shareInstance] sendData:data finish:nil];
}

#pragma mark - 触发事件
//检查并修正错误数据
- (void)checkErrorData {
    
    if (!CGRectContainsPoint(self.frame, _player.position)) {
        NSLog(@"玩家位置错误:%@",[NSValue valueWithCGPoint:_player.position]);
        [_player removeFromParent];
        [self createTankNode];
    }
    if (!CGRectContainsPoint(self.frame, _enemyTank.position)) {
        NSLog(@"对手位置错误:%@",[NSValue valueWithCGPoint:_enemyTank.position]);
        [_enemyTank removeFromParent];
        [self addEnemyTank];
    }
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
    
    //接收帧数据包
    [MCManager shareInstance].receiveData = ^(NSData *data) {
        
        NSDictionary *dataPacket = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSDictionary *statePacket = dataPacket[@"statePacket"];
        NSDictionary *attackPacket = dataPacket[@"attackPacket"];
        NSDictionary *gameOverPacket = dataPacket[@"gameOverPacket"];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (statePacket) {
                CGFloat width = [statePacket[@"width"] floatValue];
                CGFloat height = [statePacket[@"height"] floatValue];
                CGFloat pointX = [statePacket[@"pointX"] floatValue];
                CGFloat pointY = [statePacket[@"pointY"] floatValue];
                
                CGPoint point = CGPointMake((self.size.width * pointX) / width, (self.size.height * pointY) / height);
                CGFloat rotationAngle = [statePacket[@"rotationAngle"] floatValue];
                CGFloat k = [statePacket[@"k"] floatValue];
                CGFloat zRotation = [statePacket[@"zRotation"] floatValue];
                CCDirection direction = [statePacket[@"direction"] integerValue];
                
                _enemyTank.position = point;
                _enemyTank.rotationAngle = rotationAngle;
                _enemyTank.k = k;
                _enemyTank.zRotation = zRotation;
                _enemyTank.direction = direction;
            }
            if (attackPacket) {
                [_enemyTank shootBullet];
            }
            
            if (gameOverPacket) {
                [self removeAllActions];
                BOOL win = [gameOverPacket[@"result"] boolValue];
                GameOverScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:win];
                SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
                [self.view presentScene:gameOverScene transition:reveal];
            }
//            NSLog(@"receive: %@",dataPacket);
        });
    };
}

#pragma mark - JoystickDelegate
- (void)joystick:(Joystick *)joystick touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)joystick:(Joystick *)joystick touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(CGPointEqualToPoint(joystick.velocity, CGPointZero)){
        
        joystick.trackingHandle = ^(){
            _player.zRotation = _joystick.rotationAngle - M_PI_2;   //z轴旋转角度,tan的原点坐标与zRotation相差，这里减去
            _player.rotationAngle = _joystick.rotationAngle;
            _player.k = _joystick.k;
            _player.direction = _joystick.direction;
            CGPoint moveToPoint = CGPointMake(_player.position.x + _joystick.velocity.x, _player.position.y + _joystick.velocity.y);
            
            //不允许出界
            if (CGRectContainsPoint(self.frame, moveToPoint)) {
                
                CGFloat distance = sqrt(pow(fabs(moveToPoint.x - _player.position.x), 2) + pow(fabs(moveToPoint.y - _player.position.y), 2));
                NSTimeInterval timeInterval = distance / 100.0;
                SKAction *moveAction = [SKAction moveTo:moveToPoint duration:timeInterval];
                [_player runAction:moveAction];
            }
            
        };
        
    }
}

- (void)joystick:(Joystick *)joystick touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_player removeAllActions];
}

#pragma mark - SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact {
    NSLog(@"didBeginContact");
    
    BOOL bulletAndWall = [SKHandle checkContactWithNodeName:@[@"Bullet",@"Wall"] contact:contact];;
    BOOL bulletAndPlayer = [SKHandle checkContactWithNodeName:@[@"Bullet",@"Player"] contact:contact];;
    BOOL bulletAndEnemy = [SKHandle checkContactWithNodeName:@[@"Bullet",@"EnemyTank"] contact:contact];;
    BOOL playerAndWall = [SKHandle checkContactWithNodeName:@[@"player",@"Wall"] contact:contact];;
    
    BulletNode *bullet = (BulletNode *)[SKHandle getNodeWithNodeName:@"Bullet" contact:contact];
    
    if (bulletAndWall) {
        
    }else if (bulletAndPlayer) {
        _player.HP -= bullet.ATK;
        _playerHPNode.hpPercent = _player.HP / _player.hpUpperLimit;
    }else if (bulletAndEnemy) {
        BulletNode *bullet = (BulletNode *)[SKHandle getNodeWithNodeName:@"Bullet" contact:contact];
        _enemyTank.HP -= bullet.ATK;
        _enemyHPNode.hpPercent = _enemyTank.HP / _enemyTank.hpUpperLimit;
    }else if (playerAndWall) {
        [_player removeAllActions];
    }
        
    if (bullet) {   //目前子弹打中后都会消失，以后试着添加一些穿透弹（貌似没什么卵用）
        [bullet removeAllActions];
        [bullet removeFromParent];
    }
    
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    NSLog(@"didEndContact");
}

#pragma mark - UI
- (void)createJoystick {
    _joystick = [[Joystick alloc] initWithJoystickImageName:@"joystick" sliderImageName:@"joystickSlider" sliderSize:CGSizeMake(60, 60) size:CGSizeMake(120, 120)];
    _joystick.position = CGPointMake(100, 80);
    _joystick.delegate = self;
    _joystick.directionType = DirectionTypeTBLR;
    [self addChild:_joystick];
}

- (void)createTankNode {
    _player = [TankNode tankWith:[UIColor redColor] bodyColor:[UIColor lightGrayColor] size:CGSizeMake(30, 40)];
    _player.position = CGPointMake(300, 200);
    _player.name = @"Player";
    _player.HP = 100.0;
    _player.hpUpperLimit = 100.0;
    _player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_player.size];
    _player.physicsBody.affectedByGravity = NO;   //不受重力
//    _player.physicsBody.dynamic = NO; //是否受力
//    _player.physicsBody.allowsRotation = NO;  //是否受旋转力影响
    _player.physicsBody.categoryBitMask = playerBitMask;
    _player.physicsBody.contactTestBitMask = enemyBulletBitMask | wallBitMask;
    _player.physicsBody.collisionBitMask = 0;  //默认-1，表示与任何物体碰撞，0为不与任何物体碰撞
    [self addChild:_player];
    _player.bulletCategoryBitMask = playerBulletBitMask;
    _player.bulletContactTestBitMask = enemyBitMask | wallBitMask;
    _player.bulletCollisionBitMask = 0;
    
    //根据房主还是成员设定初始位置
    if ([MCManager shareInstance].type == MCTypeCreate) {
        _player.position = CGPointMake(self.size.width/4, CGRectGetMidY(self.frame));
    }else if ([MCManager shareInstance].type == MCTypeJoin) {
        _player.position = CGPointMake(self.size.width * 0.75, CGRectGetMidY(self.frame));
    }
}

- (void)addEnemyTank {
    _enemyTank = [TankNode tankWith:[UIColor blueColor] bodyColor:[UIColor lightGrayColor] size:CGSizeMake(30, 40)];
    _enemyTank.position = CGPointMake(400, 300);
    _enemyTank.name = @"EnemyTank";
    _enemyTank.HP = 100.0;
    _enemyTank.hpUpperLimit = 100.0;
    [self addChild:_enemyTank];
    _enemyTank.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_enemyTank.size];
    _enemyTank.physicsBody.affectedByGravity = NO;
//    _enemyTank.physicsBody.dynamic = NO;
//    _enemyTank.physicsBody.allowsRotation = NO;
    _enemyTank.physicsBody.categoryBitMask = enemyBitMask;
    _enemyTank.physicsBody.contactTestBitMask = playerBulletBitMask;
    _enemyTank.physicsBody.collisionBitMask = 0;
    _enemyTank.bulletCategoryBitMask = enemyBulletBitMask;
    _enemyTank.bulletContactTestBitMask = playerBitMask;
    _enemyTank.bulletCollisionBitMask = 0;
    
    //根据房主还是成员设定初始位置
    if ([MCManager shareInstance].type == MCTypeCreate) {
        _enemyTank.position = CGPointMake(self.size.width * 0.75, CGRectGetMidY(self.frame));
    }else if ([MCManager shareInstance].type == MCTypeJoin) {
        _enemyTank.position = CGPointMake(self.size.width/4, CGRectGetMidY(self.frame));

    }
}

- (void)createMenuBar {
    //菜单第二版再添加
    
    //血条
    for (int i = 0; i < 2; i++) {
        HpNode *hpNode = [[HpNode alloc] hpWithColor:[UIColor yellowColor] bgColor:[UIColor redColor] size:CGSizeMake(self.size.width/2 - 10, 5)];
        hpNode.position = CGPointMake(self.size.width/4 + self.size.width/2 * i, self.size.height - 5);
        [self addChild:hpNode];
        if (i == 0) {
            _playerHPNode = hpNode;
        }else {
            _enemyHPNode = hpNode;
        }
    }
}


#pragma mark - 私有方法


#pragma mark - 懒加载



@end
