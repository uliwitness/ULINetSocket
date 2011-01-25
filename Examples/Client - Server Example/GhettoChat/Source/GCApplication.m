
//  GhettoChat
//  GCApplication.m

#import "GCApplication.h"
#import "GCChat.h"
#import "ULINetSocket.h"

@implementation GCApplication

- (void)awakeFromNib
{
	[self newChat:nil];
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark -

- (void)applicationWillFinishLaunching:(NSNotification*)inNotification
{
	
}

- (void)applicationDidFinishLaunching:(NSNotification*)inNotification
{
	
}

- (void)applicationWillTerminate:(NSNotification*)inNotification
{
	[NSApp setDelegate:nil];
	[self release];
}

#pragma mark -

- (IBAction)newChat:(id)inSender
{
	[[GCChat alloc] init];
}

@end

#pragma mark -

int
main( int inArgC, const char* inArgV[] )
{
	[ULINetSocket ignoreBrokenPipes];
	
	return NSApplicationMain( inArgC, inArgV );
}
