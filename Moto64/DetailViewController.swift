//
//  DetailViewController.swift
//  Moto64
//
//  Created by AseR on 15.03.15.
//
//

import UIKit
import MapKit

class DetailViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descrText: UITextView!
    @IBOutlet var mapView: MKMapView!

    var detailItem: DataFeed.Item? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        
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
                    annotation.setCoordinate(location)
                    annotation.title = "ДТП"
                    if let date = detailItem?.pubDate {
                        var dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "dd.MM.yyyy hh:mm:ss"
                        annotation.subtitle = dateFormatter.stringFromDate(date)
                    }
                    //annotation.subtitle = ""
                    mapView.addAnnotation(annotation)
                    mapView.hidden = false
                } else {
                    mapView.hidden = true
                }
            }
        }
    }

    func configureView() {
//        if let date = detailItem?.pubDate {
//            var dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "dd.MM.yyyy"
//            navigationItem.title = dateFormatter.stringFromDate(date)
//        }
        titleLabel?.text = detailItem?.title
        descrText?.text = detailItem?.descr
        descrText?.scrollsToTop = true
        descrText?.scrollRangeToVisible(NSMakeRange(0, 1))
        mapView?.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "web" {
            let controller = segue.destinationViewController as WebViewController
            if let link = detailItem?.link {
                controller.link = link
            }
        }
    }



}

