
//  GSApplication.m
//  GhettoChat Server

#import "GSApplication.h"
#import "GSClient.h"
#import "GCProtocol.h"
#import "NetSocket.h"

static GSApplication* sApplication = nil;

@implementation GSApplication

- (id)init
{
	if( ![super init] )
		return nil;
	
	if( !sApplication )
		sApplication = self;
	
	// Initialize some values
	mServerSocket = nil;
	mClients = [[NSMutableArray alloc] initWithCapacity:20];
	
	return self;
}

- (void)dealloc
{
	if( sApplication == self )
		sApplication = nil;
	
	[super dealloc];
}

#pragma mark -

+ (GSApplication*)sharedApplication
{
	return sApplication;
}

#pragma mark -

- (void)serve
{
	mServerSocket = [[NetSocket netsocketListeningOnPort:kGSPort] retain];
	[mServerSocket scheduleOnCurrentRunLoop];
	[mServerSocket setDelegate:self];
	
	NSLog( @"GhettoChat Server: Waiting for connections..." );
}

- (void)broadcastPacket:(NetPacket*)inPacket
{
	[self broadcastPacket:inPacket excludingClients:nil];
}

- (void)broadcastPacket:(NetPacket*)inPacket excludingClient:(GSClient*)inClient
{
	[self broadcastPacket:inPacket excludingClients:[NSArray arrayWithObject:inClient]];
}

- (void)broadcastPacket:(NetPacket*)inPacket excludingClients:(NSArray*)inClientsToExclude
{
	NSEnumerator*	clientEnumerator;
	GSClient*		client;
	NSData*			packetData;
	
	// Flatten packet
	packetData = [NetPacket encodedPacket:inPacket compressed:NO];
	if( !packetData )
		return;
	
	// Enumerate clients and send packet
	clientEnumerator = [mClients objectEnumerator];
	while( client = [clientEnumerator nextObject] )
	{
		if( [inClientsToExclude containsObject:client] )
			continue;
		
		[[client netSocket] writeData:packetData];
	}
}

- (void)removeClient:(GSClient*)inClient
{
	[mClients removeObject:inClient];
}

#pragma mark -

- (void)netsocket:(NetSocket*)inNetSocket connectionAccepted:(NetSocket*)inNewNetSocket
{
	GSClient* client;
	
	NSLog( @"GhettoChat Server: New connection established" );
	
	client = [[[GSClient alloc] initWithNetSocket:inNewNetSocket] autorelease];
	[mClients addObject:client];
}

@end
