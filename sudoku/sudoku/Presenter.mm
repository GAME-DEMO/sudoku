//
//  Presenter.m
//  sudoku
//
//  Created by Peng Wang on 11/21/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import "Presenter.h"
#import "Algorithm.h"

@interface Presenter ()


@end

@implementation Presenter

+ (instancetype)sharedInstance {
    static Presenter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Presenter alloc] init];
    });
    return instance;
}

- (int)eachCount {
    return GetEachCount();
}

- (int)dimension {
    return GetDimension();
}

- (CGFloat)sudokuWidth {
    return self.viewWidth - self.viewEdgeInsets.left - self.viewEdgeInsets.right;
}

- (CGFloat)cubeWidth {
    return (self.sudokuWidth - (self.dimension + 1) * self.lineWidth) / self.dimension;
}

- (void)mainTest {
    MainTest();
}

@end
