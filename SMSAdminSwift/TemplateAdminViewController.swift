//
//  TemplateAdminViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/07.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import CoreData

class TemplateAdminViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    /*－－－－－－－－－－　プロパティ　開始　－－－－－－－－－－*/
    var templateArray:Array<AnyObject>? = nil
    var templateObj:NSManagedObject? = nil
    /*－－－－－－－－－－　プロパティ　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　アウトレット　開始　－－－－－－－－－－*/
    @IBOutlet weak var templateTableView: UITableView!
    /*－－－－－－－－－－　アウトレット　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　起動時処理　開始　－－－－－－－－－－*/
    override func viewDidLoad() {
        self.title = "テンプレート管理"
        
        /* 追加ボタンを作成 */
        let right1 = UIBarButtonItem(title: "追加", style: .Plain, target: self, action: #selector(TemplateAdminViewController.showNewTemplate))
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
        self.navigationItem.rightBarButtonItems = [right1,right2];
        
        /* CoreDataよりHistoryテーブルを読み出す */
        let dh = DataHandler()
        templateArray = dh.fetchEntityDataSort("Template",sort:"order")!
        //templateArray = dh.fetchEntityData("Template")!
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let dh = DataHandler()
        templateArray = dh.fetchEntityDataSort("Template",sort:"order")!
        templateTableView.reloadData()
        super.viewWillAppear(animated)
    }
    /*－－－－－－－－－－　起動時処理　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　画面遷移　開始　－－－－－－－－－－*/
    
    /* テンプレート詳細画面（新規追加）を表示 */
    func showNewTemplate() {
        performSegueWithIdentifier("showNewTemplate", sender: self)
    }

    /* テンプレート詳細画面（修正）を表示 */
    func showTemplateModify() {
        performSegueWithIdentifier("showTemplateModify", sender: self)
    }
    
    /* 画面間データ受け渡し */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showTemplateModify" {
            let ctrl:TemplateModifyViewController = segue.destinationViewController as! TemplateModifyViewController
            ctrl.title = "テンプレート修正"
            ctrl.targetButtonTitle = "更新"
            ctrl.targetObj = templateObj
            
        } else if segue.identifier == "showNewTemplate" {
            let ctrl:TemplateModifyViewController = segue.destinationViewController as! TemplateModifyViewController
            ctrl.title = "新規テンプレート"
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
        
        //let cell: HistoryTableViewCell = HistoryTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "hisotryTableCell")
        let  cell = tableView.dequeueReusableCellWithIdentifier("templateTableCell") as! TemplateTableViewCell
        let row = indexPath.row
        let template_title:NSString? = templateArray![row].valueForKey("title") as? NSString
        let template_summary:NSString? = templateArray![row].valueForKey("summary") as? NSString
        /* セルに値を設定 */
        cell.template_summary.text = template_summary as? String
        cell.template_title.text = template_title as? String
        return cell
    }
    
    /* TableView内のセクション内の行数を返す */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templateArray!.count
    }
    
    /* headerの高さを指定 */
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  32
    }
    
    /* headerを作成 */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("templateTableHeaderCell") as! TemplateTableViewHeaderCell
        headerCell.backgroundColor = UIColor.cyanColor()
        return headerCell
    }
    
    //セルが選択された場合の処理
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        templateObj = templateArray![row] as? NSManagedObject
        showTemplateModify()
    }
    
    //UITableViewDelegateに追加されたメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    /* 削除許可 */
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    /* 編集モード */
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        print(#function)
        self.templateTableView.setEditing(editing, animated: animated)
    }
    /* 編集・削除処理 */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            /* 削除対象オブジェクトの取得 */
            let removeObj:NSManagedObject = templateArray![indexPath.row] as! NSManagedObject;
            /* CoreDataから削除　*/
            let dh = DataHandler()
            dh.deleteSpecifiedEntity(removeObj)
            /*　tableViewから削除　*/
            templateArray!.removeAtIndex(indexPath.row)
            self.templateTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    //セルの移動を許可
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.section == destinationIndexPath.section { // 移動元と移動先は同じセクションです。
            if destinationIndexPath.row < templateArray!.count {
                let item:NSManagedObject = templateArray![sourceIndexPath.row] as! NSManagedObject// 移動対象を保持します。
                templateArray!.removeAtIndex(sourceIndexPath.row)// 配列から一度消します。
                templateArray!.insert(item, atIndex: destinationIndexPath.row)// 保持しておいた対象を挿入します。
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        updateOrder()
    }
    
    /*－－－－－－－－－－　テーブル関係　終了　－－－－－－－－－－*/
    
    /*　既存のEntityを修正　*/
    func updateOrder(){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        for cnt in 0 ..< templateArray!.count {
            let templateObj:NSManagedObject = templateArray![cnt] as! NSManagedObject
            templateObj.setValue(cnt, forKey: "order")
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
}
