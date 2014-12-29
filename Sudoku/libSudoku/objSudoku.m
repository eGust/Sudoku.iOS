//
//  objSudoku.m
//  Sudoku
//
//  Created by Chen Xi on 14/12/28.
//  Copyright (c) 2014年 Chen Xi. All rights reserved.
//

#import "objcSudoku.h"
#import "libSudoku.h"

@implementation OSudokuData {
    SudokuData data;
    int emptyCount;
}

// private

- (void)updateCount
{
    int r = 0;
    for (int i = 0; i < 81; i++) {
        r += (data.tiles[i] == 0);
    }
    emptyCount = r;
}

+ (instancetype)SudokuFromData:(const SudokuData* const) sd
{
    return [[OSudokuData new] initWithData:sd];
}

- (instancetype)initWithData:(const SudokuData* const) sd
{
    self = [super init];
    self->data = *sd;
    [self updateCount];
    return self;
}

- (id) copy
{
    return [OSudokuData SudokuFromData:&data];
}

// -------

+ (instancetype)SudokuFromArray:(NSArray*)array
{
    return [[OSudokuData new] initWithArray:array];
}

+ (instancetype)SudokuFromCross:(OSudokuData*)sd
{
    SudokuData csd = sd->data;
    CrossSudoku(&csd, nil, nil);
    return [OSudokuData SudokuFromData:&csd];
}

- (instancetype)initWithArray:(NSArray*)array
{
    self = [super init];
    for (int i = 0; i < [array count]; i++) {
        self->data.tiles[i] = (uint)[array objectAtIndex:i];
    }
    [self updateCount];
    return self;
}

+ (NSArray*)Relatives:(NSInteger)index
{
    NSMutableArray * r = [NSMutableArray arrayWithCapacity:20];
    const int *p = &Relative[index][0];
    for (int i = 0; i < RELATIVE_COUNT; i++) {
        [r addObject:@(p[i])];
    }
    return r;
}
// --------

+ (instancetype)Generate
{
    SudokuData sd = GenerateSudoku();
    return [OSudokuData SudokuFromData:&sd];
}

+ (instancetype)Cross:(OSudokuData*)sd
{
    return [sd Cross];
}

- (NSArray*)FindAllSolutions
{
    NSPointerArray* s = FindAllSolutions(&data);
    NSMutableArray* r = [NSMutableArray arrayWithCapacity:[s count]];
    for (int i = 0; i < [s count]; i++) {
        SudokuData * p = [s pointerAtIndex:i];
        [r addObject:[[OSudokuData new] initWithData:p]];
        free(p);
    }
    return r;
}

- (instancetype)Solve
{
    SudokuData sd = data;
    if (SolveSudoku(&sd))
        return [OSudokuData SudokuFromData:&sd];
    return nil;
}

- (instancetype)Cross
{
    SudokuData sd = data;
    if ( CrossSudoku(&sd, nil, nil) != ssCrossDone )
        return nil;
    return [OSudokuData SudokuFromData:&sd];
}

- (OSudokuStatus)CheckStatus
{
    return (OSudokuStatus)CheckSudokuStatus(&data, false);
}

- (OSudokuStatus)CheckStatusWithSolvable:(BOOL)checkSolvable
{
    return (OSudokuStatus)CheckSudokuStatus(&data, checkSolvable);
}

- (NSInteger)TileAtIndex:(NSInteger)index
{
    return data.tiles[index];
}

- (NSInteger)TileAtRow:(NSInteger)row andColumn:(NSInteger) col
{
    return data.rows[row][col];
}

- (void)setTileAtIndex:(NSInteger)index withValue:(NSInteger) v
{
    if (index < 0 || index >= 81)
        return;
    if (v < 0 || v > 9)
        return;
    
    if (v == 0 && data.tiles[index] != 0)
        ++emptyCount;
    if (v != 0 && data.tiles[index] == 0)
        --emptyCount;
    data.tiles[index] = v;
}

- (void)setTileAtRow:(NSInteger)row andColumn:(NSInteger) col withValue:(NSInteger) v
{
    [self setTileAtIndex:row*9+col withValue:v];
}

// ------

- (NSInteger) getEmptyCount
{
    return emptyCount;
}

- (NSInteger) getGivenCount
{
    return 81-emptyCount;
}

@end
