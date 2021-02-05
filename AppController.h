/* AppController */

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#define CLStateOfAlarm		@"CLStateOfAlarm"

@interface AppController : NSObject
{
    NSSound *sound;
    NSTimer *timer;
    
    NSStatusItem *menuItem;
    IBOutlet NSMenu *menuItemMenu;
    
    IBOutlet NSMenuItem *enabledMenuItem;
    IBOutlet NSMenuItem *quitMenuItem;
    
    BOOL isAlarming;
    BOOL alarmIsEnabled;
}
- (void)checkCapsLock:(NSTimer *)aTimer;
- (IBAction)menuChanged:(id)sender;

- (void)setAlarmIsEnabled:(BOOL)aBool;
- (BOOL)alarmIsEnabled;

- (IBAction)openWebsite:(id)sender;
@end

// if you want to know how to "save" this app from the dock:
// in "Info.plist" the following two lines are the reason:
//         <key>NSUIElement</key>
//         <string>1</string>
