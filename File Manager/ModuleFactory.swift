import Foundation
import UIKit

enum ModuleType {
    case main, loginFirst, settings, loginSecond
}

class ModuleFactory {

    var coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    func makeModule(type: ModuleType) -> UINavigationController {
        switch type {
        case .main:
            let vc = MainViewController(coordinator: coordinator)
            vc.tabBarItem = UITabBarItem(title: "Files", image: UIImage(systemName: "folder") , tag: 0)
            vc.navigationController?.setNavigationBarHidden(true, animated: false)
            let rootVC = UINavigationController(rootViewController: vc)
            return rootVC
        case .loginFirst:
            return UINavigationController(rootViewController: LoginViewController(coordinator: coordinator, type: .first))
        case .settings:
            let vc = SettingsViewController(coordinator: coordinator)
            vc.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape") , tag: 1)
            vc.navigationController?.setNavigationBarHidden(true, animated: false)
            let rootVC = UINavigationController(rootViewController: vc)
            return rootVC
        case .loginSecond:
            return UINavigationController(rootViewController: LoginViewController(coordinator: coordinator, type: .second))
        }
    }
}
