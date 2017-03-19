#import "StartViewController.h"
#import "ViewController.h"

@interface StartViewController ()
@property (weak, nonatomic) IBOutlet UITextField *playerName;

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    ViewController* vc = [segue destinationViewController];
    
    if([segue.identifier  isEqual: @"StartGame"])
    {
        vc.PlayerName = self.playerName.text;
    }
    
    
}


@end
