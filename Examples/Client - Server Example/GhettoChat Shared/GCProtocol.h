
#import "NetPacket.h"



#pragma mark Ports

#define kGSPort											44100



#pragma mark -
#pragma mark Server Packet Types

#define GSPacketTypeNewClient							(NetPacketType)1
#define GSPacketTypeClientDisconnected				(NetPacketType)2
#define GSPacketTypeChat								(NetPacketType)3

#pragma mark Server Packet Keys

extern NetPacketKey GSPacketKeyNickname;			// NSString*
extern NetPacketKey GSPacketKeyChat;				// NSData*



#pragma mark -
#pragma mark Client Packet Types

#define GCPacketTypeLogin								(NetPacketType)1
#define GCPacketTypeChat								(NetPacketType)2

#pragma mark Client Packet Keys

extern NetPacketKey GCPacketKeyNickname;			// NSString*
extern NetPacketKey GCPacketKeyChat;				// NSData*





