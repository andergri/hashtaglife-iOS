//
//  SELMapViewController.m
//  #life
//
//  Created by Griffin Anderson on 2/24/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELMapViewController.h"

@interface SELMapViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewA;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewB;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewC;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewD;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewE;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewF;
@property (weak, nonatomic) IBOutlet UIView *tappable;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewG;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewH;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewI;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewJ;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewK;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewL;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewM;
@property UITapGestureRecognizer *tpgr;
@property NSArray *imageViewArray;
@property NSMutableArray *mapsArray;

@end

@implementation SELMapViewController

@synthesize tpgr;
@synthesize imageViewArray;
@synthesize color;
@synthesize mapsArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Tap Gesture
    tpgr = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(tapMap:)];
    tpgr.numberOfTouchesRequired = 1;
    tpgr.delegate = self;
    tpgr.enabled = YES;
    [self.tappable addGestureRecognizer:tpgr];
    
    // ImageViewArray
    mapsArray = [[NSMutableArray alloc] init];
    imageViewArray = [[NSArray alloc] initWithObjects:self.imageViewA, self.imageViewB, self.imageViewC, self.imageViewD, self.imageViewE, self.imageViewE, self.imageViewF, self.imageViewG, self.imageViewH, self.imageViewI, self.imageViewJ, self.imageViewK, self.imageViewL, self.imageViewM, nil];
    [self prefersStatusBarHidden];
    [self loadMap:[PFObject objectWithoutDataWithClassName:@"Map" objectId:@"NR2pwctd4I"] completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadMap:(PFObject *)loadParent completion:(void (^)(BOOL finished))completion {
    
    @try {
        
        PFQuery *queryMap = [PFQuery queryWithClassName:@"Map"];
        [queryMap whereKey:@"parent" equalTo:loadParent];
        [queryMap findObjectsInBackgroundWithBlock:^(NSArray *maps, NSError *error) {
            if (!error) {
                mapsArray = (NSMutableArray *) maps;
                [self setImages:maps];
                if (completion) {
                    completion(YES);
                }
            }else{
                if (completion) {
                    completion(NO);
                }
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void) setImages: (NSArray *) maps{

    __block int i = 0;
    __block NSArray *colorArray = [color getColorArray];
    
    int j = 0;
    while (j < imageViewArray.count) {
        UIImageView *mapImageView = ((UIImageView *)[imageViewArray objectAtIndex:j]);
        mapImageView.image = nil;
        j++;
    }
    
   //NSLog(@"a %lu", (unsigned long)maps.count);
    NSLog(@"maps size %lu", (unsigned long)maps.count);
    for (PFObject *map in maps) {
        //NSLog(@"b %d %d", [maps indexOfObject:map], i);
        PFFile *imageFile = map[@"image"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            //NSLog(@"c %d %d", [maps indexOfObject:map], i);
            if (!error) {
                if([UIImage imageWithData:data]){
                    UIImage *imageMap = [[UIImage imageWithData:data] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    
                    UIImageView *mapImageView = ((UIImageView *)[imageViewArray objectAtIndex:[maps indexOfObject:map]]);
                    mapImageView.image = imageMap;
                    [mapImageView setTintColor:[colorArray objectAtIndex:i]];
                    NSLog(@"count %lu %d", (unsigned long)[maps indexOfObject:map], i);
                }
            }else{
                NSLog(@"image loading error");
            }
            NSLog(@"i %d", i);
            i++;
        }];
    }
}

- (void) tapMap:(UITapGestureRecognizer *)gestureRecognizer {
   
    CGPoint originalPoint = [gestureRecognizer locationInView:gestureRecognizer.view];

    UIImageView *sizeImageView = [imageViewArray objectAtIndex:0];
    
    CGPoint point = [self pixelPointFromViewPoint:originalPoint image:sizeImageView.image frame:sizeImageView];
    
    for (UIImageView *imageView in imageViewArray) {
        if (imageView.image != nil) {
            
            BOOL tappedImageView = [self pointInside:point image:imageView.image];
            if (tappedImageView) {
                
                int i = (int) [imageViewArray indexOfObject:imageView];
                PFObject *map = [mapsArray objectAtIndex:i];
               // NSString * name = [map objectForKey:@"name"];
                
                //[self pushOut:originalPoint];
                [self loadMap:map completion:^(BOOL finished) {
                    if (finished) {
                        
                        //NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 1.0 ];
                        //[NSThread sleepUntilDate:future];
                        //[self pushIn:originalPoint];
                    }
                }];
                
                break;
            }
        }
    }
}


- (void) pushOut:(CGPoint) originalPoint{
    
    // Transform
    CGFloat s = 1.4;
    CGAffineTransform tr = CGAffineTransformScale(self.view.transform, s, s);
    CGFloat h = self.view.frame.size.height;
    CGFloat w = self.view.frame.size.width;
    [self.view setAlpha:1.0f];
    
    [UIView animateWithDuration:1.5 delay:0 options:0 animations:^{
        
        self.view.transform = tr;
        CGFloat cx = w/2-s*(originalPoint.x-w/2);
        CGFloat cy = h/2-s*(originalPoint.y-h/2);
        self.view.center = CGPointMake(cx, cy);
        
        //[self.view setAlpha:0.0f];
    } completion:^(BOOL finished) {
        
    }];
}

- (void) pushIn:(CGPoint) originalPoint{
    CGFloat s = .4;
    CGAffineTransform tr = CGAffineTransformScale(self.view.transform, s, s
                                                  );
    //CGFloat h = self.view.frame.size.height;
    CGFloat w = self.view.frame.size.width;

    //originalPoint = CGPointMake(self.view.frame.origin.x + (w/2.0), self.view.frame.origin.y + (h/2.0));
    originalPoint = CGPointMake(160, 160);
    NSLog(@"1 %f", w);
    NSLog(@"2 %f", originalPoint.x);
    NSLog(@"1.1 %f", self.view.frame.origin.x);
    self.view.transform = tr;
    self.view.center = originalPoint;
    /**
    [UIView animateWithDuration:1.5 delay:0 options:0 animations:^{
        
        self.view.transform = CGAffineTransformIdentity;
        self.view.center = CGPointMake(self.view.superview.bounds.size.width/2,
                                       self.view.superview.bounds.size.height/2);
        [self.view setAlpha:1.0f];
        
    } completion:^(BOOL finished) {
    }];**/
     
    
}

- (BOOL)pointInside:(CGPoint)point image:(UIImage *) image {
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel,
                                                 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    UIGraphicsPushContext(context);
    [image drawAtPoint:CGPointMake(-point.x, -point.y)];
    
    UIGraphicsPopContext();
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
     
    CGFloat alpha = pixel[3]/255.0f;
    BOOL transparent = alpha < 0.01f;
    
    return !transparent;
}


-(CGPoint) pixelPointFromViewPoint:(CGPoint)touch image:(UIImage *)image frame:(UIView *)view;
{
    
    CGSize scaledImageSize = [self imageSizeAfterAspectFit:view image:image];
    float extraHeight = 0;
    float extraWidth = 0;
    float xMultiple = image.size.width / scaledImageSize.width;
    float yMultiple = image.size.height / scaledImageSize.height;
    
    
    float imageRatio = image.size.width / image.size.height;
    if (imageRatio > 1.00) {
        extraHeight = (view.frame.size.height - (scaledImageSize.height)) / 2.0;
    }else if (imageRatio < 1.00){
        extraWidth = (view.frame.size.width - (scaledImageSize.width)) / 2.0;
    }
    
    float tX = ((touch.x - extraWidth) * xMultiple);
    float tY = ((touch.y - extraHeight) * yMultiple);
    return CGPointMake(tX, tY);
    
}

-(CGSize)imageSizeAfterAspectFit:(UIView*)imgview image:(UIImage*)image{
    
    
    float newwidth;
    float newheight;

    
    if (image.size.height>=image.size.width){
        newheight=imgview.frame.size.height;
        newwidth=(image.size.width/image.size.height)*newheight;
        
        if(newwidth>imgview.frame.size.width){
            float diff=imgview.frame.size.width-newwidth;
            newheight=newheight+diff/newheight*newheight;
            newwidth=imgview.frame.size.width;
        }
        
    }
    else{
        newwidth=imgview.frame.size.width;
        newheight=(image.size.height/image.size.width)*newwidth;
        
        if(newheight>imgview.frame.size.height){
            float diff=imgview.frame.size.height-newheight;
            newwidth=newwidth+diff/newwidth*newwidth;
            newheight=imgview.frame.size.height;
        }
    }
    return CGSizeMake(newwidth, newheight);
}

@end
