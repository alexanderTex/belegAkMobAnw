#import "ViewController.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *airplane;
@property (strong, nonatomic) NSMutableArray* clouds;
@property (strong, nonatomic) UIImage *cloud;
@property (strong, nonatomic) NSTimer *updateTimer;
@property (strong, nonatomic) UIView *blueView;
@property (nonatomic) bool gameOver;
@property (nonatomic) float fixedUpdateDelta;
@property (nonatomic) float planespeed;
@property (nonatomic) float distanceTravelled;
@property (nonatomic) float gameTime;
@property (nonatomic) int collisionLastFrame;
@property (nonatomic) int lastSpawn;
@property (nonatomic) int enemyCount;
@property (nonatomic) int spawnMax;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clouds = [NSMutableArray arrayWithCapacity:10];
    self.gameOver = false;
    self.gameTime = 0.0;
    self.fixedUpdateDelta = 0.01;
    self.distanceTravelled = 0.0;
    self.planespeed = 847.0;
    self.collisionLastFrame = -1;
    self.lastSpawn = 0;
    self.enemyCount = 0;
    self.spawnMax = 3;
    self.distanceLabel.text = [NSString stringWithFormat:@"Distance: %.3f km", self.distanceTravelled];
    self.timeLabel.text =[NSString stringWithFormat:@"Time : %.1f sec", self.gameTime];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.fixedUpdateDelta target:self selector:@selector(callBack) userInfo:nil repeats:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
}

- (UIView *)SpawnCloudAt: (int) xpos{
    UIView *redView;
    CGRect blueFrame = CGRectMake( xpos - 50, -100, 100, 100);
    redView = [[UIView alloc]initWithFrame:blueFrame];
    [self.view addSubview:redView];
    [self.view sendSubviewToBack:redView];
    self.cloud = [UIImage imageNamed:@"wolke.png"];
    UIImageView *cloudView = [[UIImageView alloc] initWithImage:self.cloud];
    [redView addSubview:cloudView];
    CGRect cloudViewImageFrame = cloudView.frame;
    cloudViewImageFrame.size.width = 100;
    cloudViewImageFrame.size.height = 100;
    cloudView.frame = cloudViewImageFrame;
    return redView;
}

- (void)callBack{
    static float endTime = 120.0;
    float momentum = self.planespeed / (60*3);
    float stallSpeed = 235.00;
    if(!self.gameOver)
    {
        if( self.lastSpawn % 900 == 0 && self.enemyCount < self.spawnMax)
        {
            int newSpawn = arc4random_uniform([[UIScreen mainScreen] bounds].size.width);
            [self.clouds addObject: [self SpawnCloudAt: newSpawn]];
            self.enemyCount = (int)self.clouds.count;
        }
        bool alreadyCollided = false;
        int currentCollision = -1;
        for(int i = 0; i < self.clouds.count; i++)
        {
            UIView *currentView = [self.clouds objectAtIndex:i];
            CGRect currentRect = currentView.frame;
            if(currentRect.origin.y > [[UIScreen mainScreen] bounds].size.height)
            {
                currentRect.origin.y = -100;
                int newSpawn = arc4random_uniform([[UIScreen mainScreen] bounds].size.width);
                currentRect.origin.x = newSpawn;
                if(self.collisionLastFrame == i)
                {
                    self.collisionLastFrame = -1;
                }
            }
            else
            {
                currentRect.origin.y += momentum;
            }
        
            if( !alreadyCollided && CGRectIntersectsRect( currentRect, self.airplane.frame ))
            {
                currentCollision = i;
            
                if(self.collisionLastFrame == currentCollision)
                {
                    alreadyCollided = true;
                }
            }
            currentView.frame = currentRect;
        }
            if(currentCollision != self.collisionLastFrame && currentCollision >= 0){
            self.planespeed -= (self.planespeed * 0.12);
            if(self.planespeed <= stallSpeed)
            {
                [self EndGame];
            }
        }
        self.collisionLastFrame = currentCollision;
        self.lastSpawn++;
        self.gameTime += self.fixedUpdateDelta;
        self.timeLabel.text =[NSString stringWithFormat:@"Zeit : %.2f sek", self.gameTime];
        if((int)(self.gameTime * 100) % 100 == 0)
        {
            [self UpdateDistance];
            
            self.distanceLabel.text = [NSString stringWithFormat:@"Strecke: %.3f km", self.distanceTravelled];
            
            if(self.gameTime >= endTime)
            {
                [self EndGame];
            }
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)MovePlane:(UISlider *)sender {
    
    if(!self.gameOver)
    {
        float slidervalue = sender.value;
        CGFloat plainrad = self.airplane.bounds.size.width / 2;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat halfScreenWidth =screenWidth / 2;
        CGPoint airpCenter = self.airplane.center;
        airpCenter.x = halfScreenWidth + (plainrad - halfScreenWidth) * (1 - (2 * slidervalue));
        self.airplane.center = airpCenter;
    }
}

- (void)UpdateDistance{
    self.distanceTravelled += self.planespeed/3600;
}

- (void) SaveGame{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"HighScore"] ];
    [dict setObject: [NSString stringWithFormat:@"%f", self.distanceTravelled]  forKey: self.PlayerName];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:dict] forKey:@"HighScore"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)EndGame{
    self.gameOver = true;
    [self SaveGame];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}


@end
