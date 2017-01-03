//
//  AppDelegate.swift
//  Imagination
//
//  Created by Star on 15/11/14.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings.init(types: [UIUserNotificationType.alert,UIUserNotificationType.sound,UIUserNotificationType.badge], categories: nil))
        
        Notification.testToRescheduleNotificationToNextDay()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        application.applicationIconBadgeNumber -= 1
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        Dlog(notification.alertBody)
        application.applicationIconBadgeNumber -= 1
    }


    func applicationWillEnterForeground(_ application: UIApplication) {
        //启动的时候查看今天的提醒发送没 没有就取消
        Notification.testToRescheduleNotificationToNextDay()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        showAuthorityView()
    }

    func  showAuthorityView() {
        if AuthorityViewController.pWord != AuthorityViewController.NotSet{
            if let rootController = self.window?.rootViewController {
                if let pvc = rootController.presentedViewController {
                    if !pvc.isKind(of: AuthorityViewController.self) {
                        let storeboad = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                        let vc = storeboad.instantiateViewController(withIdentifier: "authority")
                        pvc.present(vc, animated: true, completion: nil)
                    }
                }else {
                    let storeboad = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                    let vc = storeboad.instantiateViewController(withIdentifier: "authority")
                    rootController.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {

        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "imas.Imagination" in the application's documents Application Support directory.
        let urls = Foundation.FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Imagination", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

