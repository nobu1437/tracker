//
//  SceneDelegate.swift
//  tracker
//
//  Created by Andrey Nobu on 25.05.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let isNotFirstLaunch = UserDefaults.standard.bool(forKey: "isNotFirstLauch")
        if isNotFirstLaunch {
            let tabBar = UITabBarController()
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = .ypWhite
            if #available(iOS 15.0, *) {
                tabBar.tabBar.scrollEdgeAppearance = appearance
            }
            tabBar.tabBar.standardAppearance = appearance
            let navAppearance = UINavigationBarAppearance()
            navAppearance.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 16,weight: .medium),
                .foregroundColor: UIColor(resource: .ypBlack)]
            navAppearance.shadowColor = .clear
            navAppearance.backgroundColor = .ypWhite
            
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
            let statisticVC = StatisticListViewController()
            let statisticNavVC = UINavigationController(rootViewController: statisticVC)
            statisticNavVC.tabBarItem = UITabBarItem(title: NSLocalizedString("tabbar.statistics.title", comment: ""),
                                                  image: UIImage(systemName:
                                                                    "hare.fill"),
                                                  tag: 0)
            let trackerVC = TrackerListViewController()
            let trackerNavVC = UINavigationController(rootViewController: trackerVC)
            trackerNavVC.tabBarItem = UITabBarItem(title: NSLocalizedString("tabbar.trackers.title", comment: ""),
                                                image: UIImage(systemName:
                                                                "record.circle.fill"),
                                                tag: 1)
            tabBar.setViewControllers([trackerNavVC,statisticNavVC], animated: true)
            window?.rootViewController = tabBar
        } else {
            window?.rootViewController = PageViewController()
        }
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
