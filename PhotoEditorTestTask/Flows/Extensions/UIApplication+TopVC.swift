//
//  UIApplication+TopVC.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 28.04.2025.
//

import UIKit

extension UIApplication {
    func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
                                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                                .first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

// To abstract from UIKit in services
protocol PresentingControllerProvider {
    func presentingViewController() -> UIViewController
}

final class DefaultPresentingControllerProvider: PresentingControllerProvider {
    func presentingViewController() -> UIViewController {
        UIApplication.shared.topViewController() ?? UIViewController()
    }
}
