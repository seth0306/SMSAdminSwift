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

class SendSMSViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,MFMessageComposeViewControllerDelegate {
    /*－－－－－－－－－－　プロパティ　開始　－－－－－－－－－－*/
    var recipientArray:Array<AnyObject>? = nil
    var templateArray:Array<AnyObject>? = nil
    var selectedRCP:NSManagedObject? = nil
    var selectedTMP:NSManagedObject? = nil
    
    /*－－－－－－－－－－　プロパティ　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　アウトレット　開始　－－－－－－－－－－*/
    @IBOutlet weak var recipientListName: UITextField!
    @IBOutlet weak var templateListName: UITextField!
    /*－－－－－－－－－－　アウトレット　終了　－－－－－－－－－－*/
    
    @IBAction func sendSMS(sender: UIButton) {
        let picker = MFMessageComposeViewController()
        picker.messageComposeDelegate = self;
        /* Template */
        let temp_short = selectedTMP?.valueForKey("temp_short") as NSString
        let temp_long = selectedTMP?.valueForKey("temp_long") as NSString
        let temp_title = selectedTMP?.valueForKey("title") as NSString
        picker.body = NSString(UTF8String: "\(temp_short)")
        /* 受信者リスト */
        let recipientSet = selectedRCP!.mutableSetValueForKey("addressBookUnits") as NSMutableSet
        let phoneArray:NSMutableArray = NSMutableArray()
        for v in recipientSet {
            if v.valueForKey("selected") as? Bool ?? false {
                phoneArray.addObject(v.valueForKey("phone") as NSString)
            }
        }
        picker.recipients = phoneArray
        presentViewController(picker, animated: true, completion: nil)
            
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
//送信完了後元に戻る
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    override func viewDidLoad() {
        /* タイトルをセット */
        self.title = "SMS送信"
        /* CoreDataよりHistoryテーブルを読み出す */
        let dh = DataHandler()
        recipientArray = dh.fetchEntityData("Recipient")!
        templateArray = dh.fetchEntityData("Template")!
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


    /*－－－－－－－－－－　PickerView　開始　－－－－－－－－－－*/
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return recipientArray!.count
        } else {
            return templateArray!.count
        }
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 0 {
            let targetObj:NSManagedObject = recipientArray![row] as NSManagedObject
            return  targetObj.valueForKey("name") as NSString
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
            let targetObj:NSManagedObject = recipientArray![row] as NSManagedObject
            selectedRCP = recipientArray![row] as? NSManagedObject
            recipientListName.text = targetObj.valueForKey("name") as NSString
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
