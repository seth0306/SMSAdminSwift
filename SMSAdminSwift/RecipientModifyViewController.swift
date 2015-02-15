//
//  RecipientModifyViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/09.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import AddressBook
import CoreData

class RecipientModifyViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    /*－－－－－－－－－－　定数　開始　－－－－－－－－－－*/
    /* 新規受信者定数*/
    let STR_SHINKI:NSString = "新規受信者リスト"
    /* 送信種別 */
    enum methodType:NSNumber {
        case methodTypeMail = 0
        case methodTypeLongSMS = 1
        case methodTypeShortSMS = 2
        case methodTypePhoneOnly = 3
        case methodTypeUnused = 4
    }
    
    /*－－－－－－－－－－　定数　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　プロパティ　開始　－－－－－－－－－－*/
    var recipientArray:NSArray? = nil           //受信者リスト内容
    var recipientReserveArray:NSArray? = nil           //保存用
    var addressBookArray:Array<AnyObject>? = nil
    var recipientObj:NSManagedObject? = nil
    var targetButtonTitle :String = ""
    var recipientSet:NSMutableSet? = nil
    var addressBook: ABAddressBookRef?
    /*－－－－－－－－－－　プロパティ　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　アウトレット　開始　－－－－－－－－－－*/
    @IBOutlet weak var ABTableView: UITableView!
    @IBOutlet weak var recipientListName: UITextField!
    /*－－－－－－－－－－　アウトレット　終了　－－－－－－－－－－*/
    
    func saveData(){
        /* AddressBookUnitを更新 */
        recipientObj?.setValue(recipientSet, forKeyPath: "AddressBookUnits")
        recipientObj?.setValue(recipientListName.text, forKey: "name")
        /* Get ManagedObjectContext from AppDelegate */
        let managedContext:NSManagedObjectContext = recipientObj!.managedObjectContext!
        /* Error handling */
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        println("object saved")
        /* 保存後元の画面に戻る */
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func viewDidLoad() {
        /* 保存ボタンを作成 */
        var right1 = UIBarButtonItem(title: targetButtonTitle, style: .Plain, target: self, action: "saveData")
        if let font = UIFont(name: "HiraKakuProN-W6", size: 14) {
            right1.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        /* 追加ボタンをナビゲーションバーに追加 */
        self.navigationItem.rightBarButtonItems = [right1];
        
        /* 受信者リスト */
        if recipientObj != nil {
            /*　既存リストの修正の場合　*/
            //self.title = "受信者リスト修正"
            recipientListName.text = recipientObj!.valueForKey("name") as NSString
            recipientSet = recipientObj!.mutableSetValueForKey("addressBookUnits") as NSMutableSet
            recipientArray = recipientSet!.allObjects
        } else {
            /* DataHandler */
            let dh = DataHandler()
            /* 新規作成の場合 */
            //self.title = "受信者リスト作成"
            /* 新規受信リスト作成 */
            recipientObj = dh.createNewEntity("Recipient")
            recipientObj?.setValue(STR_SHINKI, forKey: "name")
            recipientSet = recipientObj!.mutableSetValueForKey("addressBookUnits") as NSMutableSet
            /* AddressBookからデータを読み出す */
            /* Error handling */
            let ah = ABHandler()
            var errorRef: Unmanaged<CFError>?
            addressBook = ah.extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            
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
                
                var phoneArray:ABMultiValueRef = ah.extractABPhoneRef(ABRecordCopyValue(contactPerson, kABPersonPhoneProperty))!
                var emailArray:ABMultiValueRef = ah.extractABPhoneRef(ABRecordCopyValue(contactPerson, kABPersonEmailProperty))!
                let phoneNumber = ABMultiValueCopyValueAtIndex(phoneArray, 0)
                var emailAddress = ABMultiValueCopyValueAtIndex(emailArray, 0)
                
                let myPhone:NSString? = ah.extractABPhoneNumber(phoneNumber) as NSString?
                let myEMail:NSString? = ah.extractABEmailAddress(emailAddress) as NSString?
                
                println("phone: \(myPhone)")
                println("email: \(myEMail)")
                
                /* 新しいAdressBookUnitを追加 */
                var newObj:NSManagedObject? = nil
                
                /* 送信方式タイプ */
                let fullname = last + first
                if (fullname != "") {
                    let index = advance(fullname.startIndex, 0)
                    var method_type:NSNumber = 0
                    
                    switch fullname[index] {
                    case "・":
                        method_type = methodType.methodTypeLongSMS.rawValue
                        newObj = dh.createNewEntity("AddressBookUnit")
                    case ":":
                        method_type = methodType.methodTypeShortSMS.rawValue
                        newObj = dh.createNewEntity("AddressBookUnit")
                    case "、":
                        method_type = methodType.methodTypePhoneOnly.rawValue
                    case "X":
                        method_type = methodType.methodTypeUnused.rawValue
                    default:
                        method_type = methodType.methodTypeMail.rawValue
                        newObj = dh.createNewEntity("AddressBookUnit")
                        break
                    }
                    if (newObj != nil) {
                        newObj!.setValue(NSNumber(int: abrecord_id), forKey: "abrecord_id")
                        newObj!.setValue(0, forKey: "selected_phone_index")
                        newObj!.setValue(0, forKey: "selected_mail_index")
                        newObj!.setValue("\(fullname)", forKey: "name")
                        newObj!.setValue(myPhone, forKey: "selected_phone")
                        newObj!.setValue(myEMail, forKey: "selected_mail")
                        newObj!.setValue(method_type, forKey: "method_type")
                        /* Recipientに追加 */
                        recipientSet!.addObject(newObj!)
                    }
                }
                
            }
            recipientArray = recipientSet!.allObjects
            recipientListName.text = STR_SHINKI
            
        }
        
        /* nameでソートする */
        let nameSortDescriptor:NSSortDescriptor = NSSortDescriptor(key:"name", ascending:true)
        let selectedSortDescriptor:NSSortDescriptor = NSSortDescriptor(key:"selected", ascending:false)
        
        recipientArray = recipientArray?.sortedArrayUsingDescriptors([selectedSortDescriptor,nameSortDescriptor])
        
        recipientReserveArray = recipientArray
        
    }
    
    
    /*－－－－－－－－－－　テーブル関係　開始　－－－－－－－－－－*/
    
    /* TableView内のセクション数を返す */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    /* TableView内のCellの表示 */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* AddressBook */
        let  cell = tableView.dequeueReusableCellWithIdentifier("ABListTableViewCell") as AddressBookTableViewCell
        var row = indexPath.row
        let ab_name:NSString? = recipientArray![row].valueForKey("name") as? NSString
        let ab_phone:NSString? = recipientArray![row].valueForKey("selected_phone") as? NSString
        let ab_mail:NSString? = recipientArray![row].valueForKey("selected_mail") as? NSString
        let ab_selected:Bool = recipientArray![row].valueForKey("selected") as? Bool ?? false
        /* セルに値を設定 */
        cell.name.text = ab_name
        cell.phone.text = ab_phone
        cell.mail.text = ab_mail
        /* セルのアクセサリにチェックマークを指定 */
        if ab_selected {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
        
    }
    /* TableView内のセクション内の行数を返す */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipientArray!.count
    }
    
    /* headerの高さを指定 */
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  32
    }
    
    /* headerを作成 */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("ABListTableViewHeaderCell") as AddressBookTableViewHeaderCell
        headerCell.backgroundColor = UIColor.cyanColor()
        return headerCell
    }
    /* すべてのselectedをセットする */
    func toggleAllSelected(flg:Bool){
        
    }
    
    
    
    /* 検索処理 */
    func filterContainsWithSearchText( searchText:NSString ) {
        if (searchText == "") {
            recipientArray = recipientReserveArray
            
        } else {
            let predicate = NSPredicate(format: "%K contains %@ ", "name", searchText)
            recipientArray = recipientArray?.filteredArrayUsingPredicate(predicate!)
        }
    }
    
    /* 検索処理 */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        recipientArray = recipientReserveArray
        filterContainsWithSearchText(searchText)
        ABTableView.reloadData()
    }
    
    //セルが選択された場合の処理
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /* 変更対象オブジェクトの取得 */
        //var modifyObj:NSManagedObject = recipientArray![indexPath.row] as NSManagedObject;
        var modifyObj:NSManagedObject = recipientArray![indexPath.row] as NSManagedObject;
        modifyObj = recipientSet?.member(modifyObj) as NSManagedObject
        
        /* 選択フラグを取得 */
        let ab_selected:Bool = modifyObj.valueForKey("selected") as? Bool ?? false
        /* 選択フラグを反転してセット */
        modifyObj.setValue(!ab_selected, forKey: "selected")
        /*
        /* 選択されたセルを取得 */
        var cell:AddressBookTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as AddressBookTableViewCell
        /* セルのアクセサリにチェックマークを指定 */
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
           cell.accessoryType = UITableViewCellAccessoryType.None
        } else {
           cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        */
        tableView.reloadData()
    }
    
    //UITableViewDelegateに追加されたメソッド
    /*
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    */
    /*
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if tableView.tag == RCPTableViewTag {
            return true
        }
        return false
    }
    */
    
    /* 編集モード */
    /*
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        println(__FUNCTION__)
        self.ABTableView.setEditing(editing, animated: animated)
    }
    */
    
    /* 編集・削除処理 */
    /*
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if tableView.tag == RCPTableViewTag {
                /* 削除対象オブジェクトの取得 */
                var removeObj:NSManagedObject = recipientArray![indexPath.row] as NSManagedObject;
                /* CoreDataから削除　*/
                var dh = DataHandler()
                dh.deleteSpecifiedEntity(removeObj)
                /*　tableViewから削除　*/
                recipientArray!.removeAtIndex(indexPath.row)
                self.RCPTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    */
    /*－－－－－－－－－－　テーブル関係　終了　－－－－－－－－－－*/
    
}
