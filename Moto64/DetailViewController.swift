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
    @IBOutlet var showMapButton: UIButton!
    
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
                    showMapButton.hidden = false
                } else {
                    showMapButton.hidden = true
                }
            }
        }
    }

    @IBAction func showMap() {
        let mapViewController = MapViewController()
        mapViewController.detailItem = self.detailItem
        mapViewController.modalTransitionStyle = .PartialCurl
        mapViewController.modalPresentationStyle = .FullScreen
        self.presentViewController(mapViewController, animated: true, completion: nil)
    }
    
    func configureView() {
        titleLabel?.text = detailItem?.title
        descrText?.text = detailItem?.descr
        descrText?.scrollsToTop = true
        descrText?.scrollRangeToVisible(NSMakeRange(0, 1))
        showMapButton?.hidden = true
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

