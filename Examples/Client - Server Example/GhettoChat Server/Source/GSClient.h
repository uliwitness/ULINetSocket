
//  GhettoChat Server
//  GSClient.h

@class NetSocket;
@class NetPacket;

@interface GSClient : NSObject 
{
	NetSocket*	mSocket;
	NSString*	mNickname;
}

- (id)initWithNetSocket:(NetSocket*)inNetSocket;

- (NetSocket*)netSocket;

- (void)processPacket:(NetPacket*)inPacket;
- (void)processLoginPacket:(NetPacket*)inPacket;
- (void)processChatPacket:(NetPacket*)inPacket;

@end
