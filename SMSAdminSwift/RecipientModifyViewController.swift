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

class RecipientModifyViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    /*－－－－－－－－－－　定数　開始　－－－－－－－－－－*/
    let RCPTableViewTag = 0
    let ABTableViewTag = 1
    /*－－－－－－－－－－　定数　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　プロパティ　開始　－－－－－－－－－－*/
    var recipientArray:Array<AnyObject>? = nil
    var addressBookArray:Array<AnyObject>? = nil
    var recipientObj:NSManagedObject? = nil
    /*－－－－－－－－－－　プロパティ　終了　－－－－－－－－－－*/
    
    /*－－－－－－－－－－　アウトレット　開始　－－－－－－－－－－*/
    @IBOutlet weak var RCPTableView: UITableView!
    @IBOutlet weak var ABTableView: UITableView!
    /*－－－－－－－－－－　アウトレット　終了　－－－－－－－－－－*/
    
    override func viewDidLoad() {
        self.title = "受信者リスト作成"
        
        /* 保存ボタンを作成 */
        var right1 = UIBarButtonItem(title: "電話帳", style: .Plain, target: self, action: "showPeoplePicker")
        if let font = UIFont(name: "HiraKakuProN-W6", size: 14) {
            right1.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        /* 追加ボタンをナビゲーションバーに追加 */
        self.navigationItem.rightBarButtonItems = [right1];
        
        /* CoreDataよりHistoryテーブルを読み出す */
        let dh = DataHandler()
        addressBookArray = dh.fetchEntityData("AddressBook")!
    }
    
    /*－－－－－－－－－－　テーブル関係　開始　－－－－－－－－－－*/
    
    /* TableView内のセクション数を返す */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    /* TableView内のCellの表示 */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView.tag == RCPTableViewTag {
            /* Recipient */
            let  cell = tableView.dequeueReusableCellWithIdentifier("RCPListTableViewCell") as RecipientListTableViewCell
            var row = indexPath.row
            
            return cell
        } else if tableView.tag == ABTableViewTag {
            /* AddressBook */
            let  cell = tableView.dequeueReusableCellWithIdentifier("ABListTableViewCell") as AddressBookTableViewCell
            var row = indexPath.row
            let ab_name:NSString? = addressBookArray![row].valueForKey("name") as? NSString
            let ab_phone:NSString? = addressBookArray![row].valueForKey("phone") as? NSString
            /* セルに値を設定 */
            cell.name.text = ab_name
            cell.phone.text = ab_phone
            
            return cell
        }
        return UITableViewCell()
    }
    
    /* TableView内のセクション内の行数を返す */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == RCPTableViewTag {
            //return recipientArray!.count
            return 0
        } else if tableView.tag == ABTableViewTag {
            return addressBookArray!.count
        }
        return 0
    }
    
    /* headerの高さを指定 */
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  32
    }
    
    /* headerを作成 */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == RCPTableViewTag {
            let  headerCell1 = tableView.dequeueReusableCellWithIdentifier("RCPListTableViewCell") as RecipientListTableViewHeaderCell
            headerCell1.backgroundColor = UIColor.cyanColor()
            return headerCell1
        } else {
            let  headerCell2 = tableView.dequeueReusableCellWithIdentifier("ABListTableViewHeaderCell") as AddressBookTableViewHeaderCell
            headerCell2.backgroundColor = UIColor.cyanColor()
            return headerCell2
        }
    }
    
    //セルが選択された場合の処理
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*
        var row = indexPath.row
        templateObj = templateArray![row] as? NSManagedObject
        showTemplateModify()
        */
    }
    
    //UITableViewDelegateに追加されたメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if tableView.tag == RCPTableViewTag {
            return true
        }
        return false
    }
    
    /* 編集モード */
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        println(__FUNCTION__)
        self.RCPTableView.setEditing(editing, animated: animated)
    }
    
    /* 編集・削除処理 */
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
    
    /*－－－－－－－－－－　テーブル関係　終了　－－－－－－－－－－*/

}
