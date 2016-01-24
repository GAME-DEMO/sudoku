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

@property (nonatomic, strong) SKTextureAtlas *gameTextureAtlas;

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

- (instancetype)init {
    if (self = [super init]) {
        int scale = [UIScreen mainScreen].scale;
        NSString *atlasName = [NSString stringWithFormat:@"Game@%dx", scale];
        self.gameTextureAtlas = [SKTextureAtlas atlasNamed:atlasName];
    }
    return self;
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
    NSMutableArray *cubeValueArray = [[NSMutableArray alloc] initWithArray:self.resultArray copyItems:YES];
    std::vector<int> cubeValues;
    int emptyCellsCount = 0;
    
    do {
        cubeValues.clear();
        for (int i = 0; i < cubeValueArray.count; ++i) {
            cubeValues.push_back([[cubeValueArray objectAtIndex:i] intValue]);
        }
        
        emptyCellsCount = 40;
        
        switch (level) {
            case DIFFICULT_LEVEL_EASY: {
                emptyCellsCount = arc4random() % 6 + 0;
                break;
            }
                
            case DIFFICULT_LEVEL_MID: {
                emptyCellsCount = arc4random() % 4 + 6;
                break;
            }
                
            case DIFFICULT_LEVEL_HARD: {
                emptyCellsCount = arc4random() % 4 + 10;
                break;
            }
                
            case DIFFICULT_LEVEL_EXTRE_HARD: {
                emptyCellsCount = arc4random() % 5 + 14;
                break;
            }
                
            case DIFFICULT_LEVEL_NONE:
            default:
                break;
        }
        
        NSMutableArray *emptyCellIndexArray = [NSMutableArray arrayWithCapacity:emptyCellsCount];
        while (emptyCellsCount > 0) {
            int emptyCellIndex = arc4random() % 81;
            if ([emptyCellIndexArray indexOfObject:@(emptyCellIndex)] == NSNotFound &&
                cubeValues[emptyCellIndex] != 0) {
                [emptyCellIndexArray addObject:@(emptyCellIndex)];
                cubeValues[emptyCellIndex] = 0;
                emptyCellsCount--;
            }
        }
        
        resultsCount = ResultsCount(&cubeValues, YES);
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

- (void)cubeDidSelect:(SudokuCubeNode *)cube {
    
}

@end
