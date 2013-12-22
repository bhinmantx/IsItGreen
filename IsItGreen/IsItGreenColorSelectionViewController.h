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
    NSString * _originalColorOfInterest;
    
    std::map<NSString*,NSString*> _friendlyNameToName;
    std::map<NSString*,NSString*> _nameToFriendlyName;
    
}
@property (strong, nonatomic) IBOutlet UIBarButtonItem *didSelectCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *didSelectDone;

@property (strong, nonatomic) NSString *originalColorOfInterest;
@property (strong, nonatomic) IBOutlet UIPickerView *colorPicker;

@property(nonatomic)     std::map<NSString*,NSString*> friendlyNameToName;
@property(nonatomic)     std::map<NSString*,NSString*> nameToFriendlyName;

@property(strong, nonatomic) NSMutableArray *colorOptions;

@property (nonatomic, weak) id<ColorSelectionViewControllerDelegate> delegate;
@end
