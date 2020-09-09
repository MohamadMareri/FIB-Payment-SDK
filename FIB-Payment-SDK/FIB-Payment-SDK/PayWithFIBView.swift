import Foundation
import UIKit

@IBDesignable
public final class PayWithFIBView: UIView {

    var amount: Int!
    var currency: String!
    var message: String!
    private let gradientBackgroundView = FIBGradientView()
    let appConfiguration = FIBAppConfiguration()

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

    public convenience init(amount: Int, currency: String, message: String) {
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
                      identifier: identifier)
        }
        
    }

    private func openFIBApp(appLink: String, identifier: String) {
        if let url = URL(string:prepareDeepLink(appLink: appLink, identifier: identifier)) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func prepareDeepLink(appLink: String, identifier: String) -> String {
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

extension PayWithFIBView {
    private enum FIBApp {
        case personal
        case business
    }
    
    private func showAlert(personalAppHost: String, businessAppHost: String, identifier: String) {
        
        let fibAppsAlert = UIAlertController(title: "Please choose the app to complete the transaction",
                                             message: "",
                                             preferredStyle: UIAlertController.Style.actionSheet)

        let personalAppAction = UIAlertAction(title: "FIB Personal App", style: .default) { (action: UIAlertAction) in
            self.openFIBApp(appLink: personalAppHost, identifier: identifier)
        }
        
        let businessAppAction = UIAlertAction(title: "FIB Business App", style: .default) { (action: UIAlertAction) in
            self.openFIBApp(appLink: businessAppHost, identifier: identifier)
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

