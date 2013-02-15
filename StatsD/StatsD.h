//
//  StatsD.h
//  StatsD
//
//  Created by Tom Taylor on 24/07/2012.
//  Copyright (c) 2012 Newspaper Club. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDAsyncUdpSocket;

@interface StatsD : NSObject {
  NSString *host;
  unsigned short port;
  NSString *namespace;
  GCDAsyncUdpSocket *socket;
  NSRegularExpression *reservedCharsRegexp;
}

@property (strong) NSString *namespace;
@property (strong) NSString *host;
@property unsigned short port;

+ (StatsD *)sharedClient;

- (id)initWithHost:(NSString *)_host port:(unsigned short)_port;
- (void)fireToSocket:(NSData *)data;

- (void)increment:(NSString *)stat sampleRate:(float)sampleRate;
- (void)decrement:(NSString *)stat sampleRate:(float)sampleRate;
- (void)count:(NSString *)stat delta:(NSInteger)delta sampleRate:(float)sampleRate;
- (void)gauge:(NSString *)stat value:(NSInteger)value;
- (void)timing:(NSString *)stat ms:(NSInteger)ms;
- (NSUInteger)timing:(NSString *)stat block:(void (^)(void))block;

@end
