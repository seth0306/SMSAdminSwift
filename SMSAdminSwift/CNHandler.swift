//
//  CNHandler.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/07.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit

import CoreData

import Contacts

@available(iOS 9.0, *)
class CNHandler: NSObject {
    
    enum methodType:Int32 {
        case methodTypeMail = 0
        case methodTypeLongSMS = 1
        case methodTypeShortSMS = 2
        case methodTypePhoneOnly = 3
        case methodTypeUnused = 4
    }
    
    let store = CNContactStore()
    
    /* Group表示 */
    func showGroup() {
        do {
            let groups = try store.groupsMatchingPredicate(nil)
            
            for record:CNGroup in groups {
                print ("groupName \(record.name)")
            }

        }
        catch {
            print("不明なエラーです。")
        }
    }
    
    /* GroupList取得 */
    func getGroupList() -> Array<Dictionary<String,Any> > {
        var list:Array<Dictionary<String,Any> > = []
        do {
            let groups = try store.groupsMatchingPredicate(nil)
            for group:CNGroup in groups {
                let unit:Dictionary<String,Any> = ["groupIdentifier":group.identifier,"name":group.name]
                list.append(unit)
            }
        }
        catch {
            print("不明なエラーです。")
        }
        return list
    }
    
    /* Groupごとのレコード数を取得 */
    func getGroupRecordCountList() -> Array<Any> {
        var list:Array<Any> = []
        do {
            let groups = try store.groupsMatchingPredicate(nil)
            for group:CNGroup in groups {
                let predicate = CNContact.predicateForContactsInGroupWithIdentifier(group.identifier)
                let contactList = try store.unifiedContactsMatchingPredicate(predicate, keysToFetch: [CNContactGivenNameKey])
                let count:NSInteger = contactList.count as NSInteger? ?? 0
                let unit:Dictionary<String,Any> = ["groupIdentifier":group.identifier,"count":String(count)]
                list.append(unit)
            }
        }
        catch {
            print("不明なエラーです。")
        }
        return list
    }
    
    /* RecipientList取得 */
    func getRecipientListByGroup(groupIdentifier:String,typeofmethod:methodType) -> Array<String> {
        var list:Array<String> = []
        do {
            let predicate = CNContact.predicateForContactsInGroupWithIdentifier(groupIdentifier)
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey,CNContactEmailAddressesKey]
            let contactList = try store.unifiedContactsMatchingPredicate(predicate, keysToFetch: keys)
            for contact:CNContact in contactList {
                /* 電話番号を取得　一番上のもの */
                var myPhone:String = ""
                if contact.phoneNumbers.count > 0 {
                    let phonenumbder = contact.phoneNumbers[0].value as! CNPhoneNumber
                    myPhone = phonenumbder.stringValue
                }
                /* メールアドレスを取得　一番上のもの */
                var myEMail:String = ""
                if contact.emailAddresses.count > 0 {
                    myEMail = contact.emailAddresses[0].value as! String
                }
                /* 電話番号を取得　一番上のもの */
                let fullname = contact.familyName + contact.givenName
                if (fullname != "") {
                    let index = fullname.startIndex.advancedBy(0)
                    switch fullname[index] {
                    case "・","･","•":
                        if (typeofmethod == methodType.methodTypeLongSMS) {
                            if (myPhone != "") {
                                list.append(myPhone)
                            }
                            
                        }
                        break
                    case ":","：":
                        if (typeofmethod == methodType.methodTypeShortSMS) {
                            if (myPhone != "") {
                                list.append(myPhone)
                            }
                        }
                        break
                    case "、":
                        break
                    case "X":
                        break
                    default:
                        if (typeofmethod == methodType.methodTypeMail) {
                            if (myEMail != "") {
                                list.append(myEMail)
                            }
                        }
                        break
                    }
                }
            }
        }
        catch {
            print("不明なエラーです。")
        }
        return list
    }
    
    /**
     リスト内のメソッドごとのカウントを表示
     @param groupIdentifier String
     @param typeofmethod methodType
     */
    func getEachMethodCountByGroup(groupIdentifier:String) -> Dictionary<String,String> {
        /* 戻り値用 */
        var dics:Dictionary<String,String> = ["EM":"0","LS":"0","SS":"0"]
        /* 一時カウント用 */
        var emCount:Int = 0
        var lsCount:Int = 0
        var ssCount:Int = 0
        
        do {
            let predicate = CNContact.predicateForContactsInGroupWithIdentifier(groupIdentifier)
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey,CNContactEmailAddressesKey]
            let contactList = try store.unifiedContactsMatchingPredicate(predicate, keysToFetch: keys)
            if contactList.count == 0 {
                /*戻り値をセット*/
                dics["EM"] = String(0)
                dics["LS"] = String(0)
                dics["SS"] = String(0)
            } else {
                for contact:CNContact in contactList {
                    /* 電話番号を取得　一番上のもの */
                    //let phonenumbder = contact.phoneNumbers[0].value as! CNPhoneNumber
                    //let myPhone:String? = phonenumbder.stringValue
                    var myPhone:String = ""
                    if contact.phoneNumbers.count > 0 {
                        let phonenumbder = contact.phoneNumbers[0].value as! CNPhoneNumber
                        myPhone = phonenumbder.stringValue
                    }
                    /* メールアドレスを取得　一番上のもの */
                    var myEMail:String = ""
                    if contact.emailAddresses.count > 0 {
                        myEMail = contact.emailAddresses[0].value as! String
                    }
                    
                    /*　fullname作成　*/
                    let fullname = contact.familyName + contact.givenName
                    /* 送信方式タイプ 名前が空白でない場合 */
                    if (fullname != "") {
                        let index = fullname.startIndex.advancedBy(0)
                        switch fullname[index] {
                        case "・","･","•":
                            if (myPhone != "") {
                                lsCount += 1
                            }
                            break
                        case ":","：":
                            if (myPhone != "") {
                                ssCount += 1
                            }
                            break
                        case "、":
                            break
                        case "X":
                            break
                        default:
                            if (myEMail != "") {
                                emCount += 1
                            }
                            break
                        }
                    }
                }
                /*戻り値をセット*/
                dics["EM"] = String(emCount)
                dics["LS"] = String(lsCount)
                dics["SS"] = String(ssCount)
            }
        }
        catch {
            print("不明なエラーです。")
        }
        return dics
    }
    /* AddressBookの使用許可確認 */
    func startManagingAB() {
        
        switch CNContactStore.authorizationStatusForEntityType(.Contacts){
        case .Authorized:
            print("access granted")
        case .NotDetermined:
            store.requestAccessForEntityType(.Contacts){
                succeeded, err in
                guard err == nil && succeeded else{
                    print("access failed")
                    return
                }
            }
        case .Denied:
            store.requestAccessForEntityType(.Contacts){
                succeeded, err in
                guard err == nil && succeeded else{
                    print("access denied")
                    return
                }
            }
        default:
            print("Not handled")
        }
    }
}
