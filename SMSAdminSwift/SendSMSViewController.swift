//
//  SendSMSViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/06.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
import AddressBookUI

class SendSMSViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate {
    /*－－－－－－－－－－　定数　開始　－－－－－－－－－－*/
    let recipientEmailAddress:NSString = "rikiya09048824527@gmail.com"

    /*－－－－－－－－－－　定数　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　プロパティ　開始　－－－－－－－－－－*/
    var recipientArray:Array<AnyObject>? = nil
    var templateArray:Array<AnyObject>? = nil
    var selectedRCP:Int32 = 0
    var selectedTMP:NSManagedObject? = nil
    var methodString:NSString = ""
    var groupList:Array<Any>? = nil
    /*－－－－－－－－－－　プロパティ　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　アウトレット　開始　－－－－－－－－－－*/
    @IBOutlet weak var recipientListName: UITextField!
    @IBOutlet weak var templateListName: UITextField!
    /*－－－－－－－－－－　アウトレット　終了　－－－－－－－－－－*/
    
    /*－－－－－－－－－－　Mail　開始　－－－－－－－－－－*/
    func configuredMailComposeViewController(mailTitle:NSString,mailBody: NSString,bccRecipients:Array<NSString> ) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients([recipientEmailAddress])
        /*　BCCをセット　*/
        mailComposerVC.setBccRecipients(bccRecipients)
        /*　件名をセット　*/
        mailComposerVC.setSubject(mailTitle)
        /*　本文をセット　*/
        mailComposerVC.setMessageBody(NSString(UTF8String: "\(mailBody)"), isHTML: false)
        
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "メール送信失敗", message: "メール設定を確認の上再実行してください", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func showNoDataErrorAlert() {
        let noDataErrorAlert = UIAlertView(title: "送信対象データなし", message: "送信対象のデータがありません", delegate: self, cancelButtonTitle: "OK")
        noDataErrorAlert.show()
    }
    
    
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch (result.value) {
        case MFMailComposeResultCancelled.value:
            println("Message was cancelled")
            controller.dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultFailed.value:
            println("Message failed")
            controller.dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultSent.value:
            /* 成功した場合 */
            println("Message was sent")
            /* 履歴に保存 */
            saveToHistory()
            controller.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    /*－－－－－－－－－－　Mail　終了　－－－－－－－－－－*/
    
    @IBAction func sendEMail(sender: UIButton) {
        /* 送信種別文字列をセット */
        methodString = "メール"
        /* Template */
        let temp_short = selectedTMP?.valueForKey("temp_short") as NSString
        let temp_long = selectedTMP?.valueForKey("temp_long") as NSString
        let temp_title = selectedTMP?.valueForKey("title") as NSString
        /* Recipient */
        let ah = ABHandler()
        var list:Array<NSString> = ah.getRecipientListByGroup(selectedRCP, typeofmethod: ABHandler.methodType.methodTypeMail)
        if ( list.count == 0 ) {
            showNoDataErrorAlert()
        } else {
            /* メール送信 */
            let mailComposeViewController = configuredMailComposeViewController(temp_title,mailBody: temp_long,bccRecipients: list)
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
    }
    
    
    @IBAction func sendLongSMS(sender: UIButton) {
        /* 送信種別文字列をセット */
        methodString = "長文SMS"
        /* Template */
        let temp_long = selectedTMP?.valueForKey("temp_long") as NSString
        let temp_title = selectedTMP?.valueForKey("title") as NSString
        
        /* 受信者リスト */
        let ah = ABHandler()
        var list:Array<NSString> = ah.getRecipientListByGroup(selectedRCP, typeofmethod: ABHandler.methodType.methodTypeLongSMS)
        
        if ( list.count == 0 ) {
            showNoDataErrorAlert()
        } else {
            /* SMS送信 */
            let picker = MFMessageComposeViewController()
            picker.messageComposeDelegate = self;
            picker.recipients = list
            picker.body = NSString(UTF8String: "\(temp_long)")
            presentViewController(picker, animated: true, completion: nil)
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendShortSMS(sender: UIButton) {
        /* 送信種別文字列をセット */
        methodString = "短文SMS"
        /* Template */
        let temp_short = selectedTMP?.valueForKey("temp_short") as NSString
        let temp_title = selectedTMP?.valueForKey("title") as NSString
        
        /* 受信者リスト */
        let ah = ABHandler()
        var list:Array<NSString> = ah.getRecipientListByGroup(selectedRCP, typeofmethod: ABHandler.methodType.methodTypeShortSMS)
        
        if ( list.count == 0 ) {
            showNoDataErrorAlert()
        } else {
            /* SMS送信 */
            let picker = MFMessageComposeViewController()
            picker.messageComposeDelegate = self;
            picker.recipients = list
            picker.body = NSString(UTF8String: "\(temp_short)")
            presentViewController(picker, animated: true, completion: nil)
            self.presentViewController(picker, animated: true, completion: nil)
        }

    }
    
    func saveToHistory() {
        /* 履歴への追加処理 */
        let dh = DataHandler()
        let entity = dh.createNewEntity("History")
        let today = NSDate()
        let rcp_name:NSString = recipientListName.text
        let tmp_name:NSString = selectedTMP?.valueForKey("title") as? NSString ?? ""
        /* entityに追加*/
        entity.setValue(today, forKey: "sent_date")
        entity.setValue(rcp_name, forKey: "rcp_name")
        entity.setValue(tmp_name, forKey: "tmp_name")
        entity.setValue(methodString, forKey: "method")
        let context = entity.managedObjectContext
        /* Get ManagedObjectContext from AppDelegate */
        let managedContext:NSManagedObjectContext = entity.managedObjectContext!
        /* Error handling */
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        println("object saved")
        /* 保存後元の画面に戻る */
    }
    
    
    /*－－－－－－－－－－　MFMessageComposeView　開始　－－－－－－－－－－*/
    /* 送信完了後の処理 */
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch (result.value) {
        case MessageComposeResultCancelled.value:
            println("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.value:
            println("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.value:
            /* 成功した場合 */
            println("Message was sent")
            /* 履歴に保存 */
            saveToHistory()
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    /*－－－－－－－－－－　MFMessageComposeView　終了　－－－－－－－－－－*/
    
    override func viewDidLoad() {
        /* タイトルをセット */
        self.title = "SMS送信"
        /* CoreDataよりHistoryテーブルを読み出す */
        let dh = DataHandler()
        recipientArray = dh.fetchEntityData("Recipient")!
        templateArray = dh.fetchEntityData("Template")!
        
        /* AddressBookよりGroupのリスト */
        let ah = ABHandler()
        groupList =  ah.getGroupList()
        
        /* TextFieldに初期値を設定 */
        let list:Dictionary<String,Any> = groupList![0] as Dictionary<String,Any>
        recipientListName.text = list["name"] as String
        templateListName.text = templateArray?.first?.valueForKey("title") as NSString
        /* 選択されたEntitiyに初期値を設定 */
        selectedRCP = list["abrecord_id"] as ABRecordID
        selectedTMP = templateArray?.first as? NSManagedObject
        
        /* 受信者リスト用PikcerView */
        let rcpPicker = UIPickerView()
        rcpPicker.delegate = self
        rcpPicker.dataSource = self
        rcpPicker.tag = 0
        recipientListName.inputView = rcpPicker
        
        /* テンプレートリスト用PickerView */
        let tmpPicker = UIPickerView()
        tmpPicker.delegate = self
        tmpPicker.dataSource = self
        tmpPicker.tag = 1
        templateListName.inputView = tmpPicker
        
    }

    /* 画面をタッチしたらKeyboardをしまう */
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }


    /*－－－－－－－－－－　PickerView　開始　－－－－－－－－－－*/
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return groupList!.count
            
        } else {
            return templateArray!.count
        }
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 0 {
            let list:Dictionary<String,Any> = groupList![row] as Dictionary<String,Any>
            return list["name"] as String
            
        } else {
            let targetObj:NSManagedObject = templateArray![row] as NSManagedObject
            return  targetObj.valueForKey("title") as NSString
        }
    }
    
    /*
    -(void)setTextField:(UITextField *)textField
    {
    _textField = textField;
    
    // DoneボタンとそのViewの作成
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle  = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    // 完了ボタンとSpacerの配置
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStyleBordered target:self action:@selector(pickerDoneClicked)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
    
    // Viewの配置
    textField.inputAccessoryView = keyboardDoneButtonView;
    }
    */
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            /*
            let targetObj:NSManagedObject = recipientArray![row] as NSManagedObject
            selectedRCP = recipientArray![row] as? NSManagedObject
            */
            let list:Dictionary<String,Any> = groupList![row] as Dictionary<String,Any>
            recipientListName.text = list["name"] as String
        } else {
            let targetObj:NSManagedObject = templateArray![row] as NSManagedObject
            selectedTMP = templateArray![row] as? NSManagedObject
            templateListName.text = targetObj.valueForKey("title") as NSString
        }
    }
    
    /*
    
    -(void)pickerDoneClicked {
    [_textField resignFirstResponder];
    }
    
    -(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
    {
    _textField.text = _pref_list[row];
    }
    */
    
    /*－－－－－－－－－－　PickerView　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　TextField　開始　－－－－－－－－－－*/
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    /*－－－－－－－－－－　TextField　終了　－－－－－－－－－－*/
    
}
