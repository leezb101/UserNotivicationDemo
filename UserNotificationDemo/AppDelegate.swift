//
//  AppDelegate.swift
//  UserNotificationDemo
//
//  Created by Mr.LuDashi on 2016/12/16.
//  Copyright © 2016年 ZeluLi. All rights reserved.
//

import UIKit
import UserNotifications

let NOTIFICATION_SILENT = "Notification_silent"
let NOTIFICATION_FETCH = "Notification_fetch"

extension Data {
    var hexString: String {
        return withUnsafeBytes {(bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: count)
            return buffer.map {String(format: "%02hhx", $0)}.reduce("", { $0 + $1 })
        }
    }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) { (granted, error) in
                if granted {
                    print("用户已允许远程通知")
                }
            }
            
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            // Fallback on earlier versions
        }
        
//        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    
        return true
    }
    
    // 获取远程通知token，是data类型的
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.hexString
        print("Get Push token: \(tokenString)")
    }
    
    // 静默通知接收
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_SILENT), object: nil)
        
        completionHandler(.newData)
    }
    
    // background fecth 处理
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_FETCH), object: nil)
        
        completionHandler(.newData)
    }
    
    // 如何处理前台展示效果，iOS10以下，程序在前台以前是不能展示系统通知样式的
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let options: UNNotificationPresentationOptions
        options = [.alert, .sound]
        completionHandler(options)
    }
    
    // 用户触发了哪个action, 或者点击通知栏进入了程序额，这里远程和本地收到的方法得到了统一
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // 记得要设置badge的数量，因为通知可能有设置badge
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // 关于 response.notification.request.content.userInfo
        // 远程，本地通知的自定义内容现在都放到了这个字典里
        
        let userInfo = response.notification.request.content.userInfo
        print("=> 解析到整个userInfo:\(userInfo)")
        
        let customDic = userInfo["custom"]
        let apsDic = userInfo["aps"]
        print("==>远程推送解析到userInfo中的aps:\(apsDic)")
        print("==>远程推送解析到userInfo中的custom:\(customDic)")
        
        if let type = userInfo["type"] as? String {
            print("=>解析到内容type为]\(type)")
        }
        
        // 通知的identifier
        print("===>identifer:\(response.notification.request.identifier)")
        
        // 解析到指定要删除的通知
        if let deleteId = userInfo["delete"] as? String {
            print("=>服务器让我删除id为\(deleteId)的通知")
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [deleteId])
        }
        
        completionHandler()
    }



    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

