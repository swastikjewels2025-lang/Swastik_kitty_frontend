import Flutter
import UIKit
import AuthenticationServices

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  
  private var appleAuthResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if let controller = window?.rootViewController as? FlutterViewController {
      setupAppleAuthChannel(messenger: controller.binaryMessenger)
    }
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func setupAppleAuthChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "com.swastikjewel.kitty/apple_auth", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      if call.method == "signInWithApple" {
        self.appleAuthResult = result
        self.performAppleSignIn()
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func performAppleSignIn() {
    if #available(iOS 13.0, *) {
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    } else {
      appleAuthResult?(FlutterError(code: "UNSUPPORTED", message: "Sign in with Apple requires iOS 13 or newer", details: nil))
      appleAuthResult = nil
    }
  }

  // MARK: - ASAuthorizationControllerDelegate
  @available(iOS 13.0, *)
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      let userIdentifier = appleIDCredential.user
      let identityTokenString = appleIDCredential.identityToken.flatMap { String(data: $0, encoding: .utf8) }
      let email = appleIDCredential.email
      var fullName: String? = nil
      if let nameComponents = appleIDCredential.fullName {
        let parts = [nameComponents.givenName, nameComponents.familyName].compactMap { $0 }
        if !parts.isEmpty {
          fullName = parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        }
      }

      let payload: [String: Any?] = [
        "userIdentifier": userIdentifier,
        "identityToken": identityTokenString,
        "email": email,
        "name": fullName,
      ]

      appleAuthResult?(payload)
      appleAuthResult = nil
    } else {
      appleAuthResult?(FlutterError(code: "INVALID_CREDENTIAL", message: "Failed to parse Apple ID credential", details: nil))
      appleAuthResult = nil
    }
  }

  @available(iOS 13.0, *)
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    appleAuthResult?(FlutterError(code: "CANCELLED_OR_ERROR", message: error.localizedDescription, details: nil))
    appleAuthResult = nil
  }

  // MARK: - ASAuthorizationControllerPresentationContextProviding
  @available(iOS 13.0, *)
  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.window ?? UIApplication.shared.windows.first ?? ASPresentationAnchor()
  }
}
