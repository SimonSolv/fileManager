import Foundation
import UIKit

class AppCoordinator {
    
    var factory: ModuleFactory?
    
    var coordinatingControllers: [UINavigationController] = []
    
    func presentMain() -> UINavigationController {
        let controller = factory?.makeModule(type: .main)
        guard let controller else {
            return UINavigationController()
        }
        coordinatingControllers.append(controller)
        return controller
    }
    
    func presentLogin(type: LoginType) -> UINavigationController {

        switch type {
        case .first:
            let controller = factory?.makeModule(type: .loginFirst)
            guard let controller else {
                return UINavigationController()
            }
            coordinatingControllers.append(controller)
            return controller
        case .second:
            let controller = factory?.makeModule(type: .loginSecond)
            guard let controller else {
                return UINavigationController()
            }
            coordinatingControllers.append(controller)
            return controller
        case .changePasword:
            let controller = factory?.makeModule(type: .loginFirst)
            guard let controller else {
                return UINavigationController()
            }
            coordinatingControllers.append(controller)
            return controller
        }

    }
    
    func presentSettings() -> UINavigationController {
        let controller = factory?.makeModule(type: .settings)
        guard let controller else {
            return UINavigationController()
        }
        coordinatingControllers.append(controller)
        return controller
    }
    
    func presentTabBarController(iniciator: UIViewController) {
        let controller = UITabBarController()
        controller.viewControllers = [presentMain(), presentSettings()]
        controller.navigationItem.setHidesBackButton(true, animated: true)
        controller.tabBar.layer.backgroundColor = UIColor.tertiarySystemFill.cgColor
        coordinatingControllers[0].pushViewController(controller, animated: true)
    }
}

protocol CoordinatedProtocol {
    var coordinator: AppCoordinator { get set }
}
