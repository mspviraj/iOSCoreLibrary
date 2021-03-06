//
//  ISAPetsTabViewController.m
//  iOSCoreLibrarySampleApp
//
//  Created by Iain McManus on 12/07/2014.
//  Copyright (c) 2014 Injaia. All rights reserved.
//

#import "ISAPetsTabViewController.h"
#import "ISAPetDetailsViewController.h"

#import "Pet+Extensions.h"
#import "Owner+Extensions.h"
#import "Classification+Extensions.h"

#import <iOSCoreLibrary/ICLCoreDataManager.h>

@interface ISAPetsTabViewController () <StoreChangedDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, DataChangedDelegate>

@end

@implementation ISAPetsTabViewController {
    NSArray* cachedPets;
    
    Pet* petToDelete;
    UIAlertView* deleteConfirmation;
    
    UIScreenEdgePanGestureRecognizer* edgePanGesture;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[ISADataManager Instance] registerStoreChangedDelegate:self];
    [[ISADataManager Instance] registerDataChangedDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Notify that this view is now visible. This is used as part of handling new iCloud data being synchronised.
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_LoadedNewVC
                                                        object:nil
                                                      userInfo:@{@"viewController": self}];
    
    if ([[ICLCoreDataManager Instance] isDataStoreOnline]) {
        [self refreshDisplay];
    }
    
    // Detect left edge pan
    edgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgePanGesture:)];
    edgePanGesture.edges = UIRectEdgeLeft;
    edgePanGesture.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:edgePanGesture];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view removeGestureRecognizer:edgePanGesture];
    
    edgePanGesture = nil;
}

- (void) refreshDisplay {
    cachedPets = [Pet allObjects];
    [self.petsTable reloadData];
    
    [self showOverlay:NO];
}

- (void) showOverlay:(BOOL) forceReshow {
    // We dispatch to the main queue here to allow a slight delay for the pets table to reload
    dispatch_async(dispatch_get_main_queue(), ^{
        ICLTrainingOverlayData* overlay = nil;
        
        // Register the overlay
        overlay = [ICLTrainingOverlayInstance registerScreen:@"PetsTab1"
                                                   titleText:@"Pets Overview"
                                                 description:@"This screen lists all of the pets. From here you can add, update or remove a pet entry."];
        
        [overlay addElement:@[self.mainNavigationBar, self.addPetButton]
                description:@"Tap here to add a new pet."];
        
        [ICLTrainingOverlayInstance showScreen:@"PetsTab1" forceReshow:forceReshow currentViewController:self displayPosition:edpNone];
        
        if ([self.petsTable.visibleCells count] > 0) {
            ICLTrainingOverlayData* overlay = nil;
            
            // Register the overlay
            overlay = [ICLTrainingOverlayInstance registerScreen:@"PetsTab2"
                                                       titleText:@"Pets Overview"
                                                     description:@""];
            
            UITableViewCell* cell = self.petsTable.visibleCells[0];
            
            // If there are multiple cells then the first cell may not be visible
            if ([[self.petsTable visibleCells] count] > 1) {
                NSArray* indexPaths = self.petsTable.indexPathsForVisibleRows;
                
                CGRect firstCellRect = [self.petsTable rectForRowAtIndexPath:indexPaths[0]];
                firstCellRect = [self.petsTable convertRect:firstCellRect toView:self.petsTable.superview];
                
                if (!CGRectContainsRect(self.petsTable.frame, firstCellRect)) {
                    cell = self.petsTable.visibleCells[1];
                }
            }
            
            [overlay addElement:cell
                    description:@"Tap here to edit the pet details. Swipe left to delete the pet."];
            
            [ICLTrainingOverlayInstance showScreen:@"PetsTab2" forceReshow:forceReshow currentViewController:self displayPosition:edpNone];
        }
    });
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AddPet"]) {
        ISAPetDetailsViewController* viewController = [segue destinationViewController];
        viewController.pet = nil;
    }
    else if ([[segue identifier] isEqualToString:@"EditPet"]) {
        ISAPetDetailsViewController* viewController = [segue destinationViewController];
        viewController.pet = sender;
    }
}

