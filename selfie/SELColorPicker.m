//
//  SELColorPicker.m
//  selfie
//
//  Created by Griffin Anderson on 7/25/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELColorPicker.h"
#include <stdlib.h>

@interface SELColorPicker ()

@property NSMutableArray* colorArray;
@property int random;

@end

@implementation SELColorPicker

@synthesize colorArray;
@synthesize random;

- (void) setColorArray{
    colorArray = [[NSMutableArray alloc] init];
    
    // Red
    [colorArray addObject:[UIColor colorWithRed:210.0/255.0 green:77.0/255.0 blue:87.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:242.0/255.0 green:38.0/255.0 blue:19.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:217.0/255.0 green:30.0/255.0 blue:24.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:150.0/255.0 green:40.0/255.0 blue:27.0/255.0 alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:239.0/255.0 green:72.0/255.0 blue:54.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:214.0/255.0 green:69.0/255.0 blue:65.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:192.0/255.0 green:57.0/255.0 blue:43.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:207.0/255.0 green:0.0/255.0 blue:15.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1.0]];
    
    // Pink
    [colorArray addObject:[UIColor colorWithRed:219.0/255.0 green:10.0/255.0 blue:91.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:246.0/255.0 green:71.0/255.0 blue:71.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:241.0/255.0 green:169.0/255.0 blue:160.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:210.0/255.0 green:82.0/255.0 blue:127.0/255.0 alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:224.0/255.0 green:130.0/255.0 blue:131.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:246.0/255.0 green:36.0/255.0 blue:89.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:226.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:102.0/255.0 green:51.0/255.0 blue:153.0/255.0 alpha:1.0]];
    
    // Purple
    [colorArray addObject:[UIColor colorWithRed:103.0/255.0 green:65.0/255.0 blue:114.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:174.0/255.0 green:168.0/255.0 blue:211.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:145.0/255.0 green:61.0/255.0 blue:136.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:154.0/255.0 green:18.0/255.0 blue:179.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:191.0/255.0 green:85.0/255.0 blue:236.0/255.0 alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:190.0/255.0 green:144.0/255.0 blue:212.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:142.0/255.0 green:68.0/255.0 blue:173.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:155.0/255.0 green:89.0/255.0 blue:182.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:65.0/255.0 green:131.0/255.0 blue:215.0/255.0 alpha:1.0]];
    
    // Blue
    [colorArray addObject:[UIColor colorWithRed:89.0/255.0 green:171.0/255.0 blue:227.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:129.0/255.0 green:207.0/255.0 blue:224.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:82.0/255.0 green:179.0/255.0 blue:217.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:34.0/255.0 green:167.0/255.0 blue:240.0/255.0 alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:52.0/255.0 green:152.0/255.0 blue:219.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:44.0/255.0 green:62.0/255.0 blue:80.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:25.0/255.0 green:181.0/255.0 blue:254.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:51.0/255.0 green:110.0/255.0 blue:123.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:34.0/255.0 green:49.0/255.0 blue:63.0/255.0 alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:107.0/255.0 green:185.0/255.0 blue:240.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:30.0/255.0 green:139.0/255.0 blue:195.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:58.0/255.0 green:83.0/255.0 blue:155.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:52.0/255.0 green:73.0/255.0 blue:94.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:103.0/255.0 green:128.0/255.0 blue:159.0/255.0 alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:37.0/255.0 green:116.0/255.0 blue:169.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:31.0/255.0 green:58.0/255.0 blue:147.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:137.0/255.0 green:196.0/255.0 blue:244.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:75.0/255.0 green:119.0/255.0 blue:190.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:92.0/255.0 green:151.0/255.0 blue:191.0/255.0 alpha:1.0]];
    
    // green
    [colorArray addObject:[UIColor colorWithRed:135.0/255.0 green:211.0/255.0 blue:124.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:144.0/255.0 green:198.0/255.0 blue:149.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:91.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:3.0/255.0 green:201.0/255.0 blue:169.0/255.0 alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:104.0/255.0 green:195.0/255.0 blue:163.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:101.0/255.0 green:198.0/255.0 blue:187.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:27.0/255.0 green:188.0/255.0 blue:155.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:27.0/255.0 green:163.0/255.0 blue:156.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:102.0/255.0 green:204.0/255.0 blue:153.0/255.0 alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:54.0/255.0 green:215.0/255.0 blue:183.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:200.0/255.0 green:247.0/255.0 blue:197.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:134.0/255.0 green:226.0/255.0 blue:213.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:46.0/255.0 green:204.0/255.0 blue:113.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:22.0/255.0 green:160.0/255.0 blue:133.0/255.0 alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:63.0/255.0 green:195.0/255.0 blue:128.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:1.0/255.0 green:152.0/255.0 blue:117.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:3.0/255.0 green:166.0/255.0 blue:120.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:77.0/255.0 green:175.0/255.0 blue:124.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:42.0/255.0 green:187.0/255.0 blue:155.0/255.0 alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:0.0/255.0 green:177.0/255.0 blue:106.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:30.0/255.0 green:130.0/255.0 blue:76.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:4.0/255.0 green:147.0/255.0 blue:114.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:38.0/255.0 green:194.0/255.0 blue:129.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:245.0/255.0 green:215.0/255.0 blue:110.0/255.0 alpha:1.0]];

    // Yellow, Orange
    [colorArray addObject:[UIColor colorWithRed:247.0/255.0 green:202.0/255.0 blue:24.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:244.0/255.0 green:208.0/255.0 blue:63.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:248.0/255.0 green:148.0/255.0 blue:6.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:235.0/255.0 green:149.0/255.0 blue:50.0/255.0 alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:232.0/255.0 green:126.0/255.0 blue:4.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:244.0/255.0 green:179.0/255.0 blue:80.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:242.0/255.0 green:120.0/255.0 blue:75.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:235.0/255.0 green:151.0/255.0 blue:78.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:245.0/255.0 green:171.0/255.0 blue:53.0/255.0 alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:211.0/255.0 green:84.0/255.0 blue:0.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:249.0/255.0 green:105.0/255.0 blue:14.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:249.0/255.0 green:191.0/255.0 blue:59.0/255.0 alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:242.0/255.0 green:121.0/255.0 blue:53.0/255.0 alpha:1.0]];
    
}

- (void) initColor{
    [self setColorArray];
    random = arc4random() % colorArray.count;
}

- (UIColor *) getPrimaryColor{
    return [colorArray objectAtIndex:random];
}

- (NSArray *) getColorArray{
    
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    
    for(int i = 1; i < 11; i++){
        
        random = arc4random() % colorArray.count;
        [colors addObject:[colorArray objectAtIndex:(random)]];
        /**
        if((random + i) < colorArray.count){
            [colors addObject:[colorArray objectAtIndex:(random + i)]];
        }else{
            [colors addObject:[colorArray objectAtIndex:(random + i - colorArray.count)]];
        }
         **/
    }
    return colors;
}

@end
