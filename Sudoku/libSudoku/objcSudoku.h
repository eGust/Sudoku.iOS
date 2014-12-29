//
//  objcSudoku.h
//  Sudoku
//
//  Created by Chen Xi on 14/12/28.
//  Copyright (c) 2014年 Chen Xi. All rights reserved.
//

#ifndef Sudoku_objcSudoku_h
#define Sudoku_objcSudoku_h

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    osUnknown, osSolved, osInvalid,
    osUnsolvable, osOnlySolution, osMultiSolution,
    osCrossing, osCrossDone,
} OSudokuStatus;

/*
 SudokuStatus    CheckSudokuStatus(const SudokuData *const sd, bool checkSolvable);
 */

@interface OSudokuData : NSObject

@property (readonly, getter=getEmptyCount) NSInteger EmptyCount;
@property (readonly, getter=getGivenCount) NSInteger GivenCount;

+ (instancetype)Generate;

+ (instancetype)SudokuFromArray:(NSArray*)array;

+ (instancetype)SudokuFromCross:(OSudokuData*)sd;

+ (instancetype)Cross:(OSudokuData*)sd;

+ (NSArray*)Relatives:(NSInteger)index;

- (NSArray*)FindAllSolutions;

- (instancetype)Solve;

- (instancetype)initWithArray:(NSArray*)array;

- (OSudokuStatus)CheckStatus;

- (OSudokuStatus)CheckStatusWithSolvable:(BOOL)checkSolvable;

- (instancetype)Cross;

- (NSInteger)TileAtIndex:(NSInteger)index;

- (NSInteger)TileAtRow:(NSInteger)row andColumn:(NSInteger) col;

- (void)setTileAtIndex:(NSInteger)index withValue:(NSInteger) v;

- (void)setTileAtRow:(NSInteger)row andColumn:(NSInteger) col withValue:(NSInteger) v;

@end

#endif
