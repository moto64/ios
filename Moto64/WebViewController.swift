//
//  WebViewController.swift
//  Moto64
//
//  Created by AseR on 19.03.15.
//
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate
{

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var webView: UIWebView!
    
    // default link
    var link = "http://motosaratov.ru/forum24.html"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.delegate = self
        webView.scalesPageToFit = true
        webView.scrollView.scrollEnabled = true
        
        if let url = NSURL(string: link) {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView)
    {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
        activityIndicator.stopAnimating()
    }

}
