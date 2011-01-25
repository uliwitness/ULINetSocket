
//  NetPacket
//  NetPacket.h
//  Version 0.1
//  Created by Dustin Mierau

//  You have found the bonus NetSocket sidekick class.
//  This class is under the same license as NetSocket.
//  Since this class serializes objects, network protocols written using this class 
//  will only work if the framework used on the other end can deserialize the objects
//  into memory. Use at your own risk.

typedef unsigned long	NetPacketSize;
typedef unsigned long	NetPacketType;
typedef const NSString*	NetPacketKey;

@interface NetPacket : NSObject <NSCoding>
{
	NetPacketType			mType;
	NSMutableDictionary*	mDictionary;
}

+ (NetPacket*)packet;
+ (NetPacket*)packetWithType:(NetPacketType)inType;

+ (NSData*)encodedPacket:(NetPacket*)inPacket compressed:(BOOL)inCompressedFlag;
+ (NetPacket*)decodedPacket:(NSData*)inData;

+ (int)packetHeaderSize;
+ (NetPacketSize)packetSize:(NSData*)inData;
+ (BOOL)packetCompressed:(NSData*)inData;
+ (BOOL)packetAvailable:(NSData*)inData;
+ (BOOL)packetProperties:(NSData*)inData size:(NetPacketSize*)outSize compressed:(BOOL*)outCompressed;

- (NetPacketType)type;
- (void)setType:(NetPacketType)inType;
- (id)objectForKey:(NetPacketKey)inKey;
- (void)setObject:(id)inObject forKey:(NetPacketKey)inKey;

@end

@interface NSMutableData (NetPacket)
- (NetPacket*)readPacket;
- (void)appendPacket:(NetPacket*)inPacket;
@end
