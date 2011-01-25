
//  GhettoChat
//  GCChat.m

#import "GCChat.h"
#import "GCProtocol.h"
#import "NetSocket.h"

@implementation GCChat

- (id)init
{
	if( ![super init] )
		return nil;
	
	[NSBundle loadNibNamed:@"Chat" owner:self];
	
	return self;
}

- (void)awakeFromNib
{
	// Initialize some values
	mSocket = nil;
	mNickname = nil;
	
	// Center chat window on screen
	{
		NSScreen*	mainScreen;
		NSRect		mainScreenFrame;
		NSPoint		windowPoint;
		
		// Determine screen and screen frame
		mainScreen = [NSScreen mainScreen];
		mainScreenFrame = [mainScreen visibleFrame];
		
		// Calculate window position in center of screen
		windowPoint.x = ceil( mainScreenFrame.size.width / 2.0 ) - ceil( [mWindow frame].size.width / 2.0 );
		windowPoint.y = ceil( mainScreenFrame.size.height / 2.0 ) - ceil( [mWindow frame].size.height / 2.0 );
		windowPoint.x += mainScreenFrame.origin.x;
		windowPoint.y += mainScreenFrame.origin.y;
		
		// Position window
		[mWindow setFrameOrigin:windowPoint];
		
		// Show window
		[mWindow makeKeyAndOrderFront:nil];
	}
	
	// Show connection sheet
	[self connect:nil];
}

- (void)dealloc
{
	[mWindow release];
	[mConnectPanel release];
	
	[mSocket release];
	[mNickname release];

	[super dealloc];
}

#pragma mark -

- (IBAction)disconnect:(id)inSender
{
	[mSocket release];
	mSocket = nil;
}

- (IBAction)connect:(id)inSender
{
	[NSApp beginSheet:mConnectPanel modalForWindow:mWindow modalDelegate:nil didEndSelector:nil contextInfo:NULL];
	[mConnectPanel makeFirstResponder:mAddressField];
}

- (IBAction)connectConnect:(id)inSender
{
	if( [[mAddressField stringValue] length] == 0 )
	{
		[mConnectPanel makeFirstResponder:mAddressField];
		return;
	}
	else
	if( [[mNicknameField stringValue] length] == 0 )
	{
		[mConnectPanel makeFirstResponder:mNicknameField];
		return;
	}
	
	// Hide connection sheet
	[NSApp endSheet:mConnectPanel];
	[mConnectPanel orderOut:nil];
	
	// Process nickname
	[mNickname release];
	mNickname = [[NSString alloc] initWithString:[mNicknameField stringValue]];
	
	// Connect to address
	[self connectToAddress:[mAddressField stringValue]];
}

- (IBAction)connectCancel:(id)inSender
{
	[NSApp endSheet:mConnectPanel];
	[mConnectPanel orderOut:nil];
}

#pragma mark -

- (void)connectToAddress:(NSString*)inAddress
{
	NSMutableString*	mutableAddress;
	NSArray*				addressPieces;
	NSString*			host;
	UInt16				port;
	
	// Process address string
	mutableAddress = [[inAddress mutableCopy] autorelease];
	[mutableAddress replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange( 0, [mutableAddress length] )];
	[mutableAddress replaceOccurrencesOfString:@"\t" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange( 0, [mutableAddress length] )];
	[mutableAddress replaceOccurrencesOfString:@"\r" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange( 0, [mutableAddress length] )];
	[mutableAddress replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange( 0, [mutableAddress length] )];
	
	// Rip host and port from address
	addressPieces = [mutableAddress componentsSeparatedByString:@":"];
	host = [addressPieces objectAtIndex:0];
	port = ( [addressPieces count] == 2 ) ? [[addressPieces objectAtIndex:1] intValue] : kGSPort;
	
	NSLog( @"GhettoChat: Connecting to %@ on port %u", host, port );
	
	// Release current socket if necessary
	[self disconnect:nil];
	
	// Create new NetSocket connected to the specified host and port
	mSocket = [[NetSocket netsocketConnectedToHost:host port:port] retain];
	[mSocket scheduleOnCurrentRunLoop];
	[mSocket setDelegate:self];
}

- (void)loginWithNickname:(NSString*)inNickname
{
	NetPacket*	packet;
	NSData*		packetData;
	
	// Create new packet
	packet = [NetPacket packetWithType:GCPacketTypeLogin];
	if( !packet )
		return;
	
	// Set packet values
	[packet setObject:inNickname forKey:GCPacketKeyNickname];
	
	// Flatten packet
	packetData = [NetPacket encodedPacket:packet compressed:NO];
	if( !packetData )
		return;
		
	// Send packet
	[mSocket writeData:packetData];
}

- (void)sendChat:(NSAttributedString*)inChat
{
	NetPacket*	packet;
	NSData*		packetData;
	NSData*		rtfData;
	
	// Get chat in RTF form
	rtfData = [inChat RTFDFromRange:NSMakeRange( 0, [inChat length] ) documentAttributes:nil];
	
	// Create new packet
	packet = [NetPacket packetWithType:GCPacketTypeChat];
	if( !packet )
		return;
	
	// Set packet values
	[packet setObject:rtfData forKey:GCPacketKeyChat];
	
	// Flatten packet
	packetData = [NetPacket encodedPacket:packet compressed:NO];
	if( !packetData )
		return;
	
	// Send packet
	[mSocket writeData:packetData];
}

