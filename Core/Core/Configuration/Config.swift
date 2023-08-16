//
//  Config.swift
//  Core
//
//  Created by Vladimir Chekyrta on 14.09.2022.
//

import Foundation

public class Config {
    
    public let baseURL: URL
    public let oAuthClientId: String
    public let webLogin: Bool
    
    public lazy var termsOfUse: URL? = {
        URL(string: "https://www.yam-edu.com/termofservice")
    }()
    
    public lazy var privacyPolicy: URL? = {
        URL(string: "https://www.yam-edu.com/privacy")
    }()
    
    public let feedbackEmail = "contact@yam-edu.com"
    
    public init(baseURL: String, oAuthClientId: String, webLogin: Bool) {
        guard let url = URL(string: baseURL) else {
            fatalError("Ivalid baseURL")
        }
        self.baseURL = url
        self.oAuthClientId = oAuthClientId
        self.webLogin = webLogin
    }
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public class ConfigMock: Config {
    public convenience init() {
        self.init(baseURL: "https://google.com/", oAuthClientId: "client_id", webLogin: false)
    }
}
#endif
