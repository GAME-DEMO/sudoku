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

@interface Presenter : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) int eachCount;
@property (nonatomic, readonly) int dimension;

@property (nonatomic, readonly) NSArray *resultArray;


#pragma mark - View related
/////////////////////////////////////////
/// Y, ROW
/// |-------------------|
/// |----6----7----8----|
/// |----3----4----5----|
/// |----0----1----2----|
/// |-------------------| X, COL
@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) UIEdgeInsets viewEdgeInsets;

// Sudoku Square, width == height
@property (nonatomic, readonly) CGFloat sudokuWidth;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, readonly) CGFloat cubeWidth;



- (void)mainTest;

#pragma mark - UI related

+ (BOOL)isPortrait;
+ (BOOL)isLandscape;

+ (BOOL)isPortraitForSize:(CGSize)size;
+ (BOOL)isLandscapeForSize:(CGSize)size;



@end
