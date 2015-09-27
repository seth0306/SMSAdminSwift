//
//  GroupOrderViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/05/31.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import CoreData

class GroupOrderViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    /*－－－－－－－－－－　プロパティ　開始　－－－－－－－－－－*/
    var groupArray:Array<AnyObject>? = nil
    var groupObj:NSManagedObject? = nil
    var groupList:Array<Dictionary<String,Any>>? = nil
    /*－－－－－－－－－－　プロパティ　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　アウトレット　開始　－－－－－－－－－－*/
    @IBOutlet weak var GroupOrderTableView: UITableView!
    /*－－－－－－－－－－　アウトレット　終了　－－－－－－－－－－*/
    
    override func viewDidLoad() {
        self.title = "グループ表示順設定"
        
        /* 保存ボタンを作成 */
        let right1 = UIBarButtonItem(title: "削除", style: .Plain, target: self, action: "deleteAllGroup")
        if let font = UIFont(name: "HiraKakuProN-W6", size: 14 ) {
            right1.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        
        /* 編集ボタンを作成 */
        let right2 = self.editButtonItem()
        if let font = UIFont(name: "HiraKakuProN-W6", size: 14 ) {
            right2.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        right2.setValue("編集", forKey: "title")
        
        
        /* 追加ボタンをナビゲーションバーに追加 */
        self.navigationItem.rightBarButtonItems = [right2]
        //self.navigationItem.rightBarButtonItems = [right2,right1]
        
        /* CoreDataよりGroupテーブルを読み出す */
        let dh = DataHandler()
        groupArray = dh.fetchEntityData("Group",sort:"order")!
        
        /* AddressBookより読み出し */
        let ab = ABHandler()
        groupList = ab.getGroupList()
        
        /* AddressBookのGroupとEntity Groupの内容を比較 */
        for_ab:for cnt in 0..<groupList!.count {
            let abObj:Dictionary<String,Any> = groupList![cnt]
            let abid = abObj["abrecord_id"] as! Int32
            var noMatch: Bool = true
            for_g:for gObj in groupArray! {
                let gid = (gObj as! NSManagedObject).valueForKey("abrecord_id") as? Int
                if abid == Int32(gid!) {
                    noMatch = false
                    break for_g
                }
            }
            if noMatch {
                //いなければEntitiyを作成の上０番目に追加
                let nsm:NSManagedObject = createNewEntity(abid,name: abObj["name"] as! String,order :0)
                groupArray!.insert(nsm, atIndex: 0)
            }
        }
        /* AddressBookのGroupとEntity Groupの内容を比較 */
        for_g:for gObj in groupArray! {
            let gid = (gObj as! NSManagedObject).valueForKey("abrecord_id") as? Int
            var noMatch: Bool = true
                for_ab:for cnt in 0..<groupList!.count {
                    let abObj:Dictionary<String,Any> = groupList![cnt]
                    let abid = abObj["abrecord_id"] as! Int32
                    if abid == Int32(gid!) {
                        noMatch = false
                        break for_ab
                    }
            }
            if noMatch {
                //いなければEntitiyを削除
                groupArray!.removeAtIndex(((gObj as! NSManagedObject).valueForKey("order") as? Int)!)
                dh.deleteSpecifiedEntity(gObj as! NSManagedObject)
            }
        }
        /* DBに書き込み */
        modifyExist()
    }
    
    
    /*
    編集ボタンが押された際に呼び出される
    */
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // TableViewを編集可能にする
        GroupOrderTableView.setEditing(editing, animated: true)
        
        // 編集中のときのみaddButtonをナビゲーションバーの左に表示する
        if editing {
            print("編集中")
        
        } else {
            modifyExist()
        }
    }
    
    /*－－－－－－－－－－　テーブル関係　開始　－－－－－－－－－－*/
    //削除アイコンを消す
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    
    /* TableView内のセクション数を返す */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    /* TableView内のCellの表示 */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let  cell = tableView.dequeueReusableCellWithIdentifier("groupCell") as! GroupOrderTableViewCell
        let row = indexPath.row
        
        let groupName:NSString? = groupArray![row].valueForKey("name") as? String
        /* セルに値を設定 */
        cell.groupName.text = groupName as? String
        return cell
    }
    
    /* TableView内のセクション内の行数を返す */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray!.count
    }
    
    /* headerの高さを指定 */
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  32
    }
    
    /* headerを作成 */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("groupHeaderCell") as! GroupOrderTableViewHeaderCell
        headerCell.backgroundColor = UIColor.cyanColor()
        return headerCell
    }
    
    //セルが選択された場合の処理
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //特になし
    }
    //セルの移動を許可
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.section == destinationIndexPath.section { // 移動元と移動先は同じセクションです。
            if destinationIndexPath.row < groupArray!.count {
                let item:NSManagedObject = groupArray![sourceIndexPath.row] as! NSManagedObject// 移動対象を保持します。
                groupArray!.removeAtIndex(sourceIndexPath.row)// 配列から一度消します。
                groupArray!.insert(item, atIndex: destinationIndexPath.row)// 保持しておいた対象を挿入します。
            }
        }
    }
    
    /*－－－－－－－－－－　テーブル関係　終了　－－－－－－－－－－*/
    
    /*－－－－－－－－－－　CoreData　開始　－－－－－－－－－－*/
    
    /* Entitiyの追加・更新処理 */
    func saveGroupOrder() {
        
        modifyExist()
        
        /* 保存後元の画面に戻る */
        self.navigationController?.popViewControllerAnimated(true)
    }
    /* Entitiyの追加・更新処理 */
    func deleteAllGroup() {
        
        let dh = DataHandler()
        
        for gObj in groupArray! {
            dh.deleteSpecifiedEntity(gObj as! NSManagedObject)
        }
        
        /* 保存後元の画面に戻る */
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /*　新しいEntityを追加　*/
    func createNewEntity(abrecord_id:Int32, name:String, order:Int32) -> NSManagedObject {
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        /* Create new ManagedObject */
        let entity = NSEntityDescription.entityForName("Group", inManagedObjectContext: managedContext)
        let groupObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        /* Set the name attribute using key-value coding */
        groupObject.setValue(name, forKey: "name")
        groupObject.setValue(Int(abrecord_id), forKey: "abrecord_id")
        groupObject.setValue(Int(order), forKey: "order")
        
        /* Error handling */
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
        print("object saved")
        return groupObject
    }
    
    
    /*　既存のEntityを修正　*/
    func modifyExist(){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        for cnt in 0 ..< groupArray!.count {
            let groupObj:NSManagedObject = groupArray![cnt] as! NSManagedObject
            groupObj.setValue(cnt, forKey: "order")
        }
        /* Save value to managedObjectContext */
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not update \(error), \(error!.userInfo)")
        }
        
        print("Object updated")
    }
    
    
    /*－－－－－－－－－－　CoreData　終了　－－－－－－－－－－*/

}
