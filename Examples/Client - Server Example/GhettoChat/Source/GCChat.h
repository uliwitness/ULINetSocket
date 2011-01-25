
//  GhettoChat
//  GCChat.h

@class ULINetSocket;
@class NetPacket;

@interface GCChat : NSObject 
{
	IBOutlet NSWindow		*	mWindow;
	IBOutlet NSPanel		*	mConnectPanel;
	IBOutlet NSTextView		*	mChatTextView;
	IBOutlet NSTextView		*	mInputTextView;
	IBOutlet NSTextField	*	mAddressField;
	IBOutlet NSTextField	*	mNicknameField;
	ULINetSocket			*	mSocket;
	NSString				*	mNickname;
}

- (IBAction)disconnect:(id)inSender;
- (IBAction)connect:(id)inSender;
- (IBAction)connectConnect:(id)inSender;
- (IBAction)connectCancel:(id)inSender;

- (void)connectToAddress:(NSString*)inAddress;
- (void)loginWithNickname:(NSString*)inNickname;
- (void)sendChat:(NSAttributedString*)inChat;

- (void)processPacket:(NetPacket*)inPacket;
- (void)processNewClientPacket:(NetPacket*)inPacket;
- (void)processClientDisconnectedPacket:(NetPacket*)inPacket;
- (void)processChatPacket:(NetPacket*)inPacket;

@end
