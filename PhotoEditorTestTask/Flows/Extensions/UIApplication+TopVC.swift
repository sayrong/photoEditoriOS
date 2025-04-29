//
//  UIApplication+TopVC.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 28.04.2025.
//

import UIKit

extension UIApplication {
    
    func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseVC = base ?? UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        
        if let nav = baseVC as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = baseVC as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = baseVC?.presentedViewController {
            return topViewController(base: presented)
        }
        return baseVC
    }
}

// To abstract from UIKit in services
protocol PresentingControllerProvider {
    func presentingViewController() -> UIViewController
}

final class DefaultPresentingControllerProvider: PresentingControllerProvider {
    func presentingViewController() -> UIViewController {
        guard let vc = UIApplication.shared.topViewController() else {
            assertionFailure("No topViewController found. This should not happen.")
            return UIViewController()
        }
        return vc
    }
}
