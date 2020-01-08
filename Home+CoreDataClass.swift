//
//  Home+CoreDataClass.swift
//  CoreDataHomeReport
//
//  Created by Igor Korshunov on 26/12/2019.
//  Copyright © 2019 Igor Korshunov. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Home)
public class Home: NSManagedObject {

    func getHomesByStatus(isForSale: Bool, context: NSManagedObjectContext) -> [Home]{
        let request: NSFetchRequest<Home> = Home.fetchRequest()
        request.predicate = NSPredicate(format: "isForSale = %@", NSNumber(value: isForSale))
        do{
            let homes = try context.fetch(request)
            return homes
        }catch{
            fatalError("error in getting list of homes")
        }
    }
    
    typealias HomeByStatusHandler = (_ homes: [Home]) -> Void
    
    func asyncGetHomesByStatus(isForSale: Bool, context: NSManagedObjectContext, completion: @escaping HomeByStatusHandler){
        let request: NSFetchRequest<Home> = Home.fetchRequest()
        request.predicate = NSPredicate(format: "isForSale = %@", NSNumber(value: isForSale))
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request) { (res: NSAsynchronousFetchResult<Home>) in
            let homes = res.finalResult!
            completion(homes)
        }
        do{
            try context.execute(asyncRequest)
        }catch{
            fatalError("error in getting list of homes")
        }
    }
}
