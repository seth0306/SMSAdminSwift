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
        
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: appDelegate.managedObjectModel)
        var error: NSError? = nil
        let url = appDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent("SMSAdminSwift.sqlite")
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options as [NSObject : AnyObject])
        } catch let error1 as NSError {
            error = error1
        }
        catch {
            print("Unknown Error")
        }
        
    }
    
    func getProperties()->Dictionary<String,String> {
        
        var dics = Dictionary<String,String>()
        
        let results = fetchEntityDataNoSort("Other")
        if (results != nil) {
            if (results!.count > 0) {
                for result:AnyObject in results! {
                    let colKey = result.valueForKey("key") as! String
                    let colValue = result.valueForKey("property") as! String
                    dics[colKey] = colValue
                }
            }
        }
        return dics
    }

    func writeProperty(key:String,value:String) {
        var obj:NSManagedObject? = fetchNSManagedObjectString("Other", targetColumn: "key", targetValue: key)
        if (obj == nil) {
            obj = createNewEntity("Other")
        }

        obj!.setValue(key, forKey: "key")
        obj!.setValue(value, forKey: "property")
        
        /* Get ManagedObjectContext from AppDelegate */
        let managedContext:NSManagedObjectContext = obj!.managedObjectContext!
        /* Error handling */
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
        catch {
            print("Unknown Error")
        }
        
        print("object saved")
        
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
        let startDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: now, options: [])!
        
        /* １日後 */
        let tmpDate = calendar.dateByAddingUnit(NSCalendarUnit.Day, value: 1, toDate: now, options: [])
        let endDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: tmpDate!, options: [])!
        
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
        let fetchResults: [AnyObject]?
        do {
            fetchResults = try manageContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            fetchResults = nil
        }
        catch {
            print("Unknown Error")
            fetchResults = nil
        }


        var dics:Dictionary<String,Int> = Dictionary<String,Int>()
        dics["EM"] = 0
        dics["LS"] = 0
        dics["SS"] = 0
        
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

    func fetchEntityDataSort(entity:String,sort sortColumn:String)->[AnyObject]? {
        
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let manageContext = appDelegate.managedObjectContext!
        
        /* Set search conditions */
        let fetchRequest = NSFetchRequest(entityName: entity)
        
        let sort = NSSortDescriptor(key: sortColumn, ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        var error: NSError?
        
        /* Get result array from ManagedObjectContext */
        let fetchResults: [AnyObject]?
        do {
            fetchResults = try manageContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            fetchResults = nil
        }
        catch {
            print("Unknown Error")
            fetchResults = nil
        }

        
        if let results: Array = fetchResults {
            print(results.count)
            return results
        } else {
            print("Could not fetch \(error) , \(error!.userInfo)")
            return nil;
        }
    }
    
    
    func fetchEntityDataNoSort(entity:String)->[AnyObject]? {
        
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let manageContext = appDelegate.managedObjectContext!
        
        /* Set search conditions */
        let fetchRequest = NSFetchRequest(entityName: entity)
        var error: NSError?
        
        /* Get result array from ManagedObjectContext */
        let fetchResults: [AnyObject]?
        do {
            fetchResults = try manageContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            fetchResults = nil
        }
        catch {
            print("Unknown Error")
            fetchResults = nil
        }

        
        if let results: Array = fetchResults {
            print(results.count)
            return results
        } else {
            print("Could not fetch \(error) , \(error!.userInfo)")
            return nil;
        }
    }
    
    func fetchNSManagedObjectInt(entity:String, targetColumn tcol:String, targetValue tval:Int)->NSManagedObject? {
        
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let manageContext = appDelegate.managedObjectContext!
        
        /* Set search conditions */
        let fetchRequest = NSFetchRequest(entityName: entity)
        var error: NSError?
        
        /* 検索条件設定 */
        let predicate = NSPredicate(format: "%K = %d",tcol,Int32(tval))
        
        /* Set search conditions */
        
        fetchRequest.predicate = predicate
        //fetchRequest.resultType = .DictionaryResultType
        
    
        
    /* Get result array from ManagedObjectContext */
        let fetchResults: [AnyObject]?
        do {
            fetchResults = try manageContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            fetchResults = nil
        }
        catch {
            print("Unknown Error")
            fetchResults = nil
        }

        
        
        if fetchResults!.count != 0 {
            return fetchResults!.first as? NSManagedObject
        } else {
            //println("Could not fetch \(error) , \(error!.userInfo)")
            return nil;
        }
    }
    func fetchNSManagedObjectString(entity:String, targetColumn tcol:String, targetValue tval:String)->NSManagedObject? {
        
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let manageContext = appDelegate.managedObjectContext!
        
        /* Set search conditions */
        let fetchRequest = NSFetchRequest(entityName: entity)
        var error: NSError?
        
        /* 検索条件設定 */
        let predicate = NSPredicate(format: "%K = %@",tcol,tval)
        
        /* Set search conditions */
        
        fetchRequest.predicate = predicate
        //fetchRequest.resultType = .DictionaryResultType
        
        
        
        /* Get result array from ManagedObjectContext */
        let fetchResults: [AnyObject]?
        do {
            fetchResults = try manageContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            fetchResults = nil
        }
        catch {
            print("Unknown Error")
            fetchResults = nil
        }
        
        
        
        if fetchResults!.count != 0 {
            return fetchResults!.first as? NSManagedObject
        } else {
            //println("Could not fetch \(error) , \(error!.userInfo)")
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
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not update \(error), \(error!.userInfo)")
        }
        catch {
            print("Unknown Error")
        }

        print("Object deleted")
        
    }

}
