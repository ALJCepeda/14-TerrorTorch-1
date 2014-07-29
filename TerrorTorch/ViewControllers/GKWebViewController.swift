//
//  GKWebViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 7/14/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit

class GKWebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    @IBOutlet var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self;
        let url = NSURL(string: "http://www.goldenviking.org/");
        webView.loadRequest(NSURLRequest(URL:url));
    }
    @IBAction func exitPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(false, completion: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        backButton.enabled = webView.canGoBack;
    }
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
