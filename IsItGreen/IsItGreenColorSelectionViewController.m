//
//  IsItGreenColorSelectionViewController.m
//  IsItGreen
//
//  Created by Brendan Hinman on 12/20/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import "IsItGreenColorSelectionViewController.h"

@interface IsItGreenColorSelectionViewController ()

@end

@implementation IsItGreenColorSelectionViewController

@synthesize colorOptions = _colorOptions;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    NSLog(@"ViewWillAppear");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self colorPicker].delegate = self;
   [self colorPicker].dataSource = self;
    
    _colorOptions = [NSMutableArray arrayWithCapacity:2];
    
    [_colorOptions addObject:@"g"];
    [_colorOptions addObject:@"r"];
    
    
    
    NSLog(@"%@", [_colorOptions objectAtIndex:0]);
        NSLog(@"%@", [_colorOptions objectAtIndex:1]);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


///Just one column
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
      //NSLog(@"num components");
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    //  NSLog(@"Num rows");
    return 2;
}

/*
-(UIView*)pickerView:(UIPickerView *)pickerView viewforRow:(NSInteger)row forComponent:(NSInteger)component{
 UIView *rowView = [[UIView alloc] initWithFrame: CGRectMake ( 0, 0, 20, 20)];
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    myLabel.text = @"My Label";
    [rowView addSubview:myLabel];
    
    return rowView;
    //return  [_colorOptions objectAtIndex:row];
}
 */

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [_colorOptions objectAtIndex:row];
    //return @"A";
}


 
///Buttons on the nav bar

- (IBAction)didSelectDone:(UIButton *)sender
{
    
   [self.delegate didDismissPresentedViewController:@"g"];
}

@end
