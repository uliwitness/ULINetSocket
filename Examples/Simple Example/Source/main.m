
#import "GEApplication.h"
#import "NetSocket.h"

int
main( int inArgC, const char* inArgV[] )
{
	NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];
	GEApplication*			application = nil;
	
	// Use the NetSocket convenience method to ignore broken pipe signals
	[NetSocket ignoreBrokenPipes];
	
	NS_DURING
	{
		// Create our application object and connect
		application = [[[GEApplication alloc] init] autorelease];
		[application connect];
		
		// Run runloop
		[[NSRunLoop currentRunLoop] run];
		
		// Once the socket has disconnected, it will be removed from the runloop 
		// automagically. If it is the only source attached to our runloop, that too 
		// should automagically shutdown and we end up here!
		NSLog( @"GET Example: Finished" );
	}
	NS_HANDLER
		NSLog( @"GET Example::Unhandled exception, exiting..." );
	NS_ENDHANDLER
	
	[pool release];
	return 0;
}
