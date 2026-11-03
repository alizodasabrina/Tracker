//
//  UIWindow+MainScreen.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 03/11/26.
//

import UIKit

extension UIWindow {
    func showMainScreen() {
        rootViewController = TabBarController()
    }
}
