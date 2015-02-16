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
    
    
    enum methodType:Int32 {
        case methodTypeMail = 0
        case methodTypeLongSMS = 1
        case methodTypeShortSMS = 2
        case methodTypePhoneOnly = 3
        case methodTypeUnused = 4
    }
    
    var addressBook: ABAddressBookRef?
    
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    /* Group表示 */
    func showGroup() {
        var errorRef: Unmanaged<CFError>?
        addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        var contactList: NSArray = ABAddressBookCopyArrayOfAllGroups(addressBook).takeRetainedValue()
        for record:ABRecordRef in contactList {
            var contactGroup: ABRecordRef = record
            let abrecord_id = ABRecordGetRecordID(contactGroup)
            let name = ABRecordCopyValue(contactGroup, kABGroupNameProperty)?.takeRetainedValue() as String? ?? ""
            println ("groupName \(name)")
        }
    }
    
    /* GroupList取得 */
    func getGroupList() -> Array<Any> {
        var list:Array<Any> = []
        var errorRef: Unmanaged<CFError>?
        addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        var contactList: NSArray = ABAddressBookCopyArrayOfAllGroups(addressBook).takeRetainedValue()
        for record:ABRecordRef in contactList {
            var contactGroup: ABRecordRef = record
            let abrecord_id = ABRecordGetRecordID(contactGroup)
            let name = ABRecordCopyValue(contactGroup, kABGroupNameProperty)?.takeRetainedValue() as String? ?? ""
            println ("groupName \(name)")
            var unit:Dictionary<String,Any> = ["abrecord_id":abrecord_id,"name":name]
            list.append(unit)
        }
        return list
    }
    
    /* RecipientList取得 */
    func getRecipientListByGroup(abrecord_id:ABRecordID,typeofmethod:methodType) -> Array<NSString> {
        var list:Array<NSString> = []
        var errorRef: Unmanaged<CFError>?
        addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        var ab_record:ABRecord = ABAddressBookGetGroupWithRecordID(addressBook, abrecord_id).takeRetainedValue()
        var contactList: NSArray = ABGroupCopyArrayOfAllMembers(ab_record).takeRetainedValue()
        for record:ABRecordRef in contactList {
            var contactPerson: ABRecordRef = record
            /* 名前を取得 */
            let first = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty)?.takeRetainedValue() as String? ?? ""
            let last  = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty)?.takeRetainedValue() as String? ?? ""
            /* ABRecordIDを取得 */
            let abrecord_id = ABRecordGetRecordID(contactPerson)
            /* 電話番号とメールアドレスを取得　一番上のもの */
            var phoneArray:ABMultiValueRef = extractABPhoneRef(ABRecordCopyValue(contactPerson, kABPersonPhoneProperty))!
            var emailArray:ABMultiValueRef = extractABPhoneRef(ABRecordCopyValue(contactPerson, kABPersonEmailProperty))!
            /* 一番最初のデータのみ取得 */
            let phoneNumber = ABMultiValueCopyValueAtIndex(phoneArray, 0)
            var emailAddress = ABMultiValueCopyValueAtIndex(emailArray, 0)
            let myPhone:NSString? = extractABPhoneNumber(phoneNumber) as NSString?
            let myEMail:NSString? = extractABEmailAddress(emailAddress) as NSString?
            /*　fullname作成　*/
            let fullname = last + first
            /* 送信方式タイプ 名前が空白でない場合 */
            if (fullname != "") {
                let index = advance(fullname.startIndex, 0)
                switch fullname[index] {
                case "・":
                    if (typeofmethod == methodType.methodTypeLongSMS) {
                        if (myPhone != nil) {
                            list.append(myPhone!)
                        }

                    }
                    break
                case ":","：":
                    if (typeofmethod == methodType.methodTypeShortSMS) {
                        if (myPhone != nil) {
                            list.append(myPhone!)
                        }
                    }
                    break
                case "、":
                    break
                case "X":
                    break
                default:
                    if (typeofmethod == methodType.methodTypeMail) {
                        if (myEMail != nil) {
                            list.append(myEMail!)
                        }
                    }
                    break
                }
            }
        }
        return list
    }


    /* AddressBookの使用許可確認 */
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
            //self.getContactNames()
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
            /* 電話番号とメールアドレスを取得　一番上のもの */
            
            var phoneArray:ABMultiValueRef = extractABPhoneRef(ABRecordCopyValue(contactPerson, kABPersonPhoneProperty))!
            var emailArray:ABMultiValueRef = extractABPhoneRef(ABRecordCopyValue(contactPerson, kABPersonEmailProperty))!
            var phoneNumber = ABMultiValueCopyValueAtIndex(phoneArray, 0)
            var emailAddress = ABMultiValueCopyValueAtIndex(emailArray, 0)
            
            var myPhone = extractABPhoneNumber(phoneNumber)
            var myEMail = extractABEmailAddress(emailAddress)
            
            println("phone: \(myPhone)")
            println("email: \(myEMail)")
            
            /* 電話番号の個数分Entityを追加 */
            let ABObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            ABObject.setValue("\(last + first)", forKey: "name")
            ABObject.setValue(myPhone!, forKey: "selected_phone")
            ABObject.setValue(myEMail!, forKey: "selected_mail")
            
            /* idを保存 */
            ABObject.setValue(0, forKey: "id")
            /* ABRecordIDを保存 */
            ABObject.setValue(NSNumber(int: abrecord_id), forKey: "abrecord_id")
            /* Entitiyを保存*/
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            println("object saved")
            
            /*
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
            */
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
    
    /* AddressBookのデータをCoreDataに保存 */
    func asaveToCoreData(){
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
            /* 電話番号とメールアドレスを取得　一番上のもの */
            
            var phoneArray:ABMultiValueRef = extractABPhoneRef(ABRecordCopyValue(contactPerson, kABPersonPhoneProperty))!
            var emailArray:ABMultiValueRef = extractABPhoneRef(ABRecordCopyValue(contactPerson, kABPersonEmailProperty))!
            var phoneNumber = ABMultiValueCopyValueAtIndex(phoneArray, 0)
            var emailAddress = ABMultiValueCopyValueAtIndex(emailArray, 0)
            
            var myPhone = extractABPhoneNumber(phoneNumber)
            var myEMail = extractABEmailAddress(emailAddress)
            
            println("phone: \(myPhone)")
            println("email: \(myEMail)")
            
            /* 電話番号の個数分Entityを追加 */
            let ABObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            ABObject.setValue("\(last + first)", forKey: "name")
            ABObject.setValue(myPhone!, forKey: "selected_phone")
            ABObject.setValue(myEMail!, forKey: "selected_mail")
            
            /* idを保存 */
            ABObject.setValue(0, forKey: "id")
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
