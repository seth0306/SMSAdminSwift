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
        let right1 = UIBarButtonItem(title: "追加", style: .plain, target: self, action: #selector(TemplateAdminViewController.showNewTemplate))
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
        self.navigationItem.rightBarButtonItems = [right1,right2];
        
        /* CoreDataよりHistoryテーブルを読み出す */
        let dh = DataHandler()
        templateArray = dh.fetchEntityDataSort("Template",sort:"order")!
        //templateArray = dh.fetchEntityData("Template")!
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dh = DataHandler()
        templateArray = dh.fetchEntityDataSort("Template",sort:"order")!
        templateTableView.reloadData()
        super.viewWillAppear(animated)
    }
    /*－－－－－－－－－－　起動時処理　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　画面遷移　開始　－－－－－－－－－－*/
    
    /* テンプレート詳細画面（新規追加）を表示 */
    @objc func showNewTemplate() {
        performSegue(withIdentifier: "showNewTemplate", sender: self)
    }

    /* テンプレート詳細画面（修正）を表示 */
    func showTemplateModify() {
        performSegue(withIdentifier: "showTemplateModify", sender: self)
    }
    
    /* 画面間データ受け渡し */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showTemplateModify" {
            let ctrl:TemplateModifyViewController = segue.destination as! TemplateModifyViewController
            ctrl.title = "テンプレート修正"
            ctrl.targetButtonTitle = "更新"
            ctrl.targetObj = templateObj
            
        } else if segue.identifier == "showNewTemplate" {
            let ctrl:TemplateModifyViewController = segue.destination as! TemplateModifyViewController
            ctrl.title = "新規テンプレート"
            ctrl.targetButtonTitle = "保存"
        }
    }
    
    /*－－－－－－－－－－　画面遷移　終了　－－－－－－－－－－*/
    
    /*－－－－－－－－－－　テーブル関係　開始　－－－－－－－－－－*/
    
    /* TableView内のセクション数を返す */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    /* TableView内のCellの表示 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell: HistoryTableViewCell = HistoryTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "hisotryTableCell")
        let  cell = tableView.dequeueReusableCell(withIdentifier: "templateTableCell") as! TemplateTableViewCell
        let row = (indexPath as NSIndexPath).row
        let template_title:NSString? = templateArray![row].value(forKey: "title") as? NSString
        let template_summary:NSString? = templateArray![row].value(forKey: "summary") as? NSString
        /* セルに値を設定 */
        cell.template_summary.text = template_summary as String?
        cell.template_title.text = template_title as String?
        return cell
    }
    
    /* TableView内のセクション内の行数を返す */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templateArray!.count
    }
    
    /* headerの高さを指定 */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  32
    }
    
    /* headerを作成 */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "templateTableHeaderCell") as! TemplateTableViewHeaderCell
        headerCell.backgroundColor = UIColor.cyan
        return headerCell
    }
    
    //セルが選択された場合の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = (indexPath as NSIndexPath).row
        templateObj = templateArray![row] as? NSManagedObject
        showTemplateModify()
    }
    
    //UITableViewDelegateに追加されたメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    /* 削除許可 */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /* 編集モード */
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        print(#function)
        self.templateTableView.setEditing(editing, animated: animated)
    }
    /* 編集・削除処理 */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            /* 削除対象オブジェクトの取得 */
            let removeObj:NSManagedObject = templateArray![(indexPath as NSIndexPath).row] as! NSManagedObject;
            /* CoreDataから削除　*/
            let dh = DataHandler()
            dh.deleteSpecifiedEntity(removeObj)
            /*　tableViewから削除　*/
            templateArray!.remove(at: (indexPath as NSIndexPath).row)
            self.templateTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        }
    }
    
    //セルの移動を許可
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if (sourceIndexPath as NSIndexPath).section == (destinationIndexPath as NSIndexPath).section { // 移動元と移動先は同じセクションです。
            if (destinationIndexPath as NSIndexPath).row < templateArray!.count {
                let item:NSManagedObject = templateArray![(sourceIndexPath as NSIndexPath).row] as! NSManagedObject// 移動対象を保持します。
                templateArray!.remove(at: (sourceIndexPath as NSIndexPath).row)// 配列から一度消します。
                templateArray!.insert(item, at: (destinationIndexPath as NSIndexPath).row)// 保持しておいた対象を挿入します。
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        updateOrder()
    }
    
    /*－－－－－－－－－－　テーブル関係　終了　－－－－－－－－－－*/
    
    /*　既存のEntityを修正　*/
    func updateOrder(){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
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
            print("Could not update \(String(describing:error)), \(error!.userInfo)")
        }
        
        print("Object updated")
    }
}
