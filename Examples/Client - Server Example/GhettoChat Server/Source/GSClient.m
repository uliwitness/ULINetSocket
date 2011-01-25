
//  GhettoChat Server
//  GSClient.m

#import "GSClient.h"
#import "GSApplication.h"
#import "GCProtocol.h"
#import "NetSocket.h"

@implementation GSClient

- (id)initWithNetSocket:(NetSocket*)inNetSocket
{
	if( ![super init] )
		return nil;
	
	mNickname = nil;
	mSocket = [inNetSocket retain];
	
	// Setup socket for use
	[mSocket open];
	[mSocket scheduleOnCurrentRunLoop];
	[mSocket setDelegate:self];
	
	return self;
}

- (void)dealloc
{
	NSLog( @"GhettoChat Server: Client released" );
	[mSocket release];
	[mNickname release];
	[super dealloc];
}

#pragma mark -

- (NetSocket*)netSocket
{
	return mSocket;
}

#pragma mark -

- (void)processPacket:(NetPacket*)inPacket
{
	switch( [inPacket type] )
	{
		case GCPacketTypeLogin:
			[self processLoginPacket:inPacket];
			break;
		
		case GCPacketTypeChat:
			[self processChatPacket:inPacket];
			break;
	}
}

- (void)processLoginPacket:(NetPacket*)inPacket
{
	NetPacket*	packet;
	
	// Read nickname from packet
	mNickname = [[inPacket objectForKey:GCPacketKeyNickname] retain];
	
	NSLog( @"GhettoChat Server: Login packet received from %@", mNickname );
	
	// Create new client packet
	packet = [NetPacket packetWithType:GSPacketTypeNewClient];
	
	// Add packet objects
	[packet setObject:mNickname forKey:GSPacketKeyNickname];
	
	// Broadcast packet
	[[GSApplication sharedApplication] broadcastPacket:packet excludingClient:self];
}

- (void)processChatPacket:(NetPacket*)inPacket
{
	NetPacket*	packet;
	NSData*		chat;
	
	NSLog( @"GhettoChat Server: Chat packet received from %@", mNickname );
	
	// Read chat from packet
	chat = [inPacket objectForKey:GCPacketKeyChat];
	
	// Create chat packet
	packet = [NetPacket packetWithType:GSPacketTypeChat];
	
	// Add packet objects
	[packet setObject:mNickname forKey:GSPacketKeyNickname];
	[packet setObject:chat forKey:GSPacketKeyChat];
	
	// Broadcast packet
	[[GSApplication sharedApplication] broadcastPacket:packet];
}

#pragma mark -

- (void)netsocketDisconnected:(NetSocket*)inNetSocket
{
	NetPacket*	packet;
	
	NSLog( @"GhettoChat Server: Client disconnected" );
	
	// Create client disconnected packet
	packet = [NetPacket packetWithType:GSPacketTypeClientDisconnected];
	
	// Add packet object
	[packet setObject:mNickname forKey:GSPacketKeyNickname];
	
	// Broadcast packet
	[[GSApplication sharedApplication] broadcastPacket:packet excludingClient:self];
	
	// Remove ourselves from the client list
	[[GSApplication sharedApplication] removeClient:self];
}

- (void)netsocket:(NetSocket*)inNetSocket dataAvailable:(unsigned)inAmount
{
	NetPacket*		packet;
	NSData*			packetData;
	NetPacketSize	packetSize;
	
	while( [NetPacket packetAvailable:[inNetSocket peekData]] )
	{
		packetSize = [NetPacket packetHeaderSize] + [NetPacket packetSize:[inNetSocket peekData]];
		packetData = [inNetSocket readData:packetSize];
		if( !packetData )
			break;
		
		packet = [NetPacket decodedPacket:packetData];
		if( packet )
			[self processPacket:packet];
	}
}

- (void)netsocketDataSent:(NetSocket*)inNetSocket
{
	
}

@end
