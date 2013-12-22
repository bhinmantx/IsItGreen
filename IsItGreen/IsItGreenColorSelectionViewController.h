//
//  IsItGreenColorSelectionViewController.h
//  IsItGreen
//
//  Created by Brendan Hinman on 12/20/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//
///A simple picker view to allow users to select their "color of interest"

#import <UIKit/UIKit.h>

@protocol ColorSelectionViewControllerDelegate <NSObject>
- (void)didDismissPresentedViewController:(NSString*)color;
@end

@interface IsItGreenColorSelectionViewController : UIViewController  <UIPickerViewDelegate, UIPickerViewDataSource>{
    NSMutableArray *_colorOptions;

}
@property (strong, nonatomic) IBOutlet UIBarButtonItem *didSelectCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *didSelectDone;


@property (strong, nonatomic) IBOutlet UIPickerView *colorPicker;

@property(strong, nonatomic) NSMutableArray *colorOptions;

@property (nonatomic, weak) id<ColorSelectionViewControllerDelegate> delegate;
@end
