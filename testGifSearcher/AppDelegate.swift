import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.setValue(true, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainController = TrendedGifsViewController()
        let navigationController = UINavigationController(rootViewController: mainController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}

