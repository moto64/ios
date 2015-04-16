//
//  MapViewController.swift
//  Moto64
//
//  Created by AseR on 16.04.15.
//
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var detailItem: DataFeed.Item?
    
    func closeMap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let mapFrame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        let mapView = MKMapView(frame: mapFrame)
        
        let closeMapButton = UIButton(frame: CGRectMake(0, 0, 64, 64))
        closeMapButton.layer.position = CGPoint(x: mapView.frame.width - closeMapButton.frame.width/2 - 20,
            y: mapView.frame.size.height - closeMapButton.frame.height/2 - 20)
        closeMapButton.setImage(UIImage(named: "MapClose"), forState: .Normal)
        closeMapButton.alpha = 0.5
        closeMapButton.addTarget(self, action: "closeMap:", forControlEvents: .TouchUpInside)
        mapView.addSubview(closeMapButton)
        
        self.view.addSubview(mapView)

        if let latitude = detailItem?.latitude {
            if let longitude = detailItem?.longitude {
                let latitudeDouble = (latitude as NSString).doubleValue
                let longitudeDouble = (longitude as NSString).doubleValue
                if latitudeDouble > 0 && longitudeDouble > 0 {
                    
                    let location = CLLocationCoordinate2D(
                        latitude: latitudeDouble,
                        longitude: longitudeDouble
                    )
                    
                    let span = MKCoordinateSpanMake(0.005, 0.005)
                    let region = MKCoordinateRegion(center: location, span: span)
                    
                    mapView.setRegion(region, animated: true)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location
                    annotation.title = "ДТП"
                    if let date = detailItem?.pubDate {
                        var dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "dd.MM.yyyy hh:mm:ss"
                        annotation.subtitle = dateFormatter.stringFromDate(date)
                    }
                    //annotation.subtitle = ""
                    mapView.addAnnotation(annotation)
                }
            }
        }
    }

}
