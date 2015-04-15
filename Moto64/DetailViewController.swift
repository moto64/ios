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
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
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
                    
//                    let height: CGFloat = 224
//                    let mapFrame = CGRect(x: 8, y: self.view.frame.size.height - height - 8, width: self.view.frame.size.width - 16, height: height)
//                    let myMapView = MKMapView(frame: mapFrame)
                    
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
                    
//                    descrText.frame.size.height = descrText.frame.size.height - height - 8
//                    descrText.hidden = true
//                    
//                    let origin = CGPoint(x: titleLabel.frame.origin.x, y: titleLabel.frame.origin.y + titleLabel.frame.size.height + 8)
//                    let size = CGSize(width: self.view.frame.size.width - 2 * origin.x, height: self.view.frame.size.height - origin.y - 8 - myMapView.frame.size.height - 8)
//                    
//                    let textFrame = CGRect(origin: origin, size: size)
//                    let myDescrText = UITextView(frame: textFrame)
//                    myDescrText.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
//                    myDescrText.editable = false
//                    myDescrText.selectable = true
//                    let detectorTypes: UIDataDetectorTypes = .PhoneNumber | .Link | .Address
//                    myDescrText.dataDetectorTypes = detectorTypes
//                    myDescrText.text = detailItem?.descr
//                    
//                    self.view.addSubview(myDescrText)
//                    self.view.addSubview(myMapView)
                    
                    mapView.hidden = false
                } else {
                    mapView.hidden = true
                    
//                    descrText.hidden = true
//                    
//                    let origin = CGPoint(x: titleLabel.frame.origin.x, y: titleLabel.frame.origin.y + titleLabel.frame.size.height + 8)
//                    let size = CGSize(width: self.view.frame.size.width - 2 * origin.x, height: self.view.frame.size.height - origin.y - 8)
//
//                    let textFrame = CGRect(origin: origin, size: size)
//                    let myDescrText = UITextView(frame: textFrame)
//                    myDescrText.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
//                    myDescrText.editable = false
//                    myDescrText.selectable = true
//                    let detectorTypes: UIDataDetectorTypes = .PhoneNumber | .Link | .Address
//                    myDescrText.dataDetectorTypes = detectorTypes
//                    myDescrText.text = detailItem?.descr
//                    
//                    self.view.addSubview(myDescrText)

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
            let controller = segue.destinationViewController as! WebViewController
            if let link = detailItem?.link {
                controller.link = link
            }
        }
    }



}

