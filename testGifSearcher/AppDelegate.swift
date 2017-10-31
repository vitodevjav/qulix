import UIKit
import UserNotifications
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "GifSearcherDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
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
        guard let navigation = window?.rootViewController! as? UINavigationController else {
            return
        }
        if navigation.viewControllers.count > 1 {
            navigation.popViewController(animated: false)
        }
        navigation.pushViewController(GifViewController(gif: gif), animated: false)
    }
}

