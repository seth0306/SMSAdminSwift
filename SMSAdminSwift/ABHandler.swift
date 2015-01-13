//
//  ABHandler.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/07.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import AddressBook
import CoreData

class ABHandler: NSObject {
    
    var addressBook: ABAddressBookRef?
    
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    func startManagingAB() {
        if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.NotDetermined) {
            println("requesting access...")
            var errorRef: Unmanaged<CFError>? = nil
            addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
                if success {
                    println("success")
                }
                else {
                    println("error")
                }
            })
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Denied || ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Restricted) {
            println("access denied")
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Authorized) {
            println("access granted")
            self.getContactNames()
        }
    }
    
    
    /* AddressBookのデータをCoreDataに保存 */
    func saveToCoreData(){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        /* Create new ManagedObject */
        let entity = NSEntityDescription.entityForName("AddressBook", inManagedObjectContext: managedContext)
        
        /* Error handling */
        var errorRef: Unmanaged<CFError>?
        addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        println("records in the array \(contactList.count)")
        
        for record:ABRecordRef in contactList {
            var contactPerson: ABRecordRef = record
            /* 名前を取得 */
            let first = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty)?.takeRetainedValue() as String? ?? ""
            let last  = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty)?.takeRetainedValue() as String? ?? ""
            /* ABRecordIDを取得 */
            let abrecord_id = ABRecordGetRecordID(contactPerson)
            
            println ("contactName \(last + first)")
            /* 電話番号を取得 */
            var phoneArray:ABMultiValueRef = extractABPhoneRef(ABRecordCopyValue(contactPerson, kABPersonPhoneProperty))!
            
            for (var j = 0; j < ABMultiValueGetCount(phoneArray); ++j)
            {
                var phoneNumber = ABMultiValueCopyValueAtIndex(phoneArray, j)
                var myString = extractABPhoneNumber(phoneNumber)
                println("phone: \(myString)")
                /* 電話番号の個数分Entityを追加 */
                let ABObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                ABObject.setValue("\(last + first)", forKey: "name")
                ABObject.setValue(myString!, forKey: "phone")
                /* idを保存 */
                ABObject.setValue(j, forKey: "id")
                /* ABRecordIDを保存 */
                ABObject.setValue(NSNumber(int: abrecord_id), forKey: "abrecord_id")
                /* Entitiyを保存*/
                var error: NSError?
                if !managedContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
                println("object saved")
            }
        }

        
    }
    
    func getContactNames()
    {
        var errorRef: Unmanaged<CFError>?
        addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        println("records in the array \(contactList.count)")
        
        for record:ABRecordRef in contactList {
            var contactPerson: ABRecordRef = record
            
            //var contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as NSString
            let first = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty)?.takeRetainedValue() as String? ?? ""
            let last  = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty)?.takeRetainedValue() as String? ?? ""
            
            println ("contactName \(last + first)")
            
            var phoneArray:ABMultiValueRef = extractABPhoneRef(ABRecordCopyValue(contactPerson, kABPersonPhoneProperty))!
            
            for (var j = 0; j < ABMultiValueGetCount(phoneArray); ++j)
            {
                var phoneNumber = ABMultiValueCopyValueAtIndex(phoneArray, j)
                var myString = extractABPhoneNumber(phoneNumber)
                println("phone: \(myString)")
            }
        }
    }
    
    func extractABPhoneRef (abPhoneRef: Unmanaged<ABMultiValueRef>!) -> ABMultiValueRef? {
        if let ab = abPhoneRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    func extractABPhoneNumber (abPhoneNumber: Unmanaged<AnyObject>!) -> String? {
        if let ab = abPhoneNumber {
            return Unmanaged.fromOpaque(abPhoneNumber.toOpaque()).takeUnretainedValue() as CFStringRef
        }
        return nil
    }

    
    func extractABEmailRef (abEmailRef: Unmanaged<ABMultiValueRef>!) -> ABMultiValueRef? {
        if let ab = abEmailRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    func extractABEmailAddress (abEmailAddress: Unmanaged<AnyObject>!) -> String? {
        if let ab = abEmailAddress {
            return Unmanaged.fromOpaque(abEmailAddress.toOpaque()).takeUnretainedValue() as CFStringRef
        }
        return nil
    }

}
