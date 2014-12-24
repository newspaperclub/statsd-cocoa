//
//  StatsD.m
//  StatsD
//
//  Created by Tom Taylor on 24/07/2012.
//  Copyright (c) 2012 Newspaper Club. All rights reserved.
//

#import "StatsD.h"
#import "GCDAsyncUdpSocket.h"

@interface StatsD (Private)

- (void)send:(NSString *)stat
       value:(NSInteger)value
        type:(NSString *)type
  sampleRate:(float)sampleRate;

- (void)send:(NSString *)stat
      values:(NSInteger[])values
      length:(NSInteger)length
        type:(NSString *)type
  sampleRate:(float)sampleRate;

@end

@implementation StatsD

@synthesize namespace, host, port;

+ (StatsD *)sharedClient {
    static dispatch_once_t pred;
    static StatsD *sharedClient = nil;
    
    dispatch_once(&pred, ^{
        sharedClient = [[StatsD alloc] init];
    });
    return sharedClient;
}

- (id)init
{
    self = [super init];
    if (self) {
        socket = [[GCDAsyncUdpSocket alloc] init];
        reservedCharsRegexp = [NSRegularExpression regularExpressionWithPattern:@"[:|@]" options:0 error:nil];
    }
    return self;
}

- (id)initWithHost:(NSString *)_host port:(unsigned short)_port
{
    self = [self init];
    if (self) {
        host = _host;
        port = _port;
    }
    return self;
}

#pragma mark - Increment/decrement methods

- (void)increment:(NSString *)stat sampleRate:(float)sampleRate {
    [self count:stat delta:1 sampleRate:sampleRate];
}

- (void)decrement:(NSString *)stat sampleRate:(float)sampleRate {
    [self count:stat delta:-1 sampleRate:sampleRate];
}

#pragma mark - Count methods

- (void)count:(NSString *)stat delta:(NSInteger)delta sampleRate:(float)sampleRate {
    [self send:stat value:delta type:@"c" sampleRate:sampleRate];
}

- (void)count:(NSString *)stat values:(NSInteger[])values length:(NSInteger)length sampleRate:(float)sampleRate {
    [self send:stat values:values length:length type:@"c" sampleRate:sampleRate];
}

#pragma mark - Gauge methods

- (void)gauge:(NSString *)stat value:(NSInteger)value {
    [self send:stat value:value type:@"g" sampleRate:1.0];
}

- (void)gauge:(NSString *)stat values:(NSInteger[])values length:(NSInteger)length {
    [self send:stat values:values length:length type:@"g" sampleRate:1.0];
}

#pragma mark - Timing methods

- (void)timing:(NSString *)stat ms:(NSInteger)ms {
    [self send:stat value:ms type:@"ms" sampleRate:1.0];
}

- (void)timing:(NSString *)stat values:(NSInteger[])values length:(NSInteger)length {
    [self send:stat values:values length:length type:@"ms" sampleRate:1.0];
}

- (NSUInteger)timing:(NSString *)stat block:(void (^)(void))block {
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    block();
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - start;
    NSInteger ms = round(duration * 1000);
    [self timing:stat ms:ms];
    return ms;
}

#pragma mark - Send methods

- (void)send:(NSString *)stat
       value:(NSInteger)value
        type:(NSString *)type
  sampleRate:(float)sampleRate
{
    NSInteger values[] = {value};
    [self send:stat values:values length:1 type:type sampleRate:sampleRate];
}

- (void)send:(NSString *)stat
      values:(NSInteger[])values
      length:(NSInteger)length
        type:(NSString *)type
  sampleRate:(float)sampleRate
{
    // Sample, and return early if this packet isn't selected
    if (sampleRate < 1 && rand() > sampleRate) {
        return;
    }
    
    NSMutableData *buffer = [[NSMutableData alloc] init];
    
    for (int i = 0; i < length; i++) {
        if (i != 0) {
            [buffer appendBytes:"\n" length:1];
        }

        NSInteger value = values[i];

        NSMutableString *sentStat = [NSMutableString string];
        if (namespace && namespace.length > 0) {
            NSString *prefix = [NSString stringWithFormat:@"%@.", namespace];
            [sentStat appendString:prefix];
        }

        [sentStat appendString:stat];

        // Clean up the stat (including the namespace) to filter unwanted characters
        NSRange range = NSMakeRange(0, sentStat.length);
        [reservedCharsRegexp replaceMatchesInString:sentStat options:0 range:range withTemplate:@"_"];
        [buffer appendData:[sentStat dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];

        [buffer appendBytes:":" length:1];
        [buffer appendData:[[NSString stringWithFormat:@"%ld", value] dataUsingEncoding:NSASCIIStringEncoding]];
        [buffer appendBytes:"|" length:1];
        [buffer appendData:[type dataUsingEncoding:NSASCIIStringEncoding]];

        // If we're sampling below 1, add the sample rate
        if (sampleRate < 1) {
            [buffer appendBytes:"|@" length:2];
            [buffer appendData:[[NSString stringWithFormat:@"%f", sampleRate] dataUsingEncoding:NSASCIIStringEncoding]];
        }
    }

    [self fireToSocket:buffer];
}

- (void)fireToSocket:(NSData *)data {
    [socket sendData:data toHost:self.host port:self.port withTimeout:-1 tag:0];
}

@end