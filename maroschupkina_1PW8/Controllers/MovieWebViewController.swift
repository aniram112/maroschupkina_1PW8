//
//  MovieWebViewController.swift
//  maroschupkina_1PW8
//
//  Created by Marina Roshchupkina on 21.03.2022.
//

import Foundation
import WebKit
class MovieWebViewController: UIViewController, WKNavigationDelegate{
    var page = WKWebView()

    var url: URL?

    override func viewDidLoad() {
        page.load(URLRequest(url: url!))
        view.addSubview(page)
        page.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            page.topAnchor.constraint(equalTo: view.topAnchor),
            page.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            page.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            page.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
