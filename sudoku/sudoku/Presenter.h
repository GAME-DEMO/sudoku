//
//  Presenter.h
//  sudoku
//
//  Created by Peng Wang on 11/21/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSUInteger, DIFFICULT_LEVEL) {
    DIFFICULT_LEVEL_NONE,
    DIFFICULT_LEVEL_EASY,
    DIFFICULT_LEVEL_MID,
    DIFFICULT_LEVEL_HARD,
};

@interface Presenter : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) int eachCount;
@property (nonatomic, readonly) int dimension;
@property (nonatomic, readonly) int groupsCount;
@property (nonatomic, readonly) int cubesCountForDimension;
@property (nonatomic, readonly) int cubesCountForAll;
@property (nonatomic, readonly) NSArray *resultArray;

- (int)rowFromCubeIndx:(int)index;
- (int)colFromCubeIndex:(int)index;
- (int)groupIndexFromCubeIndex:(int)index;

- (void)randomResult;

#pragma mark - UI related

+ (BOOL)isPortrait;
+ (BOOL)isLandscape;

+ (BOOL)isPortraitForSize:(CGSize)size;
+ (BOOL)isLandscapeForSize:(CGSize)size;

@end
