//
//  Joystick.m
//  TanksWar_Game
//
//  Created by double on 2017/5/16.
//  Copyright © 2017年 double. All rights reserved.
//

#import "Joystick.h"

@interface Joystick ()
{
    SKSpriteNode *_joystickNode;
    SKSpriteNode *_sliderNode;
    CGFloat _radius; //半径
}

@end

@implementation Joystick

#pragma mark - 接口方法
- (instancetype)initWithJoystickImageName:(NSString *)joystickImageName
                          sliderImageName:(NSString *)sliderImageName
                               sliderSize:(CGSize)sliderSize
                                     size:(CGSize)size {
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        
        self.size = CGSizeMake(size.width, size.width); //保证为圆
        _radius = self.size.width/2.0;
        
        _joystickNode = [SKSpriteNode spriteNodeWithImageNamed:joystickImageName];
        _joystickNode.size = self.size;
        [self addChild:_joystickNode];
        
        _sliderNode = [SKSpriteNode spriteNodeWithImageNamed:sliderImageName];
        _sliderNode.size = sliderSize;
        [self addChild:_sliderNode];
        
        //随着帧数的刷新而响应，比NSTimer好用
        //每次刷新时回调
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(listen)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

//计算滑杆方向
- (CCDirection)handleCCDirection:(DirectionType)directionType {
    /*
     根据区间摇杆方向,在这里区间范围为:
     一二三四象限的角度为:
     0-90,90-180,-180- -90,-90-0
     */
    
    switch (directionType) {
        case DirectionTypeTBLR:
            if (_angle > 45 && _angle <= 135) {
                //摇杆向上
                _direction = CCDirectionTop;
            }else if (_angle > -135 && _angle <= -45) {
                //摇杆向下
                _direction = CCDirectionBottom;
            }else if ((_angle > 135 && _angle <= 180)
                      || (_angle > -180 && _angle <= -135)) {
                //摇杆向左
                _direction = CCDirectionLeft;
            }else if ((_angle > 0 && _angle <= 45)
                      || (_angle > -45 && _angle <= 0)) {
                //摇杆向右
                _direction = CCDirectionRight;
            }
            break;
        case DirectionTypeEight:
            if (_angle > 67.5 && _angle <= 112.5) {
                //摇杆向上
                _direction = CCDirectionTop;
            }else if (_angle > -112.5 && _angle <= -67.5) {
                //摇杆向下
                _direction = CCDirectionBottom;
            }else if ((_angle > 157.5 && _angle <= 180)
                      || (_rotationAngle > -180 && _rotationAngle <= -157.5)) {
                //摇杆向左
                _direction = CCDirectionLeft;
            }else if ((_angle > -22.5 && _angle <= 0) ||
                      (_angle > 0 && _angle <= 22.5)) {
                //摇杆向右
                _direction = CCDirectionRight;
            }else if (_angle > 112.5 && _angle <= 152.5) {
                //摇杆向左上
                _direction = CCDirectionTopLeft;
            }else if (_angle > 22.5 && _angle <= 67.5) {
                //摇杆向右上
                _direction = CCDirectionTopRight;
            }else if (_angle > -157.5 && _angle <= -112.5) {
                //摇杆向左下
                _direction = CCDirectionBottomLeft;
            }else if (_angle > -67.5 && _angle <= -22.5) {
                //摇杆向右下
                _direction = CCDirectionBottomRight;
            }
        default:
            break;
    }
    
    return _direction;
}

#pragma mark - 交互事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _isTracking = YES;
    if (self.delegate &&[self.delegate conformsToProtocol:@protocol(JoystickDelegate)]) {
        [self.delegate joystick:self touchesBegan:touches withEvent:event];
    }
    
    [self touchesMoved:touches withEvent:event];
    
    SKAction *showAction = [SKAction fadeInWithDuration:0.25];
    [_sliderNode runAction:showAction];
    [_joystickNode runAction:showAction];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CGPoint touchPoint = [[touches anyObject] locationInNode:self];
    
    /*
     手指所在位置的圆心距小于半径，直接设置位置，
     手指所在位置的圆心距大于半径，则通过计算将位置设在圆边，即不可超出的原则
     */
    static CGFloat touchRadius; //手指所在位置的圆心距
    touchRadius = sqrtf((fabs(powf(touchPoint.x, 2)) + fabs(powf(touchPoint.y, 2))));
    
    if (touchRadius < _radius) {
        _sliderNode.position = touchPoint;
    }else {
        CGFloat x = (touchPoint.x * _radius) / touchRadius;
        CGFloat y = (touchPoint.y * _radius) / touchRadius;
        _sliderNode.position = CGPointMake(x, y);
    }
    
    if (self.delegate &&[self.delegate conformsToProtocol:@protocol(JoystickDelegate)]) {
        [self.delegate joystick:self touchesMoved:touches withEvent:event];
    }
    
    self.velocity = _sliderNode.position;
    _rotationAngle = atan2(_sliderNode.position.y, _sliderNode.position.x); //求出tanθ的值
    _angle = _rotationAngle * (180/M_PI);   //角度
    
    if (_sliderNode.position.x == 0) {
        _k = 1;
    }else {
        _k = _sliderNode.position.y / _sliderNode.position.x;   //斜率
    }
    
    [self handleCCDirection:_directionType];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.delegate &&[self.delegate conformsToProtocol:@protocol(JoystickDelegate)]) {
        [self.delegate joystick:self touchesEnded:touches withEvent:event];
    }
    
    [self restore];
    
    SKAction *hiddenAction = [SKAction fadeOutWithDuration:0.25];
    [_sliderNode runAction:hiddenAction];
    [_joystickNode runAction:hiddenAction];
}

#pragma mark - 私有方法
//恢复滑杆位置并消除数据
- (void)restore {
    SKAction *restoreAction = [SKAction moveTo:CGPointZero duration:0.2];
    [_sliderNode runAction:restoreAction];
    _velocity = CGPointZero;
    _isTracking = NO;
    _direction = CCDirectionNone;
    _trackingHandle = nil;
}

- (void)listen {
    if (_isTracking && _trackingHandle) {
        _trackingHandle();
    }
}




@end

