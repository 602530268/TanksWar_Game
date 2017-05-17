//
//  Joystick.h
//  TanksWar_Game
//
//  Created by double on 2017/5/16.
//  Copyright © 2017年 double. All rights reserved.
//

//操控杆

#import <SpriteKit/SpriteKit.h>
@class Joystick;

@protocol JoystickDelegate <NSObject>

- (void)joystick:(Joystick *)joystick touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)joystick:(Joystick *)joystick touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)joystick:(Joystick *)joystick touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end

@interface Joystick : SKSpriteNode

@property(nonatomic,weak) id <JoystickDelegate>delegate;
@property(nonatomic,assign) CGPoint velocity;  //速度,根据滑杆移动幅度计算
@property(nonatomic,assign) CGFloat rotationAngle;  //z轴旋转角度
@property(nonatomic,assign) CGFloat angle;  //坐标系上选择角度
@property(nonatomic,assign) CGFloat k;  //斜率(与x轴正方形的夹角)
@property(nonatomic,assign) BOOL isTracking;   //正在控制;
@property(nonatomic,assign) DirectionType directionType;    //方向判断类型，默认为上下左右
@property(nonatomic,assign) CCDirection direction;    //滑杆方向
@property(nonatomic,copy) void (^trackingHandle)(); //滑杆使用时帧数刷新回调，保证每帧动画都能及时处理

//创建操控杆
- (instancetype)initWithJoystickImageName:(NSString *)joystickImageName
                          sliderImageName:(NSString *)sliderImageName
                               sliderSize:(CGSize)sliderSize
                                     size:(CGSize)size;

//计算滑杆方向
- (CCDirection)handleCCDirection:(DirectionType)directionType;

@end
