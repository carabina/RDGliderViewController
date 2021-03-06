//
//  ContentViewController.h
//  GliderSample
//
//  Created by Guillermo Delgado on 03/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController

- (void)setIndex:(NSUInteger)index ofMax:(NSUInteger)max;
- (void)setOffset:(NSString *)offset;

- (instancetype)initWithLength:(CGFloat)lenght;

@end
