//
//  HomeListController.swift
//  CoreDataHomeReport
//
//  Created by Igor Korshunov on 27/12/2019.
//  Copyright © 2019 Igor Korshunov. All rights reserved.
//

import UIKit
import CoreData

class HomeListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var managedObjectContext: NSManagedObjectContext! = CoreDataManager.shared.persistentContainer.viewContext
    
    lazy var homes = [Home]()
    
    var home: Home?
    
    var isForSale = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 140
        home = Home(context: managedObjectContext)
        loadData()
    }
    
    func loadData(){
        if let home = home {
            homes = home.getHomesByStatus(isForSale: isForSale, context: managedObjectContext)
            tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeListCell", for: indexPath) as! HomeListCell
        let currHome = homes[indexPath.row]
        cell.home = currHome
        return cell
    }
    
    //---------------filter by bredicate------------------------------
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        isForSale = sender.selectedSegmentIndex == 0 ? true : false
        loadData()
    }
    
    //--------------sale history for home---------------------------------------
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let home = homes[indexPath.row]
        let history = getSoldHistory(home: home)
        for obj in history {
            print("--------------------sale history for home-----------------")
            print(obj.soldDate ?? "")
            print(obj.soldPrice)
            print("------------")
        }
        
        filterDataSourcs()
        totalHomeSales()
        numberCondoSold()
        minSoldPrice()
        avgPrice()
        fetchAsynchronously()
    }
    
    func getSoldHistory(home: Home) -> [SaleHistory] {
        let request: NSFetchRequest<SaleHistory> = SaleHistory.fetchRequest()
        request.predicate = NSPredicate(format: "home = %@", home)
        
        do{
            let history = try managedObjectContext.fetch(request)
            return history
        }catch{
            fatalError("error in getting sold history")
        }
    }
    
    //---------sort and compound predicate-----------------------
    
    func filterDataSourcs(){
        let request: NSFetchRequest<Home> = Home.fetchRequest()
        
        var predicates = [NSPredicate]()
        var pred = NSPredicate(format: "homeType = %@", "Condo")
        predicates.append(pred)
        pred = NSPredicate(format: "isForSale = %@", NSNumber(value: true))
        predicates.append(pred)
        
        let compoundPred = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates)
        request.predicate = compoundPred
        
        let sortDescriptor = NSSortDescriptor(key: "price", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do{
            let res = try managedObjectContext.fetch(request)
            print("-------------------- compound predicate -----------------")
            print(res)
        }catch{
            print("error compound request")
        }
        
    }
    
    //MARK: agregate functions
    //------------------ agregate functions ------------------------------------------
    func totalHomeSales(){
        let soldPredicate = NSPredicate(format: "isForSale = %@", NSNumber(value: false))
        let request: NSFetchRequest<Home> = Home.fetchRequest()
        request.predicate = soldPredicate
        
        let keypathExp1 = NSExpression(forKeyPath: "price")
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp1])
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
                        
        request.returnsObjectsAsFaults = false
        request.propertiesToFetch = [sumDesc]
        request.resultType = .dictionaryResultType
        
        do{
            let res = try managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [NSDictionary]
            print("-------------------- total sales -----------------")
            
            if let dict = res.first {
                print(dict)
                let val = dict["sum"] as! Double
                print(val)
            }
            
        }catch{
            print("error getting total home sales")
        }
        
    }

    func numberCondoSold(){
        let soldPredicate = NSPredicate(format: "isForSale = %@", NSNumber(value: false))
        let typePredicate = NSPredicate(format: "homeType = %@", "Condo")
        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [soldPredicate, typePredicate])
        let request: NSFetchRequest<Home> = Home.fetchRequest()
        request.predicate = predicate
        request.resultType = .countResultType
        
        
        do{
            let res = try managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [NSNumber]
            if let count = res.first {
                print("-------------------- total condo sold -----------------")
                print(count.intValue)
            }
        }catch{
            print("error counting condo sold")
        }
    }
    
    func minSoldPrice() {
        let soldPredicate = NSPredicate(format: "isForSale = %@", NSNumber(value: false))
        let request: NSFetchRequest<Home> = Home.fetchRequest()
        request.predicate = soldPredicate
        request.resultType = .dictionaryResultType
        
        let sumExpressionDescription = NSExpressionDescription()
        sumExpressionDescription.name = "minPrice"
        sumExpressionDescription.expression = NSExpression(forFunction: "min:", arguments: [NSExpression(forKeyPath: "price")])
        sumExpressionDescription.expressionResultType = .doubleAttributeType
        
        request.propertiesToFetch = [sumExpressionDescription]
        
        do{
            let res = try managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [NSDictionary]
            print("-------------------- min home price -----------------")
            
            if let dict = res.first {
                print(dict)
                let val = dict["minPrice"] as! Double
                print(val)
            }
        }catch{
            print("error getting min price")
        }

    }
    
    func avgPrice(){
        let soldPredicate = NSPredicate(format: "isForSale = %@", NSNumber(value: false))
        let typePredicate = NSPredicate(format: "homeType = %@", "Condo")
        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [soldPredicate, typePredicate])
        let request: NSFetchRequest<Home> = Home.fetchRequest()
        request.predicate = predicate
        request.resultType = .dictionaryResultType
        
        let sumExpressionDescription = NSExpressionDescription()
        sumExpressionDescription.name = "avg"
        sumExpressionDescription.expression = NSExpression(forFunction: "average:", arguments: [NSExpression(forKeyPath: "price")])
        sumExpressionDescription.expressionResultType = .doubleAttributeType
        
        request.propertiesToFetch = [sumExpressionDescription]
        
        do{
            let res = try managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [NSDictionary]
            print("-------------------- avg condo price -----------------")
            
            if let dict = res.first {
                print(dict)
                let val = dict["avg"] as! Double
                print(val)
            }
        }catch{
            print("error avg condo price")
        }
    }
    
    //MARK: async fetching
    func fetchAsynchronously(){
        if let home = home {
            home.asyncGetHomesByStatus(isForSale: true, context: managedObjectContext) { [weak self] (res: [Home]) in
                print("-------------------- async fetch -----------------")
                self?.tableView.reloadData()
                print(res)
            }
        }
    }
}
