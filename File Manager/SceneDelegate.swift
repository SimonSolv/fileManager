import UIKit
import KeychainAccess

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let keychain = Keychain(service: "com.filemanager.app")
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let coordinator = AppCoordinator()
        let factory = ModuleFactory(coordinator: coordinator)
        coordinator.factory = factory
        window = UIWindow(windowScene: scene)
        window?.makeKeyAndVisible()
        let password = keychain["password"]
        if password != nil {
            window?.rootViewController = coordinator.presentLogin(type: .second)
        } else {
            window?.rootViewController = coordinator.presentLogin(type: .first)
        }
    }

}

