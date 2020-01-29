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
    var groupArray:Array<AnyObject>? = []
    var groupObj:NSManagedObject? = nil
    var groupList:Array<Dictionary<String,Any>>? = nil
    /*－－－－－－－－－－　プロパティ　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　アウトレット　開始　－－－－－－－－－－*/
    @IBOutlet weak var GroupOrderTableView: UITableView!
    /*－－－－－－－－－－　アウトレット　終了　－－－－－－－－－－*/
    
    override func viewDidLoad() {
        self.title = "グループ表示順設定"
        
        /* 保存ボタンを作成 */
        let right1 = UIBarButtonItem(title: "削除", style: .plain, target: self, action: #selector(GroupOrderViewController.deleteAllGroup))
        if let font = UIFont(name: "HiraKakuProN-W6", size: 14 ) {
            right1.setTitleTextAttributes([NSAttributedString.Key.font: font], for: UIControl.State())
        }
        
        /* 編集ボタンを作成 */
        let right2 = self.editButtonItem
        if let font = UIFont(name: "HiraKakuProN-W6", size: 14 ) {
            right2.setTitleTextAttributes([NSAttributedString.Key.font: font], for: UIControl.State())
        }
        right2.setValue("編集", forKey: "title")
        
        
        /* 追加ボタンをナビゲーションバーに追加 */
        self.navigationItem.rightBarButtonItems = [right2]
        //self.navigationItem.rightBarButtonItems = [right2,right1]
        
        /* CoreDataよりGroupテーブルを読み出す */
        let dh = DataHandler()
        groupArray = dh.fetchEntityDataSort("Group",sort:"order")!
        
        /* AddressBookより読み出し */
        let cn = CNHandler()
        groupList = cn.getGroupList()
        
        
        
        /* AddressBookのGroupとEntity Groupの内容を比較 */
        for_ab:for cnt in 0..<groupList!.count {
            let abObj:Dictionary<String,Any> = groupList![cnt]
            let abid = abObj["groupIdentifier"] as! String
            var noMatch: Bool = true
            for_g:for gObj in groupArray! {
                let gid = (gObj as! NSManagedObject).value(forKey: "groupIdentifier") as? String
                if abid == gid {
                    gObj.setValue(abObj["name"]as! String, forKey: "name")
                    noMatch = false
                    break for_g
                }
            }
            if noMatch {
                //いなければEntitiyを作成の上０番目に追加
                let nsm:NSManagedObject = createNewEntity(abid,name: abObj["name"] as! String,order :0)
                groupArray!.insert(nsm, at: 0)
            }
        }
        
        /* Entity GroupとAddressBookのGroupとの内容を比較 */
        var idxAry:Array<AnyObject> = Array<AnyObject>()
        for_g:for gObj in groupArray! {
            let gid = (gObj as! NSManagedObject).value(forKey: "groupIdentifier") as? String
            var noMatch: Bool = true
            for_ab:for cnt in 0..<groupList!.count {
                let abObj:Dictionary<String,Any> = groupList![cnt]
                let abid = abObj["groupIdentifier"] as! String
                if abid == gid! {
                    noMatch = false
                    break for_ab
                }
            }
            if noMatch {
                //idxAry.append(gid!)
                idxAry.append(gObj)
            }
        }
        for gObj in idxAry {
            //いなければEntitiyを削除
            //print((gObj as! NSManagedObject).value(forKey: "order") as? Int)
            let odr = (gObj as! NSManagedObject).value(forKey: "order") as? Int
            
            let max = groupArray!.count
            
            var removeIdx:Int? = nil
            for rCnt in 0..<max {
                print(rCnt)
                if odr == ((groupArray![rCnt]) as! NSManagedObject).value(forKey: "order") as? Int {
                    removeIdx = rCnt
                }
            }
            if removeIdx != nil {
                groupArray!.remove(at: removeIdx!)
            }
            //groupArray!.remove(at: ((gObj as! NSManagedObject).value(forKey: "order") as? Int)!)
            
            dh.deleteSpecifiedEntity(gObj as! NSManagedObject)
        }
        /* DBに書き込み */
        modifyExist()
    }
    
    
    /*
    編集ボタンが押された際に呼び出される
    */
    override func setEditing(_ editing: Bool, animated: Bool) {
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
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    
    /* TableView内のセクション数を返す */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    /* TableView内のCellの表示 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let  cell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as! GroupOrderTableViewCell
        let row = (indexPath as NSIndexPath).row
        
        let groupName:String? = groupArray![row].value(forKey: "name") as? String
        
        //let groupName:NSString? = groupArray![row].value(forKey: "name") as? String
        
        /* セルに値を設定 */
        cell.groupName.text = groupName
        return cell
    }
    
    /* TableView内のセクション内の行数を返す */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray!.count
    }
    
    /* headerの高さを指定 */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  32
    }
    
    /* headerを作成 */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "groupHeaderCell") as! GroupOrderTableViewHeaderCell
        headerCell.backgroundColor = UIColor.cyan
        return headerCell
    }
    
    //セルが選択された場合の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //特になし
    }
    //セルの移動を許可
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if (sourceIndexPath as NSIndexPath).section == (destinationIndexPath as NSIndexPath).section { // 移動元と移動先は同じセクションです。
            if (destinationIndexPath as NSIndexPath).row < groupArray!.count {
                let item:NSManagedObject = groupArray![(sourceIndexPath as NSIndexPath).row] as! NSManagedObject// 移動対象を保持します。
                groupArray!.remove(at: (sourceIndexPath as NSIndexPath).row)// 配列から一度消します。
                groupArray!.insert(item, at: (destinationIndexPath as NSIndexPath).row)// 保持しておいた対象を挿入します。
            }
        }
    }
    
    /*－－－－－－－－－－　テーブル関係　終了　－－－－－－－－－－*/
    
    /*－－－－－－－－－－　CoreData　開始　－－－－－－－－－－*/
    
    /* Entitiyの追加・更新処理 */
    func saveGroupOrder() {
        
        modifyExist()
        
        /* 保存後元の画面に戻る */
        self.navigationController?.popViewController(animated: true)
    }
    /* Entitiyの追加・更新処理 */
    @objc func deleteAllGroup() {
        
        let dh = DataHandler()
        
        for gObj in groupArray! {
            dh.deleteSpecifiedEntity(gObj as! NSManagedObject)
        }
        
        /* 保存後元の画面に戻る */
        self.navigationController?.popViewController(animated: true)
    }
    
    /*　新しいEntityを追加　*/
    func createNewEntity(_ groupIdentifier:String, name:String, order:Int32) -> NSManagedObject {
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        /* Create new ManagedObject */
        let entity = NSEntityDescription.entity(forEntityName: "Group", in: managedContext)
        let groupObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        /* Set the name attribute using key-value coding */
        groupObject.setValue(name, forKey: "name")
        groupObject.setValue(groupIdentifier, forKey: "groupIdentifier")
        groupObject.setValue(Int(order), forKey: "order")
        
        /* Error handling */
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(String(describing:error)), \(String(describing: error?.userInfo))")
        }
        print("object saved")
        return groupObject
    }
    
    
    /*　既存のEntityを修正　*/
    func modifyExist(){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
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
            print("Could not update \(String(describing:error)), \(error!.userInfo)")
        }
        
        print("Object updated")
    }
    /*－－－－－－－－－－　CoreData　終了　－－－－－－－－－－*/
}
