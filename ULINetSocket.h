//
//  ULINetSocket.h
//  Version 0.9
//
//  Copyright (c) Dustin Mierau.
//	With modifications by Uli Kusterer.
//
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
//

#import <Foundation/Foundation.h>
#import <netinet/in.h>

@interface ULINetSocket : NSObject 
{
	CFSocketRef				mCFSocketRef;
	CFRunLoopSourceRef		mCFSocketRunLoopSourceRef;
	id						mDelegate;
	NSTimer*				mConnectionTimer;
	BOOL					mSocketConnected;
	BOOL					mSocketListening;
	NSMutableData*			mOutgoingBuffer;
	NSMutableData*			mIncomingBuffer;
}

// Creation
+(ULINetSocket*)	netsocket;
+(ULINetSocket*)	netsocketListeningOnRandomPort;
+(ULINetSocket*)	netsocketListeningOnPort: (UInt16)inPort;
+(ULINetSocket*)	netsocketConnectedToHost: (NSString*)inHostname port: (UInt16)inPort;

// Delegate
-(id)		delegate;
-(void)		setDelegate: (id)inDelegate;

// Opening and Closing
-(BOOL)		open;
-(void)		close;

// Runloop Scheduling
-(BOOL)		scheduleOnCurrentRunLoop;
-(BOOL)		scheduleOnRunLoop: (NSRunLoop*)inRunLoop;

// Listening
-(BOOL)		listenOnRandomPort;
-(BOOL)		listenOnPort: (UInt16)inPort;
-(BOOL)		listenOnPort: (UInt16)inPort maxPendingConnections: (int)inMaxPendingConnections;

// Connecting
-(BOOL)		connectToHost: (NSString*)inHostname port: (UInt16)inPort;
-(BOOL)		connectToHost: (NSString*)inHostname port: (UInt16)inPort timeout: (NSTimeInterval)inTimeout;

// Peeking
-(NSData*)		peekData;

// Reading
-(unsigned)		read: (void*)inBuffer amount: (unsigned)inAmount;
-(unsigned)		readOntoData: (NSMutableData*)inData;
-(unsigned)		readOntoData: (NSMutableData*)inData amount: (unsigned)inAmount;
-(unsigned)		readOntoString: (NSMutableString*)inString encoding: (NSStringEncoding)inEncoding amount: (unsigned)inAmount;
-(NSData*)		readData;
-(NSData*)		readData: (unsigned)inAmount;
-(NSString*)	readString: (NSStringEncoding)inEncoding;
-(NSString*)	readString: (NSStringEncoding)inEncoding amount: (unsigned)inAmount;

// Writing
-(void)			write: (const void*)inBytes length: (unsigned)inLength;
-(void)			writeData: (NSData*)inData;
-(void)			writeString: (NSString*)inString encoding: (NSStringEncoding)inEncoding;

// Properties
-(NSString*)	remoteHost;
-(UInt16)		remotePort;
-(NSString*)	localHost;
-(UInt16)		localPort;
-(BOOL)			isConnected;
-(BOOL)			isListening;
-(unsigned)		incomingBufferLength;
-(unsigned)		outgoingBufferLength;

-(CFSocketNativeHandle)	nativeSocketHandle;
-(CFSocketRef)			cfsocketRef;

// Convenience methods
+(void)			ignoreBrokenPipes;
+(NSString*)	stringWithSocketAddress: (struct in_addr*)inAddress;

@end

#pragma mark -

@protocol ULINetSocketDelegate
@optional
-(void) netsocketConnected: (ULINetSocket*)inNetSocket;
-(void)	netsocket: (ULINetSocket*)inNetSocket connectionTimedOut: (NSTimeInterval)inTimeout;
-(void)	netsocketDisconnected: (ULINetSocket*)inNetSocket;
-(void)	netsocket: (ULINetSocket*)inNetSocket connectionAccepted: (ULINetSocket*)inNewNetSocket;
-(void)	netsocket: (ULINetSocket*)inNetSocket dataAvailable: (unsigned)inAmount;
-(void)	netsocketDataSent: (ULINetSocket*)inNetSocket;
@end
