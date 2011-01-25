
//  GEApplication.h
//  GET Example

@class NetSocket;

@interface GEApplication : NSObject 
{
	NetSocket*	mSocket;
}

- (void)connect;

@end
