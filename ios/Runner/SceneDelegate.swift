import UIKit
import Flutter

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    if window == nil { window = UIWindow(windowScene: windowScene) }
    // משתמש ב-root שכבר נוצר ע"י AppDelegate של Flutter
    window?.rootViewController = UIApplication.shared.delegate?.window??.rootViewController
    window?.makeKeyAndVisible()
  }
}
