//
//  ViewController.swift
//  Assignment1_761984
//
//  Created by MacStudent on 2020-01-15.
//  Copyright © 2020 MacStudent. All rights reserved.
//

import UIKit
import  MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var destination: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        // Do any additional setup after loading the view.
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(Tap))
        doubleTapGesture.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTapGesture)
      
    }

    @objc func Tap(gestureRecogniser: UIGestureRecognizer){
        
        for annotation in mapView.annotations{
            
                             mapView.removeAnnotation(annotation)
                         }
             
        for overlay in mapView.overlays{
            
                             mapView.removeOverlay(overlay)
                         }
        
        let touchPoint = gestureRecogniser.location(in: mapView)
        
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
        
        destination = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
                 
    }
    
    func routing(destinationCoordinate: CLLocationCoordinate2D) {
        mapView.delegate = self
        
        let source = CLLocationCoordinate2D(latitude: 43.65, longitude: -79.38)
        
        let destination = CLLocationCoordinate2D(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
        
        let Placemark = MKPlacemark(coordinate: source, addressDictionary: nil)
        
        let destination_placemark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        
        let mapItem = MKMapItem(placemark: Placemark)
        
        let destinationMapItem = MKMapItem(placemark: destination_placemark)
        
        let source_annotation = MKPointAnnotation()
        
        if let location = Placemark.location {
             source_annotation.coordinate = location.coordinate
        }
        
        let destination_annotation = MKPointAnnotation()
        
        if let location = destination_placemark.location {
            
        destination_annotation.coordinate = location.coordinate
            
         self.mapView.showAnnotations([source_annotation,destination_annotation], animated: true )
            
        }
        
        let dir_request = MKDirections.Request()
        
                       dir_request.source = mapItem
        
                       dir_request.destination = destinationMapItem
                    
                    switch segment.selectedSegmentIndex {
                        
                      case 0:
                        
                          dir_request.transportType = .automobile
                        
                      case 1:
                          dir_request.transportType = .walking
                      default:
                          dir_request.transportType = .walking
                      }
          let map_directions = MKDirections(request: dir_request)
        
         map_directions.calculate {
            
            (response, error) -> Void in
            
        guard let Response = response else {
            
                if let error = error {
                        print("Error: \(error)")
                }
                return
            }
            
            
            let routes = Response.routes[0]
            
            self.mapView.addOverlay((routes.polyline), level: MKOverlayLevel.aboveRoads)
            
            let map_rect = routes.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(map_rect), animated: true)
            
        }

    
    }

    @IBAction func findway(_ sender: UIButton) {
        
         routing(destinationCoordinate: destination)
    }
    
    
    @IBAction func minus(_ sender: UIButton) {
        
        let location = mapView.userLocation.coordinate
        
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 600000*2, longitudinalMeters: 600000*2)
        
        mapView.setRegion(region, animated: true)
    }
}

extension ViewController : MKMapViewDelegate
    {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation is MKUserLocation{
                
                    return nil
                
            }
                
            else
            {
                let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
                
                pin.animatesDrop = true
                
                pin.tintColor = .red
                
                return pin
            }
        }
    
            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                
                if overlay is MKPolyline{
                    
                    let rendrer = MKPolylineRenderer(overlay: overlay)
                    
                    rendrer.strokeColor = UIColor.green
                    
                    rendrer.lineWidth = 4.0
                    
                    return rendrer

                }
                return MKOverlayRenderer()

            }

}



  


