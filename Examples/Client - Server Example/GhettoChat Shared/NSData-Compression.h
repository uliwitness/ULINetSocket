
//  NSData-Compression.h
//  NSData Compression
//  Created by Dustin Mierau

#import <Foundation/Foundation.h>

#define NSDataCompressionNone	0
#define NSDataCompressionLow	1
#define NSDataCompressionBest	9

@interface NSData (Compression) 
- (NSData*)compressedData;
- (NSData*)compressedDataWithLevel:(int)inLevel;
- (NSData*)uncompressedData;
@end

@interface NSMutableData (Compression)
- (BOOL)compress;
- (BOOL)uncompress;
@end
