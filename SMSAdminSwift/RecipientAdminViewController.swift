//
//  RecipientAdminViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/07.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class RecipientAdminViewController: UIViewController,ABPeoplePickerNavigationControllerDelegate {
    override func viewDidLoad() {
        self.title = "受信者管理"
        /* 追加ボタンを作成 */
        var right1 = UIBarButtonItem(title: "追加", style: .Plain, target: self, action: "showNewRecipient")
        if let font = UIFont(name: "HiraKakuProN-W6", size: 14 ) {
            right1.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        /* 追加ボタンをナビゲーションバーに追加 */
        self.navigationItem.rightBarButtonItems = [right1,editButtonItem()];
        
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

    
}
