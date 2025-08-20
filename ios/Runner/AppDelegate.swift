import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  // מחזיקים רפרנס כדי שה-engine לא ייאסף ע"י ARC
  private var flutterEngine: FlutterEngine?
  private var appWindow: UIWindow?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 1) יצירת מנוע והרצה
    let engine = FlutterEngine(name: "primary_engine")
    engine.run()

    // 2) רישום פלאגינים על גבי ה-engine הזה (שימו לב: לא with: self)
    GeneratedPluginRegistrant.register(with: engine)

    // 3) חיבור ה-ViewController לאותו engine
    let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)

    // 4) חלון ושורש
    appWindow = UIWindow(frame: UIScreen.main.bounds)
    appWindow?.rootViewController = flutterVC
    appWindow?.makeKeyAndVisible()

    // לשמור רפרנס
    self.flutterEngine = engine

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
