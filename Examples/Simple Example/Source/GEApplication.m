
//  GEApplication.m
//  GET Example

#import "GEApplication.h"
#import "NetSocket.h"

@implementation GEApplication

- (id)init
{
	if( ![super init] )
		return nil;
	
	mSocket = nil;
	
	return self;
}

- (void)dealloc
{
	[mSocket release];
	mSocket = nil;
	
	[super dealloc];
}

#pragma mark -

- (void)connect
{
	// Create a new NetSocket connected to the host. Since NetSocket is asynchronous, the socket is not 
	// connected to the host until the delegate method is called.
	mSocket = [[NetSocket netsocketConnectedToHost:@"www.apple.com" port:80] retain];
	
	// Schedule the NetSocket on the current runloop
	[mSocket scheduleOnCurrentRunLoop];
	
	// Set the NetSocket's delegate to ourself
	[mSocket setDelegate:self];
}

#pragma mark -

- (void)netsocketConnected:(NetSocket*)inNetSocket
{
	NSLog( @"GET Example: Connected" );
	NSLog( @"GET Example: Sending HTTP header..." );
	
	// Send a simple HTTP 1.0 header to the server and hopefully we won't be rejected
	[mSocket writeString:@"GET / HTTP/1.0\r\n\r\n" encoding:NSUTF8StringEncoding];
}

- (void)netsocketDisconnected:(NetSocket*)inNetSocket
{
	NSString*	path;
	NSString*	data;
	
	NSLog( @"GET Example: Disconnected" );
	
	// Determine path for writing page to disk
	path = [@"~/Desktop/GET Example Download.html" stringByExpandingTildeInPath];
	
	// Read downloaded page from socket. Since NetSocket buffers available data for you
	// you can wait for your socket to disconnect and then read the data at once
	data = [mSocket readString:NSUTF8StringEncoding];
	
	// Write downloaded page to disk
	[data writeToFile:path atomically:YES];
	
	NSLog( @"GET Example: Saved downloaded page to %@", path );
}

- (void)netsocket:(NetSocket*)inNetSocket dataAvailable:(unsigned)inAmount
{
	NSLog( @"GET Example: Data available (%u)", inAmount );
}

- (void)netsocketDataSent:(NetSocket*)inNetSocket
{
	NSLog( @"GET Example: Data sent" );
}

@end
