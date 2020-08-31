//
//  PayWithFIBView.swift
//  FIB-Payment-SDK
//
//  Created by Mohamad Mareri on 30.08.20.
//  Copyright © 2020 Mohamad Mareri. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public final class PayWithFIBView: UIView {

    private let gradientBackgroundView = FIBGradientView()

    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("Pay with FIB", for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(backTapped(_:)), for: .touchUpInside)
        return button
    }()

    let image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "fib-icon", in: Bundle(for: PayWithFIBView.self), compatibleWith: nil)
        return imageView
    }()

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @objc func backTapped(_ sender: Any) {
        getToken { token in
            guard let token = token else {
                return
            }
            self.createPayment(token: token) { transactionScanCode in
                if let transactionScanCode = transactionScanCode {
                    print("ID:\(transactionScanCode.paymentId)")
                    print("Code:\(transactionScanCode.readableCode)")
                    print("T:\(transactionScanCode.personalAppLink)")
                    guard let url = URL(string: transactionScanCode.personalAppLink),
                        let identifier = self.parseURL(url: url) else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.jump(identifier: identifier, paymentId: transactionScanCode.paymentId)
                    }
                }
            }
             
        }
    }
    
    private func getToken(completion: @escaping (Token?) -> Void) {
        guard let url = URL(string: "https://keycloak.dev.azure.lawrence-spring.com/auth/realms/fib-online-shop/protocol/openid-connect/token") else {
            completion(nil)
            return
        }
        
        let body = "grant_type=client_credentials&client_id=online-shop&client_secret=0d1fff1d-3c8f-4b4f-8b9d-f138c2a23d77"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                print(error?.localizedDescription ?? "No data")
                return
            }
            let toki = try? JSONDecoder().decode(Token.self, from: data)
            completion(toki)
        }

        task.resume()
    }

    private func createPayment(token: Token, completion: @escaping (TransactionScanCode?) -> Void) {
        guard let url = URL(string: "https://fib-pay-gate.dev.azure.lawrence-spring.com/payments") else {
            return
        }
        let parameters: [String: Any] = ["accountId": "7be40aed-23df-45bf-a538-92880c50993c",
                                      "description": "some test",
                                      "monetaryValue":["amount": 255,
                                                       "currency": "IQD"]]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                print(error?.localizedDescription ?? "No data")
                return
            }
            let trans = try? JSONDecoder().decode(TransactionScanCode.self, from: data)
            completion(trans)
        }

        task.resume()
    }

    private func parseURL(url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        guard let queryItem = components.queryItems,
        let identifierUrl = queryItem.first(where: {$0.name == "link"})?.value else { return nil }
        
        guard let idURL = URL(string: identifierUrl),
            let idComponents = URLComponents(url: idURL, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        guard let idQueryItem = idComponents.queryItems,
        let identifier = idQueryItem.first(where: {$0.name == "identifier"})?.value else { return nil }
        return identifier
    }

    private func jump(identifier: String, paymentId: String) {
        //if let url = URL(string: "https://personal.dev.first-iraqi-bank.co/\(code)") {
        if let url = URL(string: "https://personal.dev.first-iraqi-bank.co/?Amount=300&Currency=IQS&Description=verwindung&Identifier=\(identifier)&PaymentId=\(paymentId)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func commonInit() {
        setupHierarchy()
        setupConstraints()
    }

    private func setupHierarchy() {
        [gradientBackgroundView, button, image].forEach { view in
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setupConstraints() {
        setupGradientConstraints()
        setupButtonConstraints()
        setupIconConstraints()
    }

    private func setupGradientConstraints() {
        NSLayoutConstraint.activate([
            gradientBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            gradientBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func setupButtonConstraints() {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func setupIconConstraints() {
        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.38),
            image.widthAnchor.constraint(equalTo: image.heightAnchor),
            image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

public struct Token: Decodable {

    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

public struct TransactionScanCode: Decodable {
    public let paymentId: String
    public let readableCode: String
    public let personalAppLink: String
    public let businessAppLink: String
}

