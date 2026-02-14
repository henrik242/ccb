#import <Cocoa/Cocoa.h>

static NSString * const CLStateOfAlarm = @"CLStateOfAlarm";

@interface AppController : NSObject

@property (nonatomic, strong) IBOutlet NSMenu *menuItemMenu;
@property (nonatomic, strong) IBOutlet NSMenuItem *enabledMenuItem;
@property (nonatomic, strong) IBOutlet NSMenuItem *quitMenuItem;

- (IBAction)menuChanged:(id)sender;
- (IBAction)openWebsite:(id)sender;

@end
