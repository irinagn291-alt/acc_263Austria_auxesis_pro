import AuxRingKit
import UIKit

/// Role: owns the one window. Canvas stays the root after launch.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.tintColor = AuxColor.accent
        window.backgroundColor = AuxColor.background
        window.rootViewController = LaunchViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
