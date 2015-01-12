//
//  RecipientAdminViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/07.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import CoreData

class RecipientAdminViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    /*－－－－－－－－－－　プロパティ　開始　－－－－－－－－－－*/
    var recipientArray:Array<AnyObject>? = nil
    var recipientObj:NSManagedObject? = nil
    /*－－－－－－－－－－　プロパティ　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　アウトレット　開始　－－－－－－－－－－*/
    @IBOutlet weak var recipientTableView: UITableView!
    /*－－－－－－－－－－　アウトレット　終了　－－－－－－－－－－*/
    
    override func viewDidLoad() {
        self.title = "受信者管理"
        /* 追加ボタンを作成 */
        var right1 = UIBarButtonItem(title: "追加", style: .Plain, target: self, action: "showNewRecipient")
        if let font = UIFont(name: "HiraKakuProN-W6", size: 14 ) {
            right1.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        /* 追加ボタンをナビゲーションバーに追加 */
        self.navigationItem.rightBarButtonItems = [right1];
        /* CoreDataよりHistoryテーブルを読み出す */
        let dh = DataHandler()
        recipientArray = dh.fetchEntityData("Recipient")!
    }
    
    /*－－－－－－－－－－　画面遷移　開始　－－－－－－－－－－*/
    
    /* 受信者詳細画面（新規追加）を表示 */
    func showNewRecipient() {
        performSegueWithIdentifier("showNewRecipient", sender: self)
    }
    
    /* 受信者詳細画面（修正）を表示 */
    func showRecipientModify() {
        performSegueWithIdentifier("showRecipientModify", sender: self)
    }
    
    /* 画面間データ受け渡し */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showRecipientModify" {
            let ctrl:RecipientModifyViewController = segue.destinationViewController as RecipientModifyViewController
            ctrl.title = "受信者リスト修正"
            ctrl.targetButtonTitle = "更新"
            ctrl.recipientObj = recipientObj
            
        } else if segue.identifier == "showNewRecipient" {
            let ctrl:RecipientModifyViewController = segue.destinationViewController as RecipientModifyViewController
            ctrl.title = "新規受信者リスト作成"
            ctrl.targetButtonTitle = "保存"
        }
    }
    /*－－－－－－－－－－　画面遷移　終了　－－－－－－－－－－*/
    
    /*－－－－－－－－－－　テーブル関係　開始　－－－－－－－－－－*/
    
    /* TableView内のセクション数を返す */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    /* TableView内のCellの表示 */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* AddressBook */
        let  cell = tableView.dequeueReusableCellWithIdentifier("RecipientTableViewCell") as RecipientTableViewCell
        var row = indexPath.row
        let  rcp_name:NSString? = recipientArray![row].valueForKey("name") as? NSString
        /* セルに値を設定 */
        cell.rcp_name.text = rcp_name
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
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("RecipientTableViewHeaderCell") as RecipientTableViewHeaderCell
        headerCell.backgroundColor = UIColor.cyanColor()
        return headerCell
    }
    
    //セルが選択された場合の処理
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /* 変更対象オブジェクトの取得 */
        recipientObj = recipientArray![indexPath.row] as? NSManagedObject;
        /* 受信者リスト修正画面に遷移 */
        showRecipientModify()
        
    }
    
    //UITableViewDelegateに追加されたメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    /* 編集モード */
        override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        println(__FUNCTION__)
        self.recipientTableView.setEditing(editing, animated: animated)
    }
    
    /* 編集・削除処理 */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            /* 削除対象オブジェクトの取得 */
            var removeObj:NSManagedObject = recipientArray![indexPath.row] as NSManagedObject;
            /* CoreDataから削除　*/
            var dh = DataHandler()
            dh.deleteSpecifiedEntity(removeObj)
            /*　tableViewから削除　*/
            recipientArray!.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    /*－－－－－－－－－－　テーブル関係　終了　－－－－－－－－－－*/

    
}
