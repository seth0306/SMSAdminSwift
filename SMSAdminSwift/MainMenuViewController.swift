//
//  MainMenuViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/06.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import AddressBook

class MainMenuViewController: UIViewController,UIAlertViewDelegate,UIPopoverPresentationControllerDelegate {
    
    override func viewDidLoad() {
        
        /* AddressBookのアクセスチェック */
        let abh = ABHandler()
        abh.startManagingAB()
        
        /* タイトルを設定 */
        self.title = "SMSAdminメニュー"
        
        /* group表示 */
        abh.showGroup()
    }
    
    
    /*　SMS送信画面表示　*/
    @IBAction func showSendSMS(sender: UIButton) {
        /* Templateがゼロの場合は遷移しない */
        let dh = DataHandler()
        if (dh.fetchEntityData("Template")!.count > 0) {
            performSegueWithIdentifier("showSendSMS", sender: nil)
        } else {
            let NoTemplateErrorAlert = UIAlertView(title: "Templateなし", message: "Templateが一つもありません", delegate: self, cancelButtonTitle: "OK")
            NoTemplateErrorAlert.show()
        }
    }
    
    /*　履歴画面表示　*/
    @IBAction func showHistory(sender: UIButton) {
        performSegueWithIdentifier("showHistorySMS", sender: nil)
    }
    /* テンプレート管理画面表示 */
    @IBAction func showTemplateAdmin(sender: UIButton) {
        performSegueWithIdentifier("showTemplateAdmin", sender: nil)
    }
    /*　受信者管理画面表示　*/
    @IBAction func showRecipientAdmin(sender: UIButton) {
        performSegueWithIdentifier("showRecipientAdmin", sender: nil)
    }
    
    
    
    
    /* データ取得 */
    /*
    @IBAction func getDataFromAB(sender: UIButton) {
        var alert = UIAlertController(title: "AddressBook", message:
            "AddressBookを取込みますか？", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: false, completion: nil)
        
        alert.addAction(UIAlertAction(title: "いいえ", style: UIAlertActionStyle.Default,
            handler: nil))
        alert.addAction(UIAlertAction(title: "はい", style: .Default, handler:
            {action in
                /*　AdressBookHandlerクラス　*/
                let abh = ABHandler()
                /* 取込を実施 */
                abh.saveToCoreData()
        }))
    }
    */
    
    /* test */
    /*
    func addCategory() {
        // 新しい View Controller をモーダル表示する
        let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("SelectItemPopover") as UIViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSizeMake(500,600)
        popover!.delegate = self
        //popover!.sourceView = self.view
        //popover!.sourceRect = CGRectMake(100,100,0,0)
        popover!.barButtonItem = self.navigationItem.backBarButtonItem
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    */
    
}
