
//  GhettoChat Server
//  main.m

#import "GSApplication.h"
#import "NetSocket.h"

int
main( int inArgC, const char* inArgV[] )
{
	NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];
	GSApplication*			application = nil;
	
	// Use the NetSocket convenience method to ignore broken pipe signals
	[NetSocket ignoreBrokenPipes];
	
	NS_DURING
	{
		application = [[[GSApplication alloc] init] autorelease];
		[application serve];
		
		// Run runloop
		[[NSRunLoop currentRunLoop] run];
	}
	NS_HANDLER
		NSLog( @"GhettoChat Server::Unhandled exception, exiting..." );
	NS_ENDHANDLER
	
	[pool release];
	return 0;
}