#pragma mark -

- (void)processPacket:(NetPacket*)inPacket
{
	switch( [inPacket type] )
	{
		case GSPacketTypeNewClient:
			[self processNewClientPacket:inPacket];
			break;
		
		case GSPacketTypeClientDisconnected:
			[self processClientDisconnectedPacket:inPacket];
			break;
		
		case GSPacketTypeChat:
			[self processChatPacket:inPacket];
			break;
	}
}

- (void)processNewClientPacket:(NetPacket*)inPacket
{
	NSString*						nickname;
	NSMutableAttributedString*	chatString;
	
	NSLog( @"GhettoChat: New client packet" );
	
	// Read objects from packet
	nickname = [inPacket objectForKey:GSPacketKeyNickname];
	
	// Format chat string
	chatString = [[[NSMutableAttributedString alloc] init] autorelease];
	[chatString appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ in da hizzoowwssss!", nickname] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:13.0], NSFontAttributeName, [NSColor grayColor], NSForegroundColorAttributeName, nil]] autorelease]];
	
	if( [[mChatTextView textStorage] length] > 0 )
		[[mChatTextView textStorage] appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n"] autorelease]];
	
	[[mChatTextView textStorage] appendAttributedString:chatString];
	[mChatTextView setSelectedRange:NSMakeRange( [[mChatTextView textStorage] length], 0 )];
	[mChatTextView scrollRangeToVisible:NSMakeRange( [[mChatTextView textStorage] length], 0 )];
}

- (void)processClientDisconnectedPacket:(NetPacket*)inPacket
{
	NSString*						nickname;
	NSMutableAttributedString*	chatString;
	
	NSLog( @"GhettoChat: Client disconnected packet" );
	
	// Read objects from packet
	nickname = [inPacket objectForKey:GSPacketKeyNickname];
	
	// Format chat string
	chatString = [[[NSMutableAttributedString alloc] init] autorelease];
	[chatString appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ left", nickname] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:13.0], NSFontAttributeName, [NSColor grayColor], NSForegroundColorAttributeName, nil]] autorelease]];
	
	if( [[mChatTextView textStorage] length] > 0 )
		[[mChatTextView textStorage] appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n"] autorelease]];
	
	[[mChatTextView textStorage] appendAttributedString:chatString];
	[mChatTextView setSelectedRange:NSMakeRange( [[mChatTextView textStorage] length], 0 )];
	[mChatTextView scrollRangeToVisible:NSMakeRange( [[mChatTextView textStorage] length], 0 )];
}

- (void)processChatPacket:(NetPacket*)inPacket
{
	NSString*						nickname;
	NSData*							chat;
	NSMutableAttributedString*	chatString;
	
	NSLog( @"GhettoChat: Chat packet" );
	
	// Read objects from packet
	nickname = [inPacket objectForKey:GSPacketKeyNickname];
	chat = [inPacket objectForKey:GSPacketKeyChat];
	
	// Format chat string
	chatString = [[[NSMutableAttributedString alloc] init] autorelease];
	[chatString appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", nickname] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:13.0], NSFontAttributeName, [NSColor grayColor], NSForegroundColorAttributeName, nil]] autorelease]];
	[chatString appendAttributedString:[[[NSAttributedString alloc] initWithRTFD:chat documentAttributes:NULL] autorelease]];
	
	if( [[mChatTextView textStorage] length] > 0 )
		[[mChatTextView textStorage] appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n"] autorelease]];
	
	[[mChatTextView textStorage] appendAttributedString:chatString];
	[mChatTextView setSelectedRange:NSMakeRange( [[mChatTextView textStorage] length], 0 )];
	[mChatTextView scrollRangeToVisible:NSMakeRange( [[mChatTextView textStorage] length], 0 )];
}

#pragma mark -

- (void)netsocketConnected:(NetSocket*)inNetSocket
{
	NSLog( @"GhettoChat: Connected" );
	
	[self loginWithNickname:mNickname];
}

- (void)netsocket:(NetSocket*)inNetSocket connectionTimedOut:(NSTimeInterval)inTimeout
{
	NSLog( @"GhettoChat: Connection timed out" );
}

- (void)netsocketDisconnected:(NetSocket*)inNetSocket
{
	NSLog( @"GhettoChat: Disconnected" );
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

#pragma mark -

- (BOOL)textView:(NSTextView*)inTextView doCommandBySelector:(SEL)inSelector
{
	if( inSelector == @selector( insertNewline: ) )
	{
		if( [[mInputTextView string] length] <= 0 )
			return YES;
		
		[self sendChat:[mInputTextView textStorage]];
		[mInputTextView setString:@""];
		
		return YES;
	}
	
	return NO;
}

- (BOOL)validateMenuItem:(id<NSMenuItem>)inMenuItem
{
	BOOL enable = YES;
	
	if( [inMenuItem action] == @selector( connect: ) )
	{
		if( [mSocket isConnected] )
			enable = NO;
	}
	else
	if( [inMenuItem action] == @selector( disconnect: ) )
	{
		if( ![mSocket isConnected] )
			enable = NO;
	}
	
	return enable;
}

- (void)windowWillClose:(NSNotification*)inNotification
{
	[self autorelease];
}

@end
