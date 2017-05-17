//
//  Math.m
//  Zombie_Demo2
//
//  Created by double on 2017/5/5.
//  Copyright © 2017年 double. All rights reserved.
//

#import "Math.h"

@implementation Math

//两点间距
+ (CGFloat)pointsSpacingWith:(NSArray <NSValue *> *)points{
    
    if (points.count != 2) return 0;
    CGPoint point1 = [points[0] CGPointValue];
    CGPoint point2 = [points[1] CGPointValue];
    
    return sqrt(pow(fabs(point1.x - point2.x), 2) + pow(fabs(point1.y - point2.y), 2));
}

//等腰直角三角形根据斜边求边长
+ (CGFloat)isoscelesTriangleSeekRightAngleWithHypotenuse:(CGFloat)hypotenuse {
    return hypotenuse/sqrt(2.0);
}

@end
