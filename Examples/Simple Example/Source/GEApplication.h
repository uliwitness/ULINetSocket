
//  GEApplication.h
//  GET Example

@class ULINetSocket;

@interface GEApplication : NSObject 
{
	ULINetSocket	*	mSocket;
}

- (void)connect;

@end
