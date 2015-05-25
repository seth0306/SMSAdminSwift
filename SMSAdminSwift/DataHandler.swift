//
//  DataHandler.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/07.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import CoreData

class DataHandler: NSObject {
    
    override init() {
        super.init()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        //自動マイグレーション用にオプションを指定
        let options:NSDictionary  = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true]
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: appDelegate.managedObjectModel)
        var error: NSError? = nil
        let url = appDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent("SMSAdminSwift.sqlite")
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options as [NSObject : AnyObject], error: &error) == nil {
        }
    }
    
    func countSentMail()->Dictionary<String,Int> {
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let manageContext = appDelegate.managedObjectContext!

        /* 今日の日付を取得 */
        let now = NSDate()
        /* NSCalendarを取得 */
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        /* １日前 */
        let startDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: now, options: nil)!
        
        /* １日後 */
        let tmpDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: 1, toDate: now, options: nil)
        let endDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: tmpDate!, options: nil)!
        
        /* 検索条件設定 */
        let predicate = NSPredicate(format: "(sent_date >= %@ ) and (sent_date < %@)",startDate,endDate)
        
        /* Set search conditions */
        let fetchRequest = NSFetchRequest(entityName: "History")
        var error: NSError?
        
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .DictionaryResultType
        
        /* countのsumを設定 */
        let sumExpression = NSExpression(format: "sum:(count)")
        let sumED = NSExpressionDescription()
        sumED.expression = sumExpression
        sumED.name = "sumOfCount"
        sumED.expressionResultType = .DoubleAttributeType
        fetchRequest.propertiesToFetch = ["method", sumED]
        fetchRequest.propertiesToGroupBy = ["method"]
        let sort = NSSortDescriptor(key: "method", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        /* Query実行 */
        //let results = manageContext?.executeFetchRequest(fetch, error: nil) as NSArray?
        
        /* Query実行 */
        let fetchResults = manageContext.executeFetchRequest(fetchRequest, error: &error)
        
        var dics:Dictionary = ["EM":0, "LS":0, "SS":0]
        if (fetchResults?.count ?? 0 == 0) {
            return dics
        }
        for rs in fetchResults! {
            if ("EM" == rs.valueForKey("method") as! String) {
                dics["EM"] = rs.valueForKey("sumOfCount") as? Int ?? 0
            } else if ("LS" == rs.valueForKey("method") as! String) {
                dics["LS"] = rs.valueForKey("sumOfCount") as? Int ?? 0
            } else if ("SS" == rs.valueForKey("method") as! String) {
                dics["SS"] = rs.valueForKey("sumOfCount") as? Int ?? 0
            }
        }
        return dics
        
    }

    
    func fetchEntityData(entity:String)->[AnyObject]? {
        
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let manageContext = appDelegate.managedObjectContext!
        
        /* Set search conditions */
        let fetchRequest = NSFetchRequest(entityName: entity)
        var error: NSError?
        
        /* Get result array from ManagedObjectContext */
        let fetchResults = manageContext.executeFetchRequest(fetchRequest, error: &error)
        
        if let results: Array = fetchResults {
            println(results.count)
            return results
        } else {
            println("Could not fetch \(error) , \(error!.userInfo)")
            return nil;
        }
    }
    
    /* entityの新規作成 */
    func createNewEntity(entityName:NSString) -> NSManagedObject{
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        /* Create new ManagedObject */
        let entityDesc = NSEntityDescription.entityForName(entityName as String, inManagedObjectContext: managedContext)
        let newObject = NSManagedObject(entity: entityDesc!, insertIntoManagedObjectContext: managedContext)
        return newObject
    }
    
    func deleteSpecifiedEntity(managedObject: NSManagedObject) {
        
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        /* Delete managedObject from managed context */
        managedContext.deleteObject(managedObject)
        
        /* Save value to managed context */
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not update \(error), \(error!.userInfo)")
        }
        println("Object deleted")
        
    }

}
