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
    std::vector<int> cubeValues = RandomResult();
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:GetCubesCountForAll()];
    for (int i = 0; i < cubeValues.size(); ++i) {
        [results addObject:@(cubeValues[i])];
    }
    self.resultArray = [NSArray arrayWithArray:results];
}

- (NSArray *)randomResultForLevel:(DIFFICULT_LEVEL)level {
    [self randomResult];
    
    int resultsCount = 0;
    std::vector<int> cubeValues;
    
    do {
        resultsCount = 0;
        cubeValues.clear();
        for (int i = 0; i < self.resultArray.count; ++i) {
            cubeValues.push_back([[self.resultArray objectAtIndex:i] intValue]);
        }
        
        int emptyCellsCount = 0;
        switch (level) {
            case DIFFICULT_LEVEL_EASY: {
                emptyCellsCount = arc4random() % 6 + 40;
                break;
            }
                
            case DIFFICULT_LEVEL_MID: {
                emptyCellsCount = arc4random() % 4 + 46;
                break;
            }
                
            case DIFFICULT_LEVEL_HARD: {
                emptyCellsCount = arc4random() % 4 + 50;
                break;
            }
                
            case DIFFICULT_LEVEL_EXTRE_HARD: {
                emptyCellsCount = arc4random() % 5 + 54;
                break;
            }
                
            case DIFFICULT_LEVEL_NONE:
            default:
                break;
        }
        
        NSMutableArray *emptyCells = [NSMutableArray arrayWithCapacity:emptyCellsCount];
        while (emptyCellsCount > 0) {
            int emptyCellIndex = arc4random() % 81;
            if ([emptyCells indexOfObject:@(emptyCellIndex)] == NSNotFound) {
                [emptyCells addObject:@(emptyCellIndex)];
                cubeValues[emptyCellIndex] = 0;
                emptyCellsCount--;
            }
        }
        
        resultsCount = ResultsCount(cubeValues, YES);
    } while (resultsCount != 1);
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:cubeValues.size()];
    for (int i = 0; i < cubeValues.size(); ++i) {
        [results addObject:(@(cubeValues[i]))];
    }
    return results;
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
