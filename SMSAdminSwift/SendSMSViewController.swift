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
    var methodString:String = ""
    var groupList:Array<Dictionary<String,Any>>? = nil                 //グループのリスト　ABRecordID,name
    var groupListShowCount:Array<String>? = nil     //グループのリストの内訳表示用（EM,LS,SS)
    var groupListCount:Array<Any>? = nil            //Groupごとのレコード数 ABRecordID,count
    var allCount = 0                                //送信宛先総数
    var sentCount = 0                               //送信済み宛先
    var tmpSentCount = 0                            //一時保存送信済み宛先
    var mailAddressList:Array<NSString>? = nil      //送信対象メールリスト
    /**
    送信用SMSアドレス保存
    */
    var tmpSmsAddressList:Array<NSString>?=nil
    /**
    SMS送信用カウント
    */
    var tmpSmsSentCount:Int = 0
    /**
    SMS送信予定件数
    */
    var tmpSmsSentPlan:Int = 0
    /**
    SMS送信内容
    */
    var tmpSmsBody:String = ""
    
    /*－－－－－－－－－－　プロパティ　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　アウトレット　開始　－－－－－－－－－－*/
    @IBOutlet weak var recipientListName: UITextField!
    @IBOutlet weak var templateListName: UITextField!
    @IBOutlet weak var sendMailButton: UIButton!
    @IBOutlet weak var sendLongSMSButton: UIButton!
    @IBOutlet weak var sendShortSMSButton: UIButton!
    @IBOutlet weak var startCount: UITextField!
    @IBOutlet weak var endCount: UITextField!
    /*－－－－－－－－－－　アウトレット　終了　－－－－－－－－－－*/
    
    /*－－－－－－－－－－　Mail　開始　－－－－－－－－－－*/
    /**
      メール送信画面設定用
    */
    func configuredMailComposeViewController(mailTitle:NSString,mailBody: NSString,bccRecipients:Array<NSString> ) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients([recipientEmailAddress])
        /*　BCCをセット　*/
        mailComposerVC.setBccRecipients(bccRecipients)
        /*　件名をセット　*/
        mailComposerVC.setSubject(mailTitle as String)
        /*　本文をセット　*/
        mailComposerVC.setMessageBody(String(UTF8String: "\(mailBody)"), isHTML: false)
        
        return mailComposerVC
    }
    /**
    最大登録件数エラー表示
    @param maxNum 最大登録件数
    */
    func showAddressBookMaxErrorAlert(maxNum:Int) {
        let sendMailErrorAlert = UIAlertView(title: "アドレス件数", message: "グループの登録件数は\(maxNum)件までです。", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    /**
    最大送信件数エラー表示
    */
    func showMaxErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "最大送信件数", message: "一度に送信できる件数は１００件までです。", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    /**
    送信件数エラー表示
    */
    func showCountErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "送信件数", message: "送信件数をを確認の上再実行してください", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    /**
    メール送信エラー表示
    */
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "メール送信失敗", message: "メール設定を確認の上再実行してください", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    /**
    送信対象データなしエラー表示
    */
    func showNoDataErrorAlert() {
        let noDataErrorAlert = UIAlertView(title: "送信対象データなし", message: "送信対象のデータがありません", delegate: self, cancelButtonTitle: "OK")
        noDataErrorAlert.show()
    }
    /**
    送信完了メッセージ表示
    */
    func showMessageSentAlert() {
        let messageSentAlert = UIAlertView(title: "送信完了", message: "メッセージの送信が完了しました", delegate: self, cancelButtonTitle: "OK")
        messageSentAlert.show()
    }
    /**
    メール送信後初期化処理
    */
    func mailTempStatusInit() {
        /* 送信メール宛先リストにNULLをセット */
        mailAddressList = nil
        /* 宛先カウントを初期化 */
        allCount = 0
        tmpSentCount = 0
        sentCount = 0
        /* ボタンのキャプションとEnabledを設定 */
        sendMailButton.titleLabel?.text = "メール送信"
        sendLongSMSButton.enabled = true
        sendShortSMSButton.enabled = true
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch (result.rawValue) {
        case MFMailComposeResultCancelled.rawValue:
            print("Message was cancelled")
            mailTempStatusInit()
            controller.dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultFailed.rawValue:
            print("Message failed")
            /*　初期化 */
            mailTempStatusInit()
            controller.dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultSent.rawValue:
            /* 成功した場合 */
            print("Message was sent")
            /* 一時保存メール送信数を送信メール数に追加 */
            sentCount += tmpSentCount
            /* 履歴に保存 */
            saveToHistory()
            /* 表示を消す */
            controller.dismissViewControllerAnimated(true, completion: nil)
            /* すべての宛先に送信完了の場合 */
            if (sentCount >= allCount) {
                mailTempStatusInit()
            } else {
                sendMailButton.titleLabel?.text = "メール継続送信"
                sendLongSMSButton.enabled = false
                sendShortSMSButton.enabled = false
            }
        default:
            break;
        }
    }
    /*－－－－－－－－－－　Mail　終了　－－－－－－－－－－*/
    
    
    /**
    メール送信アクション
    */
    @IBAction func sendEMail(sender: UIButton) {
        /* 送信種別文字列をセット */
        methodString = "EM"
        /* 送信対象カウント取得 */
        var startCnt:Int = Int(startCount.text) ?? 0
        var endCnt:Int = Int(endCount.text) ?? 0
        
        /* Template */
        let temp_short = selectedTMP?.valueForKey("temp_short") as! NSString
        let temp_long = selectedTMP?.valueForKey("temp_long") as! NSString
        let temp_title = selectedTMP?.valueForKey("title") as! NSString
        /* Recipient */
        let ah = ABHandler()
        if (mailAddressList == nil) {
            mailAddressList = ah.getRecipientListByGroup(selectedRCP, typeofmethod: ABHandler.methodType.methodTypeMail)
            allCount = mailAddressList!.count
        }
        var list:Array<NSString> = []
        if ( allCount == 0 ) {
            mailAddressList = nil
            showNoDataErrorAlert()
        } else if (startCnt == 0 && endCnt == 0) {
            if (allCount - sentCount >= 100) {
                for (var cnt = 0 + sentCount  ; cnt < 99 + sentCount; cnt++) {
                    list.append(mailAddressList![cnt])
                }
            } else {
                for (var cnt = 0 + sentCount  ; cnt < allCount; cnt++) {
                    list.append(mailAddressList![cnt])
                }
                //list = mailAddressList!
            }
            /* 一時送信メールにセット */
            tmpSentCount = list.count
            /* メール送信 */
            let mailComposeViewController = configuredMailComposeViewController(temp_title,mailBody: temp_long,bccRecipients: list)
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        } else {
            /* エラーチェック */
            if startCnt > endCnt {
                showCountErrorAlert()
            } else if (endCnt == 0 || startCnt == 0){
                showCountErrorAlert()
            } else if endCnt  > allCount {
                showAddressBookMaxErrorAlert(allCount)
            } else if endCnt - startCnt > 99 {
                showMaxErrorAlert()
            } else {
                /* allCountに最終送信カウントを設定 */
                allCount = endCnt
                /*送信リスト作成*/
                for (var cnt = startCnt - 1 ; cnt < endCnt; cnt++) {
                    list.append(mailAddressList![cnt])
                }
                /* 一時送信メールにセット */
                tmpSentCount = startCnt + list.count
                /* メール送信 */
                let mailComposeViewController = configuredMailComposeViewController(temp_title,mailBody: temp_long,bccRecipients: list)
                if MFMailComposeViewController.canSendMail() {
                    self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
            }

        }
    }
    /**
    SMS送信アクション
    */
    func sendSMS(methodStr:String,body:String,title:String,methodType:ABHandler.methodType){
        /* 送信種別文字列をセット */
        methodString = methodStr
        /* メッセージ本体を保存 */
        tmpSmsBody = body
        /* 送信済みカウントをクリア */
        tmpSmsSentCount = 0
        /* 受信者リスト */
        let ah = ABHandler()
        var smsAddressList:Array<NSString> = ah.getRecipientListByGroup(selectedRCP, typeofmethod: methodType)
        /* 送信対象カウント取得 */
        var startCnt:Int = Int(startCount.text) ?? 0
        var endCnt:Int = Int(endCount.text) ?? 0
        allCount = smsAddressList.count
        if ( allCount == 0 ) {
            showNoDataErrorAlert()
        } else if (startCnt == 0 && endCnt == 0) {
            /* SMS送信リストを保存 */
            tmpSmsAddressList = smsAddressList
            tmpSmsSentPlan = smsAddressList.count
            /* SMS送信 */
            showSMSWindow(tmpSmsBody,list: pickAnAddressFromList())
        } else {
            /* エラーチェック */
            if startCnt > endCnt {
                showCountErrorAlert()
            } else if (endCnt == 0 || startCnt == 0){
                showCountErrorAlert()
            } else if endCnt  > allCount {
                showCountErrorAlert()
            } else if endCnt - startCnt > 99 {
                showMaxErrorAlert()
            } else {
                var list:Array<NSString> = []
                allCount = endCnt - startCnt + 1
                for (var cnt = startCnt - 1 ; cnt < endCnt; cnt++) {
                    list.append(smsAddressList[cnt])
                }
                /* SMS送信リストを保存 */
                tmpSmsAddressList = list
                tmpSmsSentPlan = list.count
                /* SMS送信 */
                showSMSWindow(tmpSmsBody,list: pickAnAddressFromList())
            }
        }
    }
    /**
    アドレスリストから指定の一件を取得
    */
    func pickAnAddressFromList() -> Array<NSString>{
        var ary:Array<NSString> = []
        ary.append(tmpSmsAddressList![tmpSmsSentCount])
        return ary
    }
    
    
    /**
    LongSMS送信アクション
    */
    @IBAction func sendLongSMS(sender: UIButton) {
        /* 送信種別文字列をセット */
        methodString = "LS"
        /* Template */
        let temp_long = selectedTMP?.valueForKey("temp_long") as! String
        let temp_title = selectedTMP?.valueForKey("title") as! String

        sendSMS(methodString,body: temp_long,title: temp_title,methodType: ABHandler.methodType.methodTypeLongSMS)
        
    }
    /**
    ShortSMS送信アクション
    */
    @IBAction func sendShortSMS(sender: UIButton) {
        /* 送信種別文字列をセット */
        methodString = "SS"
        /* Template */
        let temp_short = selectedTMP?.valueForKey("temp_short") as! String
        let temp_title = selectedTMP?.valueForKey("title") as! String
        
        sendSMS(methodString,body: temp_short,title: temp_title,methodType: ABHandler.methodType.methodTypeShortSMS)
    }
    
    func showSMSWindow(body:String,list:Array<NSString>){
        /* SMS送信 */
        let picker = MFMessageComposeViewController()
        picker.messageComposeDelegate = self;
        picker.recipients = list
        picker.body = String(UTF8String: "\(body)")
        presentViewController(picker, animated: true, completion: nil)
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func saveToHistory() {
        /* 履歴への追加処理 */
        let dh = DataHandler()
        /* 履歴Entitiy取得 */
        let entity = dh.createNewEntity("History")
        /* 今日の日付 */
        let today = NSDate()
        /* 宛先リスト名 */
        let rcp_name:NSString = recipientListName.text
        /* 件数 */
        let count = tmpSentCount
        /* 件名を取得 */
        let tmp_name:NSString = selectedTMP?.valueForKey("title") as? NSString ?? ""
        /* entityに追加*/
        entity.setValue(today, forKey: "sent_date")
        entity.setValue(rcp_name, forKey: "rcp_name")
        entity.setValue(tmp_name, forKey: "tmp_name")
        entity.setValue(methodString, forKey: "method")
        entity.setValue(count, forKey: "count")
        let context = entity.managedObjectContext
        /* Get ManagedObjectContext from AppDelegate */
        let managedContext:NSManagedObjectContext = entity.managedObjectContext!
        /* Error handling */
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
        print("object saved")
        /* 保存後元の画面に戻る */
    }
    
    
    /*－－－－－－－－－－　MFMessageComposeView　開始　－－－－－－－－－－*/
    /**
    送信完了後の処理
    */
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        /* カウントをクリア */
        allCount = 0
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            print("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            /* 成功した場合 */
            print("Message was sent")
            /* 送信完了件数を１増加 */
            tmpSmsSentCount++
            /* 送信完了件数と送信リストの数が同じなら*/
            if ( tmpSmsSentPlan == tmpSmsSentCount ) {
                //履歴用カウントに送信数をセット
                tmpSentCount = tmpSmsSentCount++
                /* 履歴に保存 */
                saveToHistory()
                showMessageSentAlert()
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    /*－－－－－－－－－－　MFMessageComposeView　終了　－－－－－－－－－－*/
    
    override func viewDidAppear(animated: Bool) {
        if tmpSmsSentPlan > 0 && (tmpSmsSentPlan > tmpSmsSentCount) {
            /* SMS送信 */
            showSMSWindow(tmpSmsBody,list: pickAnAddressFromList())
        }
    }
    
    func reOrder(src:Array<Dictionary<String,Any>>?) -> Array<Dictionary<String,Any>>? {
        var misList:Array<Dictionary<String,Any>>? = []
        var tmpList:Array<Dictionary<String,Any>>? = []
        var dics:Dictionary<Int,Dictionary<String,Any>> = Dictionary<Int,Dictionary<String,Any>>()
        var groupArray:Array<AnyObject>? = nil
        
        /* CoreDataよりGroupテーブルを読み出す */
        let dh = DataHandler()
        
        for g in src! {
            let res:NSManagedObject? = dh.fetchNSManagedObject("Group",targetColumn : "abrecord_id",targetValue : Int(g["abrecord_id"] as! Int32))
            if res == nil {
                misList!.append(g)
            } else {
                let order = res!.valueForKey("order") as! Int
                dics.updateValue(g, forKey: order)
            }
        }
        var keys = dics.keys.array
        keys.sortInPlace(<)
        for cnt in 0 ..< keys.count {
            tmpList!.append(dics[cnt]!)
        }
        
        return misList! + tmpList!
        
    }
    
    
    
    override func viewDidLoad() {
        /* タイトルをセット */
        self.title = "SMS送信"
        /* CoreDataよりHistoryテーブルを読み出す */
        let dh = DataHandler()
        //recipientArray = dh.fetchEntityData("Recipient")!
        //templateArray = dh.fetchEntityData("Template")!
        templateArray = dh.fetchEntityData("Template",sort:"order")!
        
        
        /* AddressBookよりGroupのリスト */
        let ah = ABHandler()
        groupList =  ah.getGroupList()
        groupList = reOrder(groupList)
        
        groupListCount = ah.getGroupRecordCountList()
        groupListShowCount = Array<String>()
        
        /* メソッドごとの人数をセット */
        for cnt in 0 ..< groupList!.count {
            var abdics:Dictionary<String,Any> = groupList![cnt]
            let recid:ABRecordID = abdics["abrecord_id"] as! ABRecordID
            var dics:Dictionary<String,String> = ah.getEachMethodCountByGroup(recid)
            groupListShowCount!.append( (abdics["name"] as! String) + " EM-" + (dics["EM"])! + " LS-" + (dics["LS"])! + " SS-" + (dics["SS"])!)
        }
        
        /* TextFieldに初期値を設定 */
        let list:Dictionary<String,Any> = groupList![0]
        let listCount:Dictionary<String,Any> = groupListCount![0] as! Dictionary<String,Any>
        
        print(listCount["count"]!)
        
        //recipientListName.text = (list["name"] as! String) + " - " + (listCount["count"] as! String) + "名"
        recipientListName.text = groupListShowCount![0]
        templateListName.text = templateArray?.first?.valueForKey("title") as! String
        /* 選択されたEntitiyに初期値を設定 */
        selectedRCP = list["abrecord_id"] as! ABRecordID
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
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
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
            //let list:Dictionary<String,Any> = groupList![row] as! Dictionary<String,Any>
            //let listCount:Dictionary<String,Any> = groupListCount![row] as! Dictionary<String,Any>
            return groupListShowCount![row] as String
            /* メソッドごとの人数を表示 */
            //return (list["name"] as! String) + " EM" + (dics["EM"])! + "名 LS" + (dics["LS"])! + "名 SS" + (dics["SS"])! + "名"
            //return (list["name"] as! String) + " - " + (listCount["count"] as! String) + "名"
            
        } else {
            let targetObj:NSManagedObject = templateArray![row] as! NSManagedObject
            return  targetObj.valueForKey("title") as! String
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
            let list:Dictionary<String,Any> = groupList![row]
            //let listCount:Dictionary<String,Any> = groupListCount![row] as! Dictionary<String,Any>
            selectedRCP = list["abrecord_id"] as! ABRecordID
            
            recipientListName.text = groupListShowCount![row]
            //recipientListName.text = (list["name"] as! String) + " - " + (listCount["count"] as! String) + "名"
        } else {
            let targetObj:NSManagedObject = templateArray![row] as! NSManagedObject
            selectedTMP = templateArray![row] as? NSManagedObject
            templateListName.text = targetObj.valueForKey("title") as! String
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
