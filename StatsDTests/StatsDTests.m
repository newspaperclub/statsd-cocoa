//
//  StatsDTests.m
//  StatsDTests
//
//  Created by Tom Taylor on 24/07/2012.
//  Copyright (c) 2012 Newspaper Club. All rights reserved.
//

#import "StatsDTests.h"
#import <StatsD/StatsD.h>
#import <OCMock/OCMock.h>

@implementation StatsDTests

#pragma mark - Increment/decrement methods

- (void)testIncrement
{
    id mockClient = [OCMockObject partialMockForObject:[StatsD sharedClient]];
    
    NSData *expectedData = [@"statsd.test:1|c" dataUsingEncoding:NSASCIIStringEncoding];
    [[mockClient expect] fireToSocket:[OCMArg checkWithBlock:^BOOL(NSData *data) {
        return [expectedData isEqualToData:data];
    }]];
    
    [mockClient increment:@"statsd.test" sampleRate:1.0];
    
    [mockClient verify];
}

- (void)testDecrement
{
    id mockClient = [OCMockObject partialMockForObject:[StatsD sharedClient]];
    
    NSData *expectedData = [@"statsd.test:-1|c" dataUsingEncoding:NSASCIIStringEncoding];
    [[mockClient expect] fireToSocket:[OCMArg checkWithBlock:^BOOL(NSData *data) {
        return [expectedData isEqualToData:data];
    }]];
    
    [mockClient decrement:@"statsd.test" sampleRate:1.0];
    
    [mockClient verify];
}

#pragma mark - Gauge tests

- (void)testGauge
{
    id mockClient = [OCMockObject partialMockForObject:[StatsD sharedClient]];
    
    NSData *expectedData = [@"statsd.test:1|g" dataUsingEncoding:NSASCIIStringEncoding];
    [[mockClient expect] fireToSocket:[OCMArg checkWithBlock:^BOOL(NSData *data) {
        return [expectedData isEqualToData:data];
    }]];
    
    [mockClient gauge:@"statsd.test" value:1];
    
    [mockClient verify];
}

- (void)testMultiGauge
{
    id mockClient = [OCMockObject partialMockForObject:[StatsD sharedClient]];

    NSData *expectedData = [@"statsd.test:1|g\nstatsd.test:2|g" dataUsingEncoding:NSASCIIStringEncoding];
    [[mockClient expect] fireToSocket:[OCMArg checkWithBlock:^BOOL(NSData *data) {
        return [expectedData isEqualToData:data];
    }]];

    NSInteger values[] = {1,2};
    [mockClient gauge:@"statsd.test" values:values length:2];

    [mockClient verify];
}

#pragma mark - Count tests

- (void)testCount
{
    id mockClient = [OCMockObject partialMockForObject:[StatsD sharedClient]];

    NSData *expectedData = [@"statsd.test:2|c" dataUsingEncoding:NSASCIIStringEncoding];
    [[mockClient expect] fireToSocket:[OCMArg checkWithBlock:^BOOL(NSData *data) {
        return [expectedData isEqualToData:data];
    }]];

    [mockClient count:@"statsd.test" delta:2 sampleRate:1.0];

    [mockClient verify];
}

- (void)testMultiCount
{
    id mockClient = [OCMockObject partialMockForObject:[StatsD sharedClient]];

    NSData *expectedData = [@"statsd.test:1|c\nstatsd.test:2|c" dataUsingEncoding:NSASCIIStringEncoding];
    [[mockClient expect] fireToSocket:[OCMArg checkWithBlock:^BOOL(NSData *data) {
        return [expectedData isEqualToData:data];
    }]];

    NSInteger values[] = {1,2};
    [mockClient count:@"statsd.test" values:values length:2 sampleRate:1.0];

    [mockClient verify];
}

#pragma mark - Timing tests

- (void)testTiming
{
    id mockClient = [OCMockObject partialMockForObject:[StatsD sharedClient]];
    
    NSData *expectedData = [@"statsd.test:200|ms" dataUsingEncoding:NSASCIIStringEncoding];
    [[mockClient expect] fireToSocket:[OCMArg checkWithBlock:^BOOL(NSData *data) {
        return [expectedData isEqualToData:data];
    }]];
    
    [mockClient timing:@"statsd.test" ms:200];
    
    [mockClient verify];
}

- (void)testMultiTiming
{
    id mockClient = [OCMockObject partialMockForObject:[StatsD sharedClient]];

    NSData *expectedData = [@"statsd.test:10|ms\nstatsd.test:20|ms" dataUsingEncoding:NSASCIIStringEncoding];
    [[mockClient expect] fireToSocket:[OCMArg checkWithBlock:^BOOL(NSData *data) {
        return [expectedData isEqualToData:data];
    }]];

    NSInteger values[] = {10, 20};
    [mockClient timing:@"statsd.test" values:values length:2];

    [mockClient verify];
}

- (void)testTimingBlock
{
    id mockClient = [OCMockObject partialMockForObject:[StatsD sharedClient]];
    
    // This is really nasty. There's obviously a much better way to test this, but I can't be bothered now
    NSData *expectedData = [@"statsd.test:51|ms" dataUsingEncoding:NSASCIIStringEncoding];
    [[mockClient expect] fireToSocket:[OCMArg checkWithBlock:^BOOL(NSData *data) {
        return [expectedData isEqualToData:data];
    }]];
    
    NSUInteger ms = [mockClient timing:@"statsd.test" block:^{
        NSDate *future = [NSDate dateWithTimeIntervalSinceNow:0.05];
        [NSThread sleepUntilDate:future];
    }];
    
    [mockClient verify];
    XCTAssertEqual((NSUInteger)51, ms, @"response is 51ms");
}

//- (void)testLive
//{
//    [[StatsD sharedClient] setHost:@"127.0.0.1"];
//    [[StatsD sharedClient] setPort:8125];
//    [[StatsD sharedClient] increment:@"test.increment" sampleRate:1.0];
//    [[StatsD sharedClient] timing:@"test.timing" ms:200];
//    [[StatsD sharedClient] gauge:@"test.gauge" value:1];
//}

@end
