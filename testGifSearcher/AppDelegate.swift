import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        } else {
            // Fallback on earlier versions
        }
        application.registerForRemoteNotifications()
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainController = TrendedGifsViewController()
        let navigationController = UINavigationController(rootViewController: mainController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        debugPrint(token)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        guard let image = data["image"] as? [String: Any] else {
            return
        }
        guard let gif = GiphyService().parseNotificationMessageToGif(json: image) else {
            return
        }
        (window?.rootViewController! as! UINavigationController).pushViewController(GifViewController(gif: gif), animated: true)
    }
}

