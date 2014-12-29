//
//  SudokuTests.m
//  SudokuTests
//
//  Created by Chen Xi on 14/12/26.
//  Copyright (c) 2014年 Chen Xi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "libSudoku_test.h"

@interface SudokuTests : XCTestCase

@end

@implementation SudokuTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    //dbgTestSolve();
    dbgTestCrossing();
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
