//
//  WebController.swift
//  flipmap_ios
//
//  Created by liqc on 2018/04/09.
//

import SVProgressHUD
import UIKit
import WebKit

protocol WebDelegate {
    func didFinish(_ webView: WebController)
}

final class WebController: UIViewController {
	private(set) lazy var webView: WKWebView = {
		let view = WKWebView(frame: UIScreen.main.bounds)
		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.navigationDelegate = self
		return view
	}()

    // params.
    var url: String?

    // for report.
    var flipID: String?
    var delegate: WebDelegate?

	override func loadView() {
		view = webView
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        setWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }

    @IBAction func doClose() {
        appDelegate?.transitionDelegate?.viewController(self, needsTransitionWith: nil)
    }

    fileprivate func setWebView() {

        if let url = url, let webURL = URL(string: url) {
            let request = URLRequest(url: webURL)
            webView.load(request)
        }
    }

    fileprivate func startLoading() {
        SVProgressHUD.show()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    fileprivate func endLoading() {
        SVProgressHUD.dismiss()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension WebController: WKNavigationDelegate {
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        startLoading()
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        endLoading()
        delegate?.didFinish(self)
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError error: Error) {
        endLoading()
        // TODO: 警告が出る
//        super.showErrorAlert(title: nil, message: error.localizedDescription)
    }

    func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError error: Error) {
        endLoading()
        // TODO: 警告が出る
//        super.showErrorAlert(title: nil, message: error.localizedDescription)
    }

    func webView(_: WKWebView, decidePolicyFor _: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
