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
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        //自動マイグレーション用にオプションを指定
        let options:NSDictionary  = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true]
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: appDelegate.managedObjectModel)
        var error: NSError? = nil
        let url = appDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent("SMSAdminSwift.sqlite")
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: &error) == nil {
        }
    }
    
    func fetchEntityData(entity:String)->[AnyObject]? {
        
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
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
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        /* Create new ManagedObject */
        let entityDesc = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)
        let newObject = NSManagedObject(entity: entityDesc!, insertIntoManagedObjectContext: managedContext)
        return newObject
    }
    
    func deleteSpecifiedEntity(managedObject: NSManagedObject) {
        
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
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
