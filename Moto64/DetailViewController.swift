//
//  DetailViewController.swift
//  Moto64
//
//  Created by AseR on 15.03.15.
//
//

import UIKit
//import MapKit

class DetailViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descrText: UITextView!
//    @IBOutlet var mapView: MKMapView!

    var detailItem: DataFeed.Item? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        
//        let location = CLLocationCoordinate2D(
//            latitude: 51.5405600,
//            longitude: 46.0086100
//        )
//
//        let span = MKCoordinateSpanMake(0.05, 0.05)
//        let region = MKCoordinateRegion(center: location, span: span)
//        mapView.setRegion(region, animated: true)
//        
//        let annotation = MKPointAnnotation()
//        annotation.setCoordinate(location)
//        annotation.title = "Саратов"
//        //annotation.subtitle = ""
//        mapView.addAnnotation(annotation)
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

