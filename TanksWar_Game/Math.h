//
//  Math.h
//  Zombie_Demo2
//
//  Created by double on 2017/5/5.
//  Copyright © 2017年 double. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Math : NSObject

//两点间距
+ (CGFloat)pointsSpacingWith:(NSArray <NSValue *> *)points;

//等腰直角三角形根据斜边求边长
+ (CGFloat)isoscelesTriangleSeekRightAngleWithHypotenuse:(CGFloat)hypotenuse;

@end
