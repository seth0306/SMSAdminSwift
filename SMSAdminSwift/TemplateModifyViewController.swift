//
//  TemplateModifyViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/08.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import CoreData

class TemplateModifyViewController: UIViewController {
    
    /*－－－－－－－－－－　プロパティ　開始　－－－－－－－－－－*/
    /* 対象のCoreData Object */
    var targetObj:NSManagedObject? = nil
    var targetButtonTitle :String = ""
    /*－－－－－－－－－－　プロパティ　終了　－－－－－－－－－－*/
    
    /*－－－－－－－－－－　アウトレット　開始　－－－－－－－－－－*/
    
    /* テンプレートのタイトル */
    @IBOutlet weak var template_title: UITextField!
    /*　テンプレートのサマリー　*/
    @IBOutlet weak var template_summary: UITextView!
    /*　短いテンプレート　*/
    @IBOutlet weak var template_short: UITextView!
    /*　長いテンプレート　*/
    @IBOutlet weak var template_long: UITextView!
    
    /*－－－－－－－－－－　アウトレット　終了　－－－－－－－－－－*/
    
    /*－－－－－－－－－－　起動時処理　開始　－－－－－－－－－－*/
    
    override func viewDidLoad() {
        /* 保存ボタンを作成 */
        var right1 = UIBarButtonItem(title: targetButtonTitle, style: .Plain, target: self, action: "saveTemplate")
        if let font = UIFont(name: "HiraKakuProN-W6", size: 14) {
            right1.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        /* 追加ボタンをナビゲーションバーに追加 */
        self.navigationItem.rightBarButtonItems = [right1];
        
        /*　更新の場合既存のEntityの内容をセット　*/
        if targetObj != nil {
            /* Objectからデータを取り出す */
            let t_title:NSString? = targetObj!.valueForKey("title") as? NSString
            let t_summary:NSString? = targetObj!.valueForKey("summary") as? NSString
            let t_short:NSString? = targetObj!.valueForKey("temp_short") as? NSString
            let t_long:NSString? = targetObj!.valueForKey("temp_long") as? NSString
            /* データを画面にセット */
            template_title.text = t_title
            template_summary.text = t_summary
            template_short.text = t_short
            template_long.text = t_long
        }
    }

    /*－－－－－－－－－－　起動時処理　終了　－－－－－－－－－－*/
    
    /*－－－－－－－－－－　CoreData　開始　－－－－－－－－－－*/
    /*　新しいEntityを追加　*/
    func createNewEntity(){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        /* Create new ManagedObject */
        let entity = NSEntityDescription.entityForName("Template", inManagedObjectContext: managedContext)
        let templateObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        /* Set the name attribute using key-value coding */
        templateObject.setValue(template_title.text, forKey: "title")
        templateObject.setValue(template_summary.text, forKey: "summary")
        templateObject.setValue(template_short.text, forKey: "temp_short")
        templateObject.setValue(template_long.text, forKey: "temp_long")
        
        /* Error handling */
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        println("object saved")
    }
    
    /*　既存のEntityを修正　*/
    func modifyExist(){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        /* Set the name attribute using key-value coding */
        targetObj!.setValue(template_title.text, forKey: "title")
        targetObj!.setValue(template_summary.text, forKey: "summary")
        targetObj!.setValue(template_short.text, forKey: "temp_short")
        targetObj!.setValue(template_long.text, forKey: "temp_long")
        
        /* Save value to managedObjectContext */
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not update \(error), \(error!.userInfo)")
        }
        
        println("Object updated")
    }
    /* Entitiyの追加・更新処理 */
    func saveTemplate() {
        
        if targetButtonTitle == "保存" {
            createNewEntity()
        } else if targetButtonTitle == "更新" {
            modifyExist()
        }
        
        /* 保存後元の画面に戻る */
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /*－－－－－－－－－－　CoreData　終了　－－－－－－－－－－*/
}
