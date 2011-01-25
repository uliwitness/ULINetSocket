
//  NSData-Compression.m
//  NSData Compression
//  Created by Dustin Mierau

#import "NSData-Compression.h"
#import <zlib.h>

@implementation NSData (Compression)

- (NSData*)compressedData
{
	return [self compressedDataWithLevel:Z_DEFAULT_COMPRESSION];
}

- (NSData*)compressedDataWithLevel:(int)inLevel
{
	Bytef*	data = (Bytef*)[self bytes];
	uLongf	originalLength = [self length];
	uLongf	bufferLength = ( [self length] * 1.1 ) + 16;
	Bytef*	buffer;
	int		err;
	
	if( inLevel > NSDataCompressionBest )
		inLevel = NSDataCompressionBest;
	
	if( inLevel < Z_DEFAULT_COMPRESSION )
		inLevel = NSDataCompressionNone;
	
	buffer = (Bytef*)malloc( (uInt)bufferLength );
	err = compress2( buffer, &bufferLength, (const Bytef*)data, [self length], inLevel );
	if( err != Z_OK )
	{
		free( buffer );
		return nil;
	}
	
	bcopy( buffer, buffer + sizeof( uLongf ), bufferLength );
	bcopy( (void*)&originalLength, buffer, sizeof( uLongf ) );
	
	return [NSData dataWithBytesNoCopy:buffer length:bufferLength + sizeof( uLongf )];
}

- (NSData*)uncompressedData
{
	Bytef*	data = (Bytef*)[self bytes];
	uLongf	bufferLength;
	Bytef*	buffer;
	int		err;
	
	if( [self length] <= sizeof( uLongf ) )
		return nil;
	
	bcopy( data, &bufferLength, sizeof( uLongf ) );

	buffer = (Bytef*)malloc( (uInt)bufferLength );
	err = uncompress( buffer, &bufferLength, (const Bytef*)data + sizeof( uLongf ), [self length] - sizeof( uLongf ) );
	if( err != Z_OK )
	{
		free( buffer );
		return nil;
	}
	
	return [NSData dataWithBytesNoCopy:buffer length:bufferLength];
}

@end

@implementation NSMutableData (Compression)

- (BOOL)compress
{
	NSData* compressed = [self compressedData];
	if( compressed )
		[self setData:compressed];
	
	return ( compressed != nil );
}

- (BOOL)uncompress
{
	NSData* uncompressed = [self uncompressedData];
	if( uncompressed )
		[self setData:uncompressed];
	
	return ( uncompressed != nil );
}

@end