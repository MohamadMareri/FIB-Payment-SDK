import Foundation

extension PayWithFIBView {
    func getToken(completion: @escaping (Token?) -> Void) {
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

    func createPayment(token: Token, completion: @escaping (TransactionCode?) -> Void) {
        guard let message = message,
            let amount = amount,
            let currency = currency else {
                print("FIB-Payment_SDK Error: missing params")
                return
        }
        let parameters: [String: Any] = ["accountId": appConfiguration.accountId,
                                      "description": message,
                                      "monetaryValue":["amount": amount,
                                                       "currency": currency]]
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
}