#pragma mark StoreChangedDelegate Support

- (void) storeWillChange {
    // The objects are going away so clear out any stored data
    cachedPets = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.petsTable reloadData];
    });
}

- (void) storeDidChange {
    // If we are the active VC then refresh the data. Otherwise it will be refreshed when we appear.
    if ([[ISADataManager Instance] currentViewController] == self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshDisplay];
        });
    }
}

#pragma mark UITableViewDataSource Support

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cachedPets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PetCell"];
    Pet* petForCell = cachedPets[indexPath.row];
    
    NSString* cellText = petForCell.name;
    
    if (petForCell.owner && petForCell.classification) {
        cellText = [NSString stringWithFormat:@"%@ (%@) owned by %@", petForCell.name, petForCell.classification.name, petForCell.owner.name];
    }
    else if (petForCell.owner) {
        cellText = [NSString stringWithFormat:@"%@ owned by %@", petForCell.name, petForCell.owner.name];
    }
    else if (petForCell.classification) {
        cellText = [NSString stringWithFormat:@"%@ (%@)", petForCell.name, petForCell.classification.name];
    }
    
    [cell.textLabel setText:cellText];
    
    return cell;
}

- (void) tableView:(UITableView*) tableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath*) indexPath {
    NSString* messageTitle = NSLocalizedStringFromTable(@"Delete.ConfirmationMessageTitle", @"Common", @"Confirm Deletion");
    NSString* message = nil;
    
    petToDelete = cachedPets[indexPath.row];
    
    message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"DeletePet", @"Pets", @"Are you sure you wish to delete the pet %@ ?"), petToDelete.name];
    
    deleteConfirmation = [[UIAlertView alloc] initWithTitle:messageTitle message:message delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"no", @"Common", @"No") otherButtonTitles:NSLocalizedStringFromTable(@"yes", @"Common", @"Yes"), nil];
    
    [deleteConfirmation show];
}

#pragma mark UITableViewDelegate Support

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"EditPet" sender:cachedPets[indexPath.row]];
}

- (UITableViewCellEditingStyle) tableView:(UITableView*) tableView editingStyleForRowAtIndexPath:(NSIndexPath*) indexPath {
    return UITableViewCellEditingStyleDelete;
}

#pragma mark UIAlertViewDelegate Support

- (void) alertView:(UIAlertView*) alertView clickedButtonAtIndex:(NSInteger) buttonIndex {
    if (alertView == deleteConfirmation) {
        if (buttonIndex == 0) {
            petToDelete = nil;
        }
        else {
            NSManagedObjectContext* context = [[ICLCoreDataManager Instance] managedObjectContext];
            [context performBlockAndWait:^{
                [context deleteObject:petToDelete];
            }];
            [[ICLCoreDataManager Instance] saveContext];
            
            petToDelete = nil;
            
            [self refreshDisplay];
        }
    }
}

#pragma DataChangedDelegate support

- (void) dataChanged:(NSDictionary *)changeInfo remoteChange:(BOOL)isRemoteChange {
    // Has a change to pets, owners or classifications happened?
    if (changeInfo[@(emtPet)] || changeInfo[@(emtOwner)] || changeInfo[@(emtClassification)]) {
        // Nothing fancy is required. If we are the active VC then refresh the data. Otherwise it will be refreshed when we appear.
        if ([[ISADataManager Instance] currentViewController] == self) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshDisplay];
            });
        }
    }
}

#pragma mark Overlay Reshow Handling

- (void) edgePanGesture:(UIGestureRecognizer*) recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        // Force the overlay to be reshown
        [self showOverlay:YES];
    }
}

@end
