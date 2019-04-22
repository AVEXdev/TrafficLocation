//
//  ViewController.swift
//  TrafficLocation
//
//  Created by user149365 on 4/14/19.
//  Copyright © 2019 user149365. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView :MKMapView!
    
    private var rootRef :DatabaseReference!
    
    private var locationManager :CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rootRef = Database.database().reference()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        
        self.locationManager.requestWhenInUseAuthorization()
        
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        
        self.locationManager.startUpdatingLocation()
        
        setupUI()
        
        populateTrafficLocations()
    }
    
    private func populateTrafficLocations() {
        
        let trafficRegionsRef = self.rootRef.child("traffic-regions")
        
        trafficRegionsRef.observe(.value) { snapshot in
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            let trafficDictionaries = snapshot.value as? [String:Any] ?? [:]
            
            for (key, _) in trafficDictionaries {
                
                if let trafficDict = trafficDictionaries[key] as? [String:Any] {
                    
                    if let traffic = Traffic(dictionary: trafficDict) {
                        
                        DispatchQueue.main.async {
                            
                            let trafficAnnotation = MKPointAnnotation()
                            trafficAnnotation.coordinate = CLLocationCoordinate2D(latitude: traffic.latitude, longitude: traffic.longitude)
                            
                            self.mapView.addAnnotation(trafficAnnotation)
                            
                        }
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    private func setupUI() {
        
        let addTrafficButton = UIButton(frame: CGRect.zero)
        addTrafficButton.setImage(UIImage(named :"plus-image"), for: .normal)
        
        addTrafficButton.addTarget(self, action: #selector(addTrafficAnnotationButtonPressed), for: .touchUpInside)
        addTrafficButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(addTrafficButton)
        
        addTrafficButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        addTrafficButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
        addTrafficButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        addTrafficButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
    }
    
    @objc func addTrafficAnnotationButtonPressed(sender :Any?) {
        
        if let location = self.locationManager.location {
            
            let trafficAnnotation = MKPointAnnotation()
            trafficAnnotation.coordinate = location.coordinate
            self.mapView.addAnnotation(trafficAnnotation)
            
            let coordinate = location.coordinate
            let traffic = Traffic(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            let trafficRegionsRef = self.rootRef.child("traffic-regions")
            
            let trafficRef = trafficRegionsRef.childByAutoId()
            trafficRef.setValue(traffic.toDictionary())
            
        }
        
        print("addTrafficAnnotationButtonPressed")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            
            let coordinate = location.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            // self.mapView.setRegion(region, animated: true)
        }
        
    }
    
    
}
