//
//  ViewController.swift
//  Sample
//
//  Created by Mohamad Mareri on 30.08.20.
//  Copyright © 2020 Mohamad Mareri. All rights reserved.
//

import UIKit
import FIB_Payment_SDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fibView = PayWithFIBView(amount: 301, currency: "IQD", message: "I am SDK")
        view.addSubview(fibView)
        fibView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fibView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            fibView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fibView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            fibView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            fibView.heightAnchor.constraint(equalToConstant: 64)
        ])
    }


}

