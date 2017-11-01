import UIKit
import UserNotifications
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var coreDataStack = CoreDataStack(modelName: "GifSearcherDataModel")
    lazy var service = GiphyService(managedContext: coreDataStack.managedContext)

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        application.registerForRemoteNotifications()
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainController = TrendedGifsViewController()
        mainController.managedContext = coreDataStack.managedContext
        mainController.giphyService = service
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
        guard let json = data as? [String: Any],
            let gif = service.parseJsonToGifArray(json),
            let navigation = window?.rootViewController! as? UINavigationController else {
                return
        }
        if navigation.viewControllers.count > 1 {
            navigation.popViewController(animated: false)
        }
        navigation.pushViewController(GifViewController(gif: gif.first!), animated: false)
    }
}

