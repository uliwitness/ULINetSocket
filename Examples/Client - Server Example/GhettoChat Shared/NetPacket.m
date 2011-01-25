
//  NetPacket
//  NetPacket.m
//  Version 0.1
//  Created by Dustin Mierau

#import "NetPacket.h"
#import "NSData-Compression.h"

@implementation NetPacket

- (id)init
{
	if( !( self = [super init] ) )
		return nil;
	
	mType = 0;
	mDictionary = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (id)initWithCoder:(NSCoder*)inDecoder
{
	if( !( self = [super init] ) )
		return nil;
	
	[inDecoder decodeValueOfObjCType:@encode( NetPacketType ) at:&mType];
	mDictionary = [[inDecoder decodeObject] retain];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)inEncoder
{
	[inEncoder encodeValueOfObjCType:@encode( NetPacketType ) at:&mType];
	[inEncoder encodeObject:mDictionary];
}

- (void)dealloc
{
	[mDictionary release];
	[super dealloc];
}

#pragma mark -

+ (NetPacket*)packet
{
	return [[[NetPacket alloc] init] autorelease];
}

+ (NetPacket*)packetWithType:(NetPacketType)inType
{
	NetPacket* packet;
	
	packet = [NetPacket packet];
	[packet setType:inType];
	
	return packet;
}

#pragma mark -

+ (NSData*)encodedPacket:(NetPacket*)inPacket compressed:(BOOL)inCompressedFlag
{
	NetPacketSize			size;
	NSMutableData*			packetData;
	NSData*					encodedPacket;
	BOOL						compressed = inCompressedFlag;
	
	// Encode
	encodedPacket = [NSArchiver archivedDataWithRootObject:inPacket];
	if( !encodedPacket )
		return nil;
	
	// Compress
	if( compressed )
		encodedPacket = [encodedPacket compressedDataWithLevel:NSDataCompressionBest];
	
	// Size
	size = [encodedPacket length];
	if( size == 0 )
		return nil;
	
	// Bundle
	packetData = [[[NSMutableData alloc] init] autorelease];
	[packetData appendBytes:&size length:sizeof( NetPacketSize )];
	[packetData appendBytes:&compressed length:sizeof( BOOL )];
	[packetData appendData:encodedPacket];
	
	return packetData;
}

+ (NetPacket*)decodedPacket:(NSData*)inData
{
	NetPacketSize	packetSize;
	NSData*			packetData;
	BOOL				compressed;

	// Check
	if( ![NetPacket packetAvailable:inData] )
		return nil;
	
	// Properties
	[inData getBytes:&packetSize range:NSMakeRange( 0, sizeof( NetPacketSize ) )];
	[inData getBytes:&compressed range:NSMakeRange( sizeof( NetPacketSize ), sizeof( BOOL ) )];
	if( packetSize > ( [inData length] - [NetPacket packetHeaderSize] ) )
		return nil;

	// Data
	packetData = [inData subdataWithRange:NSMakeRange( [NetPacket packetHeaderSize], packetSize )];
	if( !packetData )
		return nil;
	
	// Uncompress
	if( compressed )
		packetData = [packetData uncompressedData];

	return [NSUnarchiver unarchiveObjectWithData:packetData];
}

#pragma mark -

+ (int)packetHeaderSize
{
	return ( sizeof( NetPacketSize ) + sizeof( BOOL ) );
}

+ (NetPacketSize)packetSize:(NSData*)inData
{
	NetPacketSize packetSize;
	
	if( ![self packetProperties:inData size:&packetSize compressed:NULL] )
		packetSize = 0;
	
	return packetSize;
}

+ (BOOL)packetCompressed:(NSData*)inData
{
	BOOL packetCompressed;
	
	if( ![self packetProperties:inData size:NULL compressed:&packetCompressed] )
		packetCompressed = NO;
	
	return packetCompressed;
}

+ (BOOL)packetAvailable:(NSData*)inData
{
	return [NetPacket packetProperties:inData size:NULL compressed:NULL];
}

+ (BOOL)packetProperties:(NSData*)inData size:(NetPacketSize*)outSize compressed:(BOOL*)outCompressed
{
	NetPacketSize packetSize = 0;

	if( [inData length] < [NetPacket packetHeaderSize] )
		return NO;
	
	[inData getBytes:&packetSize range:NSMakeRange( 0, sizeof( NetPacketSize ) )];
	
	if( outSize )
		*outSize = packetSize;

	if( outCompressed )
		[inData getBytes:outCompressed range:NSMakeRange( sizeof( NetPacketSize ), sizeof( BOOL ) )];
		
	return ( [inData length] >= ( [NetPacket packetHeaderSize] + packetSize ) );
}

#pragma mark -

- (NetPacketType)type
{
	return mType;
}

- (void)setType:(NetPacketType)inType
{
	mType = inType;
}

- (id)objectForKey:(NetPacketKey)inKey
{
	return [mDictionary objectForKey:(NSString*)inKey];
}

- (void)setObject:(id)inObject forKey:(NetPacketKey)inKey
{
	[mDictionary setObject:inObject forKey:(NSString*)inKey];
}

#pragma mark -

- (NSString*)description
{
	return [NSString stringWithFormat:@"%u %@", mType, mDictionary, nil];
}

@end

@implementation NSMutableData (NetPacket)

- (NetPacket*)readPacket
{
	NetPacketSize	packetSize = [NetPacket packetSize:self];
	NetPacket*		packet = nil;
	
	if( packetSize <= 0 )
		return nil;
	
	packet = [NetPacket decodedPacket:self];
	
	if( packet )
		[self setData:[self subdataWithRange:NSMakeRange( [NetPacket packetHeaderSize] + packetSize, [self length] - ( [NetPacket packetHeaderSize] + packetSize ) )]];
	
	return packet;
}

- (void)appendPacket:(NetPacket*)inPacket
{
	
}

@end