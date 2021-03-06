//
//  ISAMiscellaneousTabViewController.h
//  iOSCoreLibrarySampleApp
//
//  Created by Iain McManus on 25/07/2014.
//  Copyright (c) 2014 Injaia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISAMiscellaneousTabViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *selectColourButton;
@property (weak, nonatomic) IBOutlet UIButton *resetTrainingButton;

- (IBAction)selectColour:(id)sender;
- (IBAction)resetTraining:(id)sender;

@end
