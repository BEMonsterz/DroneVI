//
//  MapViewController.h
//  FPVDemo
//
//  Created by Bryan Ayllon on 8/16/16.
//  Copyright © 2016 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface MapViewController : UIViewController{
    
    MKMapView *mapView;
    
}
@property (strong,nonatomic) IBOutlet MKMapView *mapView;
@end
