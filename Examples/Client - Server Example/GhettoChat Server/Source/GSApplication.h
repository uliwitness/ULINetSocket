
//  GSApplication.h
//  GhettoChat Server

@class NetSocket;
@class NetPacket;
@class GSClient;

@interface GSApplication : NSObject 
{
	NetSocket*			mServerSocket;
	NSMutableArray*	mClients;
}

+ (GSApplication*)sharedApplication;

- (void)serve;
- (void)broadcastPacket:(NetPacket*)inPacket;
- (void)broadcastPacket:(NetPacket*)inPacket excludingClient:(GSClient*)inClient;
- (void)broadcastPacket:(NetPacket*)inPacket excludingClients:(NSArray*)inClientsToExclude;
- (void)removeClient:(GSClient*)inClient;

@end
