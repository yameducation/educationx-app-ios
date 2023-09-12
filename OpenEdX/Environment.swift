//
//  Environment.swift
//  OpenEdX
//
//  Created by Vladimir Chekyrta on 14.09.2022.
//

import Foundation
import Core
import FirebaseCore

enum `Environment`: String {
    case debugDev = "DebugDev"
    case releaseDev = "ReleaseDev"
    
    case debugStage = "DebugStage"
    case releaseStage = "ReleaseStage"
    
    case debugProd = "DebugProd"
    case releaseProd = "ReleaseProd"
}

class BuildConfiguration {
    static let shared = BuildConfiguration()
    
    var environment: Environment
    
    var baseURL: String {
        switch environment {
        case .debugDev, .releaseDev:
            return "https://edxdev.yam-edu.com"
        case .debugStage, .releaseStage:
            return "https://edxdev.yam-edu.com"
        case .debugProd, .releaseProd:
            return "https://courses.yam-edu.com"
        }
    }
    
    var clientId: String {
        switch environment {
        case .debugDev, .releaseDev:
            return "g7H79XL9yCCKKha70vcLE5dKJCTyYuKthk9OPtwl"
        case .debugStage, .releaseStage:
            return "g7H79XL9yCCKKha70vcLE5dKJCTyYuKthk9OPtwl"
        case .debugProd, .releaseProd:
            return "giEfkU5XH6o7QOGaocL7b1X4LyX2rYi7wrEwpYG6"
        }
    }

    /* Set this to true if you are using an authentication provider that
    requires your learners to visit their login page. In this case,
    the existing app interface for login will be ignored, and the
    learner will be directed to a web view bringing up the LMS's login
    flow, redirecting to your provider as needed.
    
    Note that in order for this to work, you must add a redirect URL in
    your OAuth2 app settings that matches the URI
    com.bundle.app://oauth2Callback where com.bundle.app is your app
    bundle name. You must also set your Django settings in Open edX to
    allow for your bundle name as a protocol for redirects. This setting
    can be found within the OAUTH2_PROVIDER dictionary in your settings.
    The key, ALLOWED_REDIRECT_URI_SCHEMES, should be set to something
    like ['https', 'com.bundle.app'], again, where com.bundle.app is the
    bundle name for your app. */
    var webLogin: Bool = true
    
    var firebaseOptions: FirebaseOptions {
        switch environment {
        case .debugDev, .releaseDev:
            let firebaseOptions = FirebaseOptions(googleAppID: "",
                                                  gcmSenderID: "")
            firebaseOptions.apiKey = ""
            firebaseOptions.projectID = ""
            firebaseOptions.bundleID = ""
            firebaseOptions.clientID = ""
            firebaseOptions.storageBucket = ""
            
            return firebaseOptions
        case .debugStage, .releaseStage:
            let firebaseOptions = FirebaseOptions(googleAppID: "",
                                                  gcmSenderID: "")
            firebaseOptions.apiKey = ""
            firebaseOptions.projectID = ""
            firebaseOptions.bundleID = ""
            firebaseOptions.clientID = ""
            firebaseOptions.storageBucket = ""
            
            return firebaseOptions
        case .debugProd, .releaseProd:
            let firebaseOptions = FirebaseOptions(googleAppID: "",
                                                  gcmSenderID: "")
            firebaseOptions.apiKey = ""
            firebaseOptions.projectID = ""
            firebaseOptions.bundleID = ""
            firebaseOptions.clientID = ""
            firebaseOptions.storageBucket = ""
            
            return firebaseOptions
        }
    }
    
    init() {
        let currentConfiguration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as! String
        environment = Environment(rawValue: currentConfiguration)!
    }
}
