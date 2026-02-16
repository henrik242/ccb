#import <Cocoa/Cocoa.h>

static NSString * const CLStateOfAlarm = @"CLStateOfAlarm";
static NSString * const CLNumberOfBeeps = @"CLNumberOfBeeps";

@interface AppController : NSObject <NSSoundDelegate>

@property (nonatomic, strong) IBOutlet NSMenu *menuItemMenu;
@property (nonatomic, strong) IBOutlet NSMenuItem *enabledMenuItem;
@property (nonatomic, strong) IBOutlet NSMenuItem *quitMenuItem;

- (IBAction)menuChanged:(id)sender;
- (IBAction)openWebsite:(id)sender;

@end
