//
//  LocationsViewController.swift
//  yeltzland
//
//  Created by John Pollard on 06/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import MapKit
import Font_Awesome_Swift

class LocationsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var mapToggleButton: UIBarButtonItem!
    
    var mapView = MKMapView()
    var locationManager = CLLocationManager()
    
    let regionRadius: CLLocationDistance = 600000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup refresh button
        self.mapToggleButton = UIBarButtonItem(
            title: "Toggle",
            style: .Plain,
            target: self,
            action: #selector(LocationsViewController.mapToggleButtonTouchUp)
        )
        self.mapToggleButton.FAIcon = FAType.FAMapO
        self.mapToggleButton.tintColor = AppColors.NavBarTintColor
        self.navigationController?.navigationBar.tintColor = AppColors.NavBarTintColor
        self.navigationItem.rightBarButtonItems = [self.mapToggleButton]
        
        self.navigationItem.title = "Where's The Ground?"
        
        // Setup location manager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        // Setup map settings
        self.mapView.mapType = .Standard
        self.mapView.frame = view.bounds
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.zoomEnabled = true
        
        // Setup initial view covering points
        self.mapView.setRegion(LocationManager.instance.mapRegion(), animated: true)
                
        // Add locations on map
        for location in LocationManager.instance.Locations {
            let cooordinate = CLLocationCoordinate2DMake(location.latitude!, location.longitude!)
            let annotation = LocationAnnotation(coordinate: cooordinate, team: location.team)
            self.mapView.addAnnotation(annotation)
        }
        
        // Finally add the map to the view
        self.view.addSubview(mapView)
    }
    
    func mapToggleButtonTouchUp() {
        if (self.mapView.mapType == .Standard) {
            self.mapView.mapType = .Satellite
        } else {
            self.mapView.mapType = .Standard
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.mapView.frame = self.view.bounds
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? LocationAnnotation {
            let identifier = "YLZAnnotation"
            var view: MKAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                let ballImage = UIImage(icon: FAType.FASoccerBallO, size: CGSize(width: 20, height: 20), textColor: AppColors.Evostick, backgroundColor: UIColor.clearColor())
                
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.image = ballImage
                view.centerOffset = CGPointMake(0, -10.0)
            }
            
            return view
        }
        else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let selectedLocation = view.annotation!.title
        print("Selected \(selectedLocation)")
    }
}
