//
//  GAButton.m
//  GliderSample
//
//  Created by Guillermo Delgado on 03/04/2017.
//  Copyright © 2017. All rights reserved.
//

#import "RDButton.h"

@interface RDButton()

@property (nonatomic) UIColor *bgColor;

@end

@implementation RDButton

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([self.bgColor CGColor]));
    CGContextFillPath(ctx);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _bgColor = [backgroundColor copy];
    super.backgroundColor = [UIColor clearColor];
}

@end
