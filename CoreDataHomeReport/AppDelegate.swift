//
//  AppDelegate.swift
//  CoreDataHomeReport
//
//  Created by Igor Korshunov on 26/12/2019.
//  Copyright © 2019 Igor Korshunov. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var coreDataManager = CoreDataManager.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        deleteRecords()
//                coreDataManager.persistentContainer.performBackgroundTask { [weak self] (context: NSManagedObjectContext) in
//        //            perform on background
//                    
//        //            should be used on main queue
//                    let mainQueueContext = self?.coreDataManager.persistentContainer.viewContext
//                    print("===================== \(context)")
//                    print("===================== \(mainQueueContext)")
//                    
//                    
//                }
        checkDataStore()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func checkDataStore() {
        print("123")
        let request: NSFetchRequest<Home> = Home.fetchRequest()
        let context = coreDataManager.persistentContainer.viewContext
        do{
            let homeCount = try context.count(for: request)
            if homeCount == 0 {
                uploadSampleData()
            }
        }catch{
            fatalError("error in counting home record")
        }
    }
    
    func uploadSampleData(){
//        let context = coreDataManager.persistentContainer.viewContext
        
        //backgroundContext
        let context = coreDataManager.persistentContainer.newBackgroundContext()
    
        coreDataManager.persistentContainer.performBackgroundTask { [weak self] (context: NSManagedObjectContext) in
//            perform on background
            
//            should be used on main queue
            let mainQueueContext = self?.coreDataManager.persistentContainer.viewContext
            print("===================== \(context)")
            print("===================== \(mainQueueContext)")
            
            
        }
        
        //async
//        context.perform {
//            try? context.save()
//        }
        
        guard let url = Bundle.main.url(forResource: "homes", withExtension: "json") else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        
        do{
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            let jsonArr = jsonResult.value(forKey: "home") as! NSArray
            for json in jsonArr {
                let homeData = json as! [String: AnyObject]
                
                guard let city = homeData["city"] else { return }
                guard let price = homeData["price"] else { return }
                guard let bed = homeData["bed"] else { return }
                guard let bath = homeData["bath"] else { return }
                guard let sqft = homeData["sqft"] else { return }
                
                var image: UIImage?
                if let currImage = homeData["image"] {
                    guard let imageName = currImage as? String else { return }
                    image = UIImage(named: imageName)
                }
                
                guard let category = homeData["category"] as? [String: String] else { return }
                guard let homeType = category["homeType"] else { return }
                
                guard let status = homeData["status"] as? [String: Bool] else { return }
                guard let isForSale = status["isForSale"] else { return }
                
                //create Home object
                let home = homeType.caseInsensitiveCompare("Condo") == .orderedSame ? Condo(context: context) : SingleFamily(context: context)
                home.city = city as? String
                home.price = price as! Double
                home.bed = bed.int16Value
                home.bath = bath.int16Value
                home.sqft = sqft.int16Value
                if let image = image {
                    home.image = image.jpegData(compressionQuality: 1.0)
                }else{
                    return
                }
                home.homeType = homeType
                home.isForSale = isForSale
                
                if let unitsPerBuilding = homeData["unitsPerBuilding"] {
                    (home as! Condo).unitsPerBuilding = unitsPerBuilding.int16Value
                }
                
                if let lotSize = homeData["lotSize"] {
                    (home as! SingleFamily).lotSize = lotSize.int16Value
                }
                
                //sale history
                if let saleHistory = homeData["saleHistory"] {
                    
                    for saleDetail in saleHistory as! NSArray{
                        let saleData = saleDetail as! [String: AnyObject]
                        let historyObject = SaleHistory(context: context)
                        historyObject.soldPrice = saleData["soldPrice"] as! Double
                        
                        let dateStr = saleData["soldDate"] as! String
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let date = formatter.date(from: dateStr)
                        historyObject.soldDate = date
                        
                        home.addToSaleHistory(historyObject)
                    }
                }
            }
            context.perform {
                try? context.save()
            }
//            coreDataManager.saveContext()
        }catch{
            fatalError("cannot upload sample data")
        }
        
    }
    
    
}

