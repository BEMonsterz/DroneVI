//
//  MapsViewController.swift
//  FPVDemo
//
//  Created by Bryan Ayllon on 8/17/16.
//  Copyright © 2016 DJI. All rights reserved.
//

import UIKit
import CloudKit
import MapKit
import CoreLocation
class MapsViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var mapViews: MKMapView!
    var locationManager: CLLocationManager!
    var droneLocationsAnnotation: MKAnnotation!
    var container: CKContainer!
    var publicDB: CKDatabase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.mapViews.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.mapViews.showsUserLocation = true
        
        self.container = CKContainer.defaultContainer()
        self.publicDB = self.container.publicCloudDatabase
        
        populateFloodLocations()
        
        
    }
    
    private func populateFloodLocations() {
        
        let query = CKQuery(recordType: "DroneStuff", predicate: NSPredicate(format: "name = %@", "location"))
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { (records: [CKRecord]?, error: NSError?) in
            
            for location in records!{
                let locations = location["DroneLocations"] as! CLLocation
                let annotationCoordinate = locations.coordinate
                
                let droneLocationsAnnotation = MKPointAnnotation()
                droneLocationsAnnotation.title = "Warning!"
                droneLocationsAnnotation.coordinate = annotationCoordinate
                
                self.mapViews.addAnnotation(droneLocationsAnnotation)
                
            }
            
        }
        
        
        
    }
    
    
    
      @IBAction func pinPointPressed () {
        let droneLocationsAnnotation = MKPointAnnotation()
        droneLocationsAnnotation.title = "Warning!"
        droneLocationsAnnotation.coordinate = self.mapViews.userLocation.coordinate
        
        let savedAnnotation = CLLocation(coordinate: droneLocationsAnnotation.coordinate, altitude:0, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: NSDate())
        
        let pinPointedRecord = CKRecord(recordType: "DroneStuff")
        pinPointedRecord["DroneLocations"] = savedAnnotation
        pinPointedRecord["name"] = "location"
        self.publicDB.saveRecord(pinPointedRecord) { (record: CKRecord?, error: NSError?) in }
        self.mapViews.addAnnotation(droneLocationsAnnotation)
    }
    
    
    
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        if let annotationView = views.first {
            if let annotation = annotationView.annotation {
                if annotation is MKUserLocation {
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 300, 200)
                    self.mapViews.setRegion(region, animated: true)
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        self.droneLocationsAnnotation = view.annotation
        
        
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        
        let dronePhoto = UIImage(named: "dronepoint.png")
        
        var droneLocationsAnnotation = self.mapViews.dequeueReusableAnnotationViewWithIdentifier("droneLocationsAnnotation")
        
        
        if droneLocationsAnnotation == nil {
            droneLocationsAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: "droneLocationsAnnotation")
            
        } else {
            droneLocationsAnnotation?.annotation = annotation
            
        }
        
        droneLocationsAnnotation?.frame = CGRectMake(0, 0, 50, 50)
        
        let droneView = UIImageView(image: dronePhoto)
        
        droneView.frame.size = CGSize(width: 250, height:  250)
        droneLocationsAnnotation?.image = dronePhoto
        droneLocationsAnnotation?.frame = CGRectMake(0, 0, 25, 50)
        
        
        droneLocationsAnnotation?.userInteractionEnabled = true
        
        droneLocationsAnnotation!.canShowCallout = true
        
        let leftView = UIView(frame: CGRectMake(0,0,60,80))
        let delete = UIButton(frame: CGRectMake(0,-15.5,60,80))
        delete.titleLabel?.textColor = UIColor.blackColor()
        delete.setTitle("Delete", forState: UIControlState.Normal)
        delete.addTarget(self, action: #selector(destoryAnnotation), forControlEvents:UIControlEvents.TouchUpInside)
        leftView.backgroundColor = UIColor(red: 202.0/255, green: 15.0/255, blue: 20.0/255, alpha: 1.0)
        leftView.addSubview(delete)
        droneLocationsAnnotation!.leftCalloutAccessoryView = leftView
        return droneLocationsAnnotation
        
    }
    
    
    func destoryAnnotation() {
        
        let query = CKQuery(recordType: "DroneStuff", predicate: NSPredicate(format: "name = %@", "location"))
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { (records: [CKRecord]?, error: NSError?) in
            
            if let locations = records {
                
                for loactionRecord in locations {
                    
                    let recordCoordinate = loactionRecord["DroneLocations"] as! CLLocation
                    let savedLongtitudeCoordinate = recordCoordinate.coordinate.longitude
                    let longitudeSavedAnnotation = self.droneLocationsAnnotation.coordinate.longitude
                    let savedLatitudeCoordinate = recordCoordinate.coordinate.latitude
                    let latitudeSavedAnnotation = self.droneLocationsAnnotation.coordinate.latitude
                    
                    if(savedLongtitudeCoordinate == longitudeSavedAnnotation && savedLatitudeCoordinate == latitudeSavedAnnotation ){
                        self.publicDB.deleteRecordWithID(loactionRecord.recordID, completionHandler: { (recordId: CKRecordID?, error: NSError?) in })
                    }
                }
                
            }
            
            
        }
        
        mapViews.removeAnnotation(self.droneLocationsAnnotation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
}
