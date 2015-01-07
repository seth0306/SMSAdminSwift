//
//  ABHandler.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/07.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import AddressBook

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
                    self.getContactNames()
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
            
            var emailArray:ABMultiValueRef = extractABEmailRef(ABRecordCopyValue(contactPerson, kABPersonEmailProperty))!
            
            for (var j = 0; j < ABMultiValueGetCount(emailArray); ++j)
            {
                var emailAdd = ABMultiValueCopyValueAtIndex(emailArray, j)
                var myString = extractABEmailAddress(emailAdd)
                println("email: \(myString)")
            }
        }
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
