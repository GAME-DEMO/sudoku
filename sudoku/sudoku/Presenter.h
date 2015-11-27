//
//  Presenter.h
//  sudoku
//
//  Created by Peng Wang on 11/21/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Presenter : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign) int eachCount;
@property (nonatomic, assign) int dimension;


@property (nonatomic, readonly) NSArray *resultArray;


- (void)mainTest;

@end
