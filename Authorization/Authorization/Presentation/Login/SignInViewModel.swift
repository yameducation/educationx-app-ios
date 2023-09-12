//
//  SignInViewModel.swift
//  Authorization
//
//  Created by Vladimir Chekyrta on 14.09.2022.
//

import Foundation
import Core
import SwiftUI
import Alamofire
import OAuthSwift
import SafariServices

private class WebLoginSafariDelegate: NSObject, SFSafariViewControllerDelegate {
    private let viewModel: SignInViewModel
    public init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        /* Called when the 'Done' button is hit on the Safari Web view. In this case,
        authentication would neither have failed nor succeeded, but we'd be back
        at the SignInView. So, we make sure we mark it as attempted so the UI
        renders. */
        self.viewModel.markAttempted()
    }
}

public class SignInViewModel: ObservableObject {
    
    @Published private(set) var isShowProgress = false
    @Published private(set) var showError: Bool = false
    @Published private(set) var showAlert: Bool = false
    @Published private(set) var webLoginAttempted: Bool = false
    
    var forceWebLogin: Bool {
        return config.webLogin && !webLoginAttempted
    }
    var errorMessage: String? {
        didSet {
            withAnimation {
                showError = errorMessage != nil
            }
        }
    }
    var alertMessage: String? {
        didSet {
            withAnimation {
                showAlert = alertMessage != nil
            }
        }
    }
    var oauthswift: OAuth2Swift?
    
    private let interactor: AuthInteractorProtocol
    let router: AuthorizationRouter
    let config: Config
    let analytics: AuthorizationAnalytics
    private let validator: Validator
    private var safariDelegate: WebLoginSafariDelegate?
    
    public init(interactor: AuthInteractorProtocol,
                router: AuthorizationRouter,
                analytics: AuthorizationAnalytics,
                config: Config,
                validator: Validator) {
        self.interactor = interactor
        self.router = router
        self.analytics = analytics
        self.config = config
        self.validator = validator
        self.webLoginAttempted = false
    }
    
    @MainActor
    func login(viewController: UIViewController) async {
        /* OAuth web login. Used when we cannot use the built-in login form,
        but need to let the LMS redirect us to the authentication provider.
        
        An example service where this is needed is something like Auth0, which
        redirects from the LMS to its own login page. That login page then redirects
        back to the LMS for the issuance of a token that can be used for making
        requests to the LMS, and then back to the redirect URL for the app. */
        self.safariDelegate = WebLoginSafariDelegate(viewModel: self)
        oauthswift = OAuth2Swift(
            consumerKey: config.oAuthClientId,
            consumerSecret: "", // No secret required
            authorizeUrl: "\(config.baseURL)/oauth2/authorize/",
            accessTokenUrl: "\(config.baseURL)/oauth2/access_token/",
            responseType: "code"
        )
        
        oauthswift!.allowMissingStateCheck = true
        let handler = SafariURLHandler(
            viewController: viewController, oauthSwift: oauthswift!
        )
        handler.delegate = self.safariDelegate
        oauthswift!.authorizeURLHandler = handler

        // Trigger OAuth2 dance
        guard let rwURL = URL(string: "\(Bundle.main.bundleIdentifier ?? "")://oauth2Callback") else { return }
        oauthswift!.authorize(withCallbackURL: rwURL, scope: "", state: "") { result in
            switch result {
            case .success(let (credential, _, _)):
                Task {
                    self.webLoginAttempted = true
                    let user = try await self.interactor.login(credential: credential)
                    self.analytics.setUserID("\(user.id)")
                    self.analytics.userLogin(method: .oauth2)
                    self.router.showMainScreen()
                }
                // Do your request
            case .failure(let error):
                self.webLoginAttempted = true
                self.isShowProgress = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    public func markAttempted() {
        // Hack to get around published observables limitation when handing this model over
        // to an outside object. Is there a better way to do this?
        self.webLoginAttempted = true
    }
     
    @MainActor
    func login(username: String, password: String) async {
        guard validator.isValidEmail(username) else {
            errorMessage = AuthLocalization.Error.invalidEmailAddress
            return
        }
        guard validator.isValidPassword(password) else {
            errorMessage = AuthLocalization.Error.invalidPasswordLenght
            return
        }
        
        isShowProgress = true
        do {
            let user = try await interactor.login(username: username, password: password)
            analytics.setUserID("\(user.id)")
            analytics.userLogin(method: .password)
            router.showMainScreen()
        } catch let error {
            isShowProgress = false
            if let validationError = error.validationError,
               let value = validationError.data?["error_description"] as? String {
                errorMessage = value
            } else if case APIError.invalidGrant = error {
                errorMessage = CoreLocalization.Error.invalidCredentials
            } else if error.isInternetError {
                errorMessage = CoreLocalization.Error.slowOrNoInternetConnection
            } else {
                errorMessage = CoreLocalization.Error.unknownError
            }
        }
    }
}
