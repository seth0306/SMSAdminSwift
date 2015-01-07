//
//  MainMenuViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/06.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    /*　AdressBookHandlerクラス　*/
    let abh = ABHandler()
    
    override func viewDidLoad() {
        /* タイトルを設定 */
        self.title = "SMSAdminメニュー"
        /* AddressBookを取得 */
        abh.startManagingAB()
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
}
