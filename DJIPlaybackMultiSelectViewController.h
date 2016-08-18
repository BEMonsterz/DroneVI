//
//  DJIPlaybackMultiSelectViewController.h
//  DroneApplication
//
//  Created by Bryan Ayllon on 8/18/16.
//  Copyright © 2016 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DJIPlaybackMultiSelectViewController : UIViewController

@property (copy, nonatomic) void (^selectItemBtnAction)(int index);
@property (copy, nonatomic) void (^swipeGestureAction)(UISwipeGestureRecognizerDirection direction);


@end
