//
//  TestWeb.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/9.
//

import UIKit
import WebKit

class TestWeb: UIViewController, WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!
    
    
    
    override func viewDidLoad() {
//        var webView: WKWebView!
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webView.navigationDelegate = self
//        self.webView = webView
        let url = URL(string: "https://runningfieldstoday.com/%e9%9a%90%e7%a7%81%e6%94%bf%e7%ad%96/")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
