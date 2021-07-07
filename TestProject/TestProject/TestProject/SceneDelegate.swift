//
//  SceneDelegate.swift
//  TestProject
//
//  Created by Vyacheslav Khorkov on 21.03.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}
