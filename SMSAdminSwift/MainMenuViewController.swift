//
//  MainMenuViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/06.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import AddressBook

class MainMenuViewController: UIViewController,UIAlertViewDelegate {
    
    override func viewDidLoad() {
        
        /* AddressBookのアクセスチェック */
        let abh = ABHandler()
        abh.startManagingAB()
        
        /* タイトルを設定 */
        self.title = "SMSAdminメニュー"
    }
    
    
    /*　SMS送信画面表示　*/
    @IBAction func showSendSMS(sender: UIButton) {
        performSegueWithIdentifier("showSendSMS", sender: nil)
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
}
