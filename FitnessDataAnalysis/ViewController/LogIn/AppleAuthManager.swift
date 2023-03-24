//
//  AppleAuthManager.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/9.
//
//https://blog.devgenius.io/make-signing-in-easy-simply-sign-in-with-apple-9f348a7c69e9

import Foundation
import AuthenticationServices

@available(iOS 13.0, *)
class AppleAuthManager: NSObject {
    
    let authorizationButton = ASAuthorizationAppleIDButton()
    
    override init() {
        super.init()
        self.authorizationButton.cornerRadius = 15
        self.authorizationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setAuthButtonTarget(viewController: UIViewController) {
        authorizationButton.addTarget(viewController, action: #selector(handleAppleIdRequest), for: .touchUpInside)
    }
    
    
    @objc
    func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func getCredentialState(for userId: String) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userId) {  (credentialState, error) in
             switch credentialState {
                case .authorized:
                    // The Apple ID credential is valid.
                    break
                case .revoked:
                    // The Apple ID credential is revoked.
                    break
                case .notFound:
                    // No credential was found, so show the sign-in UI.
                 break
                default:
                    break
             }
        }
    }
    
}

@available(iOS 13.0, *)
extension AppleAuthManager: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
          
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
//            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
            getCredentialState(for: userIdentifier)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {

    }
}

