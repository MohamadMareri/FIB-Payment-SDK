import Foundation

public struct FIBAppConfiguration: Decodable {
    public let baseURLs: FIBAppConfiguration.FIBBackendBaseURLs
    public let grantType: String
    public let clientId: String
    public let clientSecret: String
    public let accountId: String
}

extension FIBAppConfiguration {
    public struct FIBBackendBaseURLs: Decodable, FIBBackendBaseURLsRepresentable {
        public let fibPayGate: String
        public let keycloak: String

        public var fibPayGateURL: URL {
            URL(string: fibPayGate)
        }

        public var keycloakURL: URL {
            URL(string: keycloak)
        }
    }
}

extension FIBAppConfiguration {
    public init(fromPropertyList fileName: String = "FIBConfiguration",
                inBundle bundle: Bundle = Bundle.main) {
        guard let url = bundle.url(forResource: fileName, withExtension: "plist") else {
            fatalError("Url for Property list file \(fileName).plist could not be created.")
        }

        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
            fatalError("Property list file \(url) could not be read.")
        }

        do {
            self = try PropertyListDecoder().decode(FIBAppConfiguration.self, from: data)
        } catch {
            fatalError("Unexpected error occured when reading property list from \(url): \(error)")
        }
    }
}

public protocol FIBBackendBaseURLsRepresentable {
    var fibPayGateURL: URL { get }
    var keycloakURL: URL { get }
}

public extension URL {
    init(string: String) {
        guard let url = URL(string: string) else {
            fatalError("Can't create URL from: \(string)")
        }
        self = url
    }
}
