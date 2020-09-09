import Foundation
import UIKit

@IBDesignable
public final class PayWithFIBView: UIView {

    private var amount: String!
    private var currency: String!
    private var message: String!
    private let gradientBackgroundView = FIBGradientView()
    private let appConfiguration = FIBAppConfiguration()

    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("Pay with FIB", for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(payTapped(_:)), for: .touchUpInside)
        return button
    }()

    let image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "fib-icon", in: Bundle(for: PayWithFIBView.self), compatibleWith: nil)
        return imageView
    }()

    public convenience init(amount: String, currency: String, message: String) {
        self.init(frame: CGRect.zero)
        self.amount = amount
        self.currency = currency
        self.message = message
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @objc func payTapped(_ sender: Any) {
        getToken { token in
            guard let token = token else {
                return
            }
            self.createPayment(token: token) { transactionCode in
                guard let transactionCode = transactionCode else {
                    return
                }
                
                print("*** ID:\(transactionCode.paymentId)")
                print("*** Code:\(transactionCode.readableCode)")
                print("*** P:\(transactionCode.personalAppLink)")
                print("*** B:\(transactionCode.businessAppLink)")
                DispatchQueue.main.async {
                    self.prepareAppDialog(transactionCode: transactionCode)
                }
            }
        }
    }
    
    private func getToken(completion: @escaping (Token?) -> Void) {
        
        let grantType = "grant_type=\(appConfiguration.grantType)"
        let clientId = "client_id=\(appConfiguration.clientId)"
        let clientSecret = "client_secret=\(appConfiguration.clientSecret)"
        let body = "\(grantType)&\(clientId)&\(clientSecret)"
        var request = URLRequest(url: appConfiguration.baseURLs.keycloakURL)

        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                print(error?.localizedDescription ?? "No data")
                return
            }
            let token = try? JSONDecoder().decode(Token.self, from: data)
            completion(token)
        }

        task.resume()
    }

    private func createPayment(token: Token,
                               completion: @escaping (TransactionCode?) -> Void) {
        
        let parameters: [String: Any] = ["accountId": appConfiguration.accountId,
                                      "description": "some test",
                                      "monetaryValue":["amount": 255,
                                                       "currency": "IQD"]]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        
        var request = URLRequest(url: appConfiguration.baseURLs.fibPayGateURL)
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
            let transactionCode = try? JSONDecoder().decode(TransactionCode.self, from: data)
            completion(transactionCode)
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

    private func prepareAppDialog(transactionCode: TransactionCode) {
        guard let identifierUrl = URL(string: transactionCode.personalAppLink),
            let identifier = self.parseURL(url: identifierUrl),
            let personalAppUrl = URL(string: transactionCode.personalAppLink),
            let businessAppUrl = URL(string: transactionCode.businessAppLink),
            let personalAppScheme = personalAppUrl.scheme,
            let businessAppScheme = businessAppUrl.scheme,
            let personalAppHost = personalAppUrl.host,
            let businessAppHost = businessAppUrl.host else {
                print("Error while parsing FIB urls")
                return
        }

        let personalAppLink = personalAppScheme+"://"+personalAppHost+"/"
        let businessAppLink = businessAppScheme+"://"+businessAppHost+"/"
        
        var installedFIBApp: [FIBApp] = []
        if UIApplication.shared.canOpenURL(URL(string: personalAppLink)) {
            installedFIBApp.append(.personal)
        }
        if UIApplication.shared.canOpenURL(URL(string: businessAppLink)) {
            installedFIBApp.append(.business)
        }
        if installedFIBApp.count == 2 {
            showAlert(personalAppHost: personalAppLink,
                      businessAppHost: businessAppLink,
                      identifier: identifier,
                      paymentId: transactionCode.paymentId)
        }
        
    }

    private func openFIBApp(appLink: String, identifier: String, paymentId: String) {
        if let url = URL(string:prepareDeepLink(appLink: appLink, identifier: identifier, paymentId: paymentId)) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func prepareDeepLink(appLink: String, identifier: String, paymentId: String) -> String {
        guard let amount = amount,
            let currency = currency,
            let message = message else {
                fatalError("FIB params missing")
        }
        return appLink +
        "?Identifier=\(identifier)"
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

private struct Token: Decodable {

    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

private struct TransactionCode: Decodable {
    public let paymentId: String
    public let readableCode: String
    public let personalAppLink: String
    public let businessAppLink: String
}

extension PayWithFIBView {
    private enum FIBApp {
        case personal
        case business
    }
    
    private func showAlert(personalAppHost: String, businessAppHost: String, identifier: String, paymentId: String) {
        
        let fibAppsAlert = UIAlertController(title: "Please choose the app to complete the transaction",
                                             message: "",
                                             preferredStyle: UIAlertController.Style.actionSheet)

        let personalAppAction = UIAlertAction(title: "FIB Personal App", style: .default) { (action: UIAlertAction) in
            self.openFIBApp(appLink: personalAppHost, identifier: identifier, paymentId: paymentId)
        }
        
        let businessAppAction = UIAlertAction(title: "FIB Business App", style: .default) { (action: UIAlertAction) in
            self.openFIBApp(appLink: businessAppHost, identifier: identifier, paymentId: paymentId)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        fibAppsAlert.addAction(personalAppAction)
        fibAppsAlert.addAction(businessAppAction)
        fibAppsAlert.addAction(cancelAction)
        DispatchQueue.main.async {
            self.window?.rootViewController?.present(fibAppsAlert, animated: true, completion: nil)
        }
    }
}

