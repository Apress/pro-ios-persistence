//
// From the book Pro iOS Persistence
// Michael Privat and Rob Warner
// Published by Apress, 2014
// Source released under The MIT License
// http://opensource.org/licenses/MIT
//
// Contact information:
// Michael: @michaelprivat -- http://michaelprivat.com -- mprivat@mac.com
// Rob: @hoop33 -- http://grailbox.com -- rwarner@grailbox.com
//

@import CoreData;
#import "ViewController.h"
#import "Persistence.h"

@interface ViewController ()
@property (nonatomic, strong) Persistence *persistence;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self addObserver:self forKeyPath:@"managedObjectContext" options:NSKeyValueObservingOptionNew context:NULL];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.persistence = [[Persistence alloc] init];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.managedObjectContext = [self.persistence createManagedObjectContext];
            });
        });
    }
    return self;
}

/* No threads version
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self writeData];
    
    CGFloat status = 0;
    while(status < 1.0) {
        status = [self reportStatus];
        NSLog(@"Status: %lu%%", (unsigned long)(status * 100));
    }
    
    NSLog(@"All done");
}
*/

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self writeData];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat status = 0;
        while(status < 1.0) {
            status = [self reportStatus];
//            NSLog(@"Status: %lu%%", (unsigned long)(status * 100));
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressView.progress = status;
                self.label.text = [NSString stringWithFormat:@"%lu%%",
                                   (unsigned long)(status * 100)];
            });
        }
        
        NSLog(@"All done");
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.progressView.progress = 0;
    self.label.text = @"Initializing Core Data";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)writeData {
    NSManagedObjectContext *context = [self.persistence createManagedObjectContext];
  
    NSLog(@"Writing");
    for(int i=0; i<10000; i++) {
        NSManagedObject *obj = [NSEntityDescription
                                insertNewObjectForEntityForName:@"MyData"
                                inManagedObjectContext:context];
        [obj setValue:[NSNumber numberWithInt:i] forKey:@"myValue"];
        
        NSError *error;
        [context save:&error];
        if(error) {
            NSLog(@"Boom while writing! %@", error);
        }
    }
    NSLog(@"Done");
}

- (CGFloat)reportStatus {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"MyData"
                                 inManagedObjectContext:context];
    
    NSError *error;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    
    if(error) {
        NSLog(@"Boom while reading! %@", error);
    }
    
    return (CGFloat)count / 10000.0f;
}

@end
