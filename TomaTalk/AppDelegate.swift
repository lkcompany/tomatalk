//
//  AppDelegate.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 6/18/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    // setup plist to get location working
    // NSLocationWhenInUseUsageDescription = your text    
    var locationManager: CLLocationManager?
    var coordinate: CLLocationCoordinate2D?
    
    let APP_ID = "54E0E55B-A959-17EC-FF42-C980BDDC2700"
    let SECRET_KEY = "8C2B6CDF-B03C-6F1B-FFC9-94650CC6B600"
    let VERSION_NUM = "v1"
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        
        // Override point for customization after application launch.
        backendless?.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        
        FIRDatabase.database().persistenceEnabled = true
        
        // If you plan to use Backendless Media Service, uncomment the following line (iOS ONLY!)
        backendless?.mediaService = MediaService()
        
        // facebook SDK
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        startLocationManager()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        startLocationManager()
    }
    
    // MARK: LocationManager functions
    func startLocationManager() {
        
        if locationManager == nil {
            print("init locationManager")
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
        
        print("have location manager")
        locationManager!.startUpdatingLocation()
    }
    
    func stopLocationManager() {
        locationManager!.stopUpdatingLocation()
    }
    
    // MARK: CLLocationManager Delegate
    /*
    func locationManager(_ manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        coordinate = newLocation.coordinate
    }*/
    
    // MARK: Facebook login
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let result = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        if result {
            
            let token = FBSDKAccessToken.current()
            let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "email"], tokenString: token?.tokenString, version: nil, httpMethod: "GET")
            /*request?.start(completionHandler: { (connection, result, error: NSError!) in
                
                if error == nil {
                    let facebookId = result["id"]! as! String
                    let avatarUrl = "https://graph.facebook.com/\(facebookId)/picture?type=normal"
                    
                    updateBackendlessUser(facebookId, avatarUrl: avatarUrl)
                } else {
                    print("Facebook request error \(error)")
                }
            })*/
            
            request?.start(completionHandler: { (connection, result, error) in
                
                if error == nil {
                    let item = result as! [String:AnyObject]
                    let facebookId = item["id"]! as! String
                    let avatarUrl = "https://graph.facebook.com/\(facebookId)/picture?type=normal"
                    
                    updateBackendlessUser(facebookId, avatarUrl: avatarUrl)
                } else {
                    print("Facebook request error \(error)")
                }
            })
            
            let fieldsMapping = ["id" : "facebookId", "name" : "name", "email" : "email"]
            
            backendless?.userService.login(withFacebookSDK: token, fieldsMapping: fieldsMapping)
        }
        
        return result
    }
}

