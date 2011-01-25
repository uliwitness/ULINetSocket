
//  GhettoChat Server
//  GSClient.h

@class ULINetSocket;
@class NetPacket;

@interface GSClient : NSObject 
{
	ULINetSocket	*	mSocket;
	NSString		*	mNickname;
}

- (id)initWithNetSocket:(ULINetSocket*)inNetSocket;

- (ULINetSocket*)netSocket;

- (void)processPacket:(NetPacket*)inPacket;
- (void)processLoginPacket:(NetPacket*)inPacket;
- (void)processChatPacket:(NetPacket*)inPacket;

@end
