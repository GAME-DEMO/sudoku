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

@property (nonatomic, strong) NSArray *resultArray;

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

- (int)groupsCount {
    return GetGroupsCount();
}

- (int)cubesCountForDimension {
    return GetCubesCountForDimension();
}

- (int)cubesCountForAll {
    return GetCubesCountForAll();
}

- (int)rowFromCubeIndx:(int)index {
    return index / self.dimension;
}

- (int)colFromCubeIndex:(int)index {
    return index % self.dimension;
}

- (int)groupIndexFromCubeIndex:(int)index {
    int row = [self rowFromCubeIndx:index];
    int col = [self colFromCubeIndex:index];
    
    return (row / self.eachCount) * self.eachCount + col / self.eachCount;
}

- (void)randomResult {
    RandomResult();
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:GetCubesCountForAll()];
    std::vector<int> cubeValues = GetCubeValues();
    for (int i = 0; i < cubeValues.size(); ++i) {
        [results addObject:@(cubeValues[i])];
    }
    self.resultArray = [NSArray arrayWithArray:results];
}

#pragma mark - UI related

+ (UIInterfaceOrientation) appOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

+ (BOOL)isPortrait {
    UIInterfaceOrientation orientation = [self appOrientation];
    return orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown;
}

+ (BOOL)isLandscape {
    UIInterfaceOrientation orientation = [self appOrientation];
    return orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight;
}

+ (BOOL)isPortraitForSize:(CGSize)size {
    return size.width <= size.height;
}

+ (BOOL)isLandscapeForSize:(CGSize)size {
    return size.width > size.height;
}

@end
