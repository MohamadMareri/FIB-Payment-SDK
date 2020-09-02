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
        
        let aaa = PayWithFIBView(amount: "299", currency: "IQS", message: "message")
        view.addSubview(aaa)
        aaa.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aaa.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            aaa.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            aaa.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            aaa.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            aaa.heightAnchor.constraint(equalToConstant: 64)
        ])
    }


}

