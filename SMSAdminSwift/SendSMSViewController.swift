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
    //let recipientEmailAddress:String = "rikiya09048824527@gmail.com"
    var recipientEmailAddress:String = ""
    
    /*－－－－－－－－－－　定数　終了　－－－－－－－－－－*/
    /*－－－－－－－－－－　プロパティ　開始　－－－－－－－－－－*/
    var recipientArray:Array<AnyObject>? = nil
    var templateArray:Array<AnyObject>? = nil
    //var selectedRCP:Int32 = 0
    var selectedRCP:String = ""
    
    var selectedTMP:NSManagedObject? = nil
    var methodString:String = ""
    var groupList:Array<Dictionary<String,Any>>? = nil                 //グループのリスト　ABRecordID,name
    var groupListShowCount:Array<String>? = nil     //グループのリストの内訳表示用（EM,LS,SS)
    var groupListCount:Array<Any>? = nil            //Groupごとのレコード数 ABRecordID,count
    var allCount = 0                                //送信宛先総数
    var sentCount = 0                               //送信済み宛先
    var tmpSentCount = 0                            //一時保存送信済み宛先
    var mailAddressList:Array<NSString>? = nil      //送信対象メールリスト
    
    var props:Dictionary<String,String> = Dictionary<String,String>()
    let pkey_fromMail:String = "fromMailAddress"
    let defaulfromMail:String = "rikiya09048824527@gmail.com"

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
    func configuredMailComposeViewController(_ mailTitle:NSString,mailBody: NSString,bccRecipients:[String] ) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        //mailComposerVC.setToRecipients([recipientEmailAddress])
        /*　BCCをセット　*/
        mailComposerVC.setBccRecipients(bccRecipients)
        /*　件名をセット　*/
        mailComposerVC.setSubject(mailTitle as String)
        /*　本文をセット　*/
        mailComposerVC.setMessageBody(String(validatingUTF8: "\(mailBody)")!, isHTML: false)
        
        return mailComposerVC
    }
    /**
    最大登録件数エラー表示
    @param maxNum 最大登録件数
    */
    func showAddressBookMaxErrorAlert(_ maxNum:Int) {
        let alertController = UIAlertController(title: "アドレス件数", message: "グループの登録件数は\(maxNum)件までです。", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) {
            action in NSLog("いいえボタンが押されました")
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
        //let sendMailErrorAlert = UIAlertView(title: "アドレス件数", message: "グループの登録件数は\(maxNum)件までです。", delegate: self, cancelButtonTitle: "OK")
        //sendMailErrorAlert.show()
    }
    /**
    最大送信件数エラー表示
    */
    func showMaxErrorAlert() {
        let alertController = UIAlertController(title: "最大送信件数", message: "一度に送信できる件数は１００件までです。", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) {
            action in NSLog("いいえボタンが押されました")
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        //let sendMailErrorAlert = UIAlertView(title: "最大送信件数", message: "一度に送信できる件数は１００件までです。", delegate: self, cancelButtonTitle: "OK")
        //sendMailErrorAlert.show()
    }
    /**
    送信件数エラー表示
    */
    func showCountErrorAlert() {
        let alertController = UIAlertController(title: "送信件数", message: "送信件数をを確認の上再実行してください", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) {
            action in NSLog("いいえボタンが押されました")
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        //let sendMailErrorAlert = UIAlertView(title: "送信件数", message: "送信件数をを確認の上再実行してください", delegate: self, cancelButtonTitle: "OK")
        //sendMailErrorAlert.show()
    }
    /**
    メール送信エラー表示
    */
    func showSendMailErrorAlert() {
        let alertController = UIAlertController(title: "メール送信失敗", message: "メール設定を確認の上再実行してください", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) {
            action in NSLog("いいえボタンが押されました")
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        //let sendMailErrorAlert = UIAlertView(title: "メール送信失敗", message: "メール設定を確認の上再実行してください", delegate: self, cancelButtonTitle: "OK")
        //sendMailErrorAlert.show()
    }
    /**
    送信対象データなしエラー表示
    */
    func showNoDataErrorAlert() {
        let alertController = UIAlertController(title: "送信対象データなし", message: "送信対象のデータがありません", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) {
            action in NSLog("いいえボタンが押されました")
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        //let noDataErrorAlert = UIAlertView(title: "送信対象データなし", message: "送信対象のデータがありません", delegate: self, cancelButtonTitle: "OK")
        //noDataErrorAlert.show()
    }
    /**
    送信完了メッセージ表示
    */
    func showMessageSentAlert() {
        let alertController = UIAlertController(title: "送信完了", message: "メッセージの送信が完了しました", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) {
            action in NSLog("いいえボタンが押されました")
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        //let messageSentAlert = UIAlertView(title: "送信完了", message: "メッセージの送信が完了しました", delegate: self, cancelButtonTitle: "OK")
        //messageSentAlert.show()
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
        sendLongSMSButton.isEnabled = true
        sendShortSMSButton.isEnabled = true
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch (result.rawValue) {
        case MFMailComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            mailTempStatusInit()
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed.rawValue:
            print("Message failed")
            /*　初期化 */
            mailTempStatusInit()
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent.rawValue:
            /* 成功した場合 */
            print("Message was sent")
            /* 一時保存メール送信数を送信メール数に追加 */
            sentCount += tmpSentCount
            /* 履歴に保存 */
            saveToHistory()
            /* 表示を消す */
            controller.dismiss(animated: true, completion: nil)
            /* すべての宛先に送信完了の場合 */
            if (sentCount >= allCount) {
                mailTempStatusInit()
            } else {
                sendMailButton.titleLabel?.text = "メール継続送信"
                sendLongSMSButton.isEnabled = false
                sendShortSMSButton.isEnabled = false
            }
        default:
            break;
        }
    }
    /*－－－－－－－－－－　Mail　終了　－－－－－－－－－－*/
    
    
    /**
    メール送信アクション
    */
    @IBAction func sendEMail(_ sender: UIButton) {
        /* 送信種別文字列をセット */
        methodString = "EM"
        /* 送信対象カウント取得 */
        let startCnt:Int = Int(startCount.text!) ?? 0
        let endCnt:Int = Int(endCount.text!) ?? 0
        
        /* Template */
        //let temp_short = selectedTMP?.valueForKey("temp_short") as! NSString
        let temp_long = selectedTMP?.value(forKey: "temp_long") as! NSString
        let temp_title = selectedTMP?.value(forKey: "title") as! NSString
        /* Recipient */
        //let ah = ABHandler()
        
        let cn = CNHandler()
        if (mailAddressList == nil) {
            mailAddressList = cn.getRecipientListByGroup(selectedRCP, typeofmethod: CNHandler.methodType.methodTypeMail) as Array<NSString>?
        }
        allCount = mailAddressList!.count
        
        var list:[String] = []
        if ( allCount == 0 ) {
            mailAddressList = nil
            showNoDataErrorAlert()
        } else if (startCnt == 0 && endCnt == 0) {
            if (allCount - sentCount >= 100) {
                //for (var cnt = 0 + sentCount  ; cnt < 99 + sentCount; cnt += 1) {
                for cnt in 0 + sentCount   ..< 99 + sentCount {
                    list.append(mailAddressList![cnt] as String)
                }
            } else {
                for cnt in 0 + sentCount   ..< allCount {
                    list.append(mailAddressList![cnt] as String)
                }
                //list = mailAddressList!
            }
            /* 一時送信メールにセット */
            tmpSentCount = list.count
            /* メール送信 */
            let mailComposeViewController = configuredMailComposeViewController(temp_title,mailBody: temp_long,bccRecipients: list)
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
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
                for cnt in startCnt - 1  ..< endCnt {
                    list.append(mailAddressList![cnt] as String)
                }
                /* 一時送信メールにセット */
                tmpSentCount = startCnt + list.count
                /* メール送信 */
                let mailComposeViewController = configuredMailComposeViewController(temp_title,mailBody: temp_long,bccRecipients: list)
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
            }

        }
    }
    /**
    SMS送信アクション
    */
    func sendSMS(_ methodStr:String,body:String,title:String,methodType:CNHandler.methodType){
        /* 送信種別文字列をセット */
        methodString = methodStr
        /* メッセージ本体を保存 */
        tmpSmsBody = body
        /* 送信済みカウントをクリア */
        tmpSmsSentCount = 0
        
        /* 受信者リスト */
        var smsAddressList:Array<NSString> = Array<NSString>()
        let cn = CNHandler()
        smsAddressList = cn.getRecipientListByGroup(selectedRCP, typeofmethod: methodType) as Array<NSString>
        allCount = smsAddressList.count
        
        /* 送信対象カウント取得 */
        let startCnt:Int = Int(startCount.text!) ?? 0
        let endCnt:Int = Int(endCount.text!) ?? 0
        
        
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
                for cnt in startCnt - 1  ..< endCnt {
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
    func pickAnAddressFromList() -> [String]{
        var ary:[String] = []
        ary.append(tmpSmsAddressList![tmpSmsSentCount] as String)
        return ary
    }
    
    
    /**
    LongSMS送信アクション
    */
    @IBAction func sendLongSMS(_ sender: UIButton) {
        /* 送信種別文字列をセット */
        methodString = "LS"
        /* Template */
        let temp_long = selectedTMP?.value(forKey: "temp_long") as! String
        let temp_title = selectedTMP?.value(forKey: "title") as! String
        
        sendSMS(methodString,body: temp_long,title: temp_title,methodType: CNHandler.methodType.methodTypeLongSMS)
        
    }
    /**
    ShortSMS送信アクション
    */
    @IBAction func sendShortSMS(_ sender: UIButton) {
        /* 送信種別文字列をセット */
        methodString = "SS"
        /* Template */
        let temp_short = selectedTMP?.value(forKey: "temp_short") as! String
        let temp_title = selectedTMP?.value(forKey: "title") as! String
        
        sendSMS(methodString,body: temp_short,title: temp_title,methodType: CNHandler.methodType.methodTypeShortSMS)
        
    }
    
    func showSMSWindow(_ body:String,list:[String]){
        /* SMS送信 */
        /*
        let picker = MFMessageComposeViewController()
        picker.messageComposeDelegate = self;
        picker.recipients = list
        picker.body = String(validatingUTF8: "\(body)")
        picker.modalPresentationStyle =  .overFullScreen
        present(picker, animated: true, completion: nil)
        self.present(picker, animated: true, completion: nil)
        */
        
        let messageViewController = MFMessageComposeViewController()
        messageViewController.messageComposeDelegate = self
        messageViewController.recipients = list
        messageViewController.body = String(validatingUTF8: "\(body)")

        let containerViewController = UIViewController()
        containerViewController.view.addSubview(messageViewController.view)
        messageViewController.willMove(toParent: nil)
        containerViewController.addChild(messageViewController)
        messageViewController.didMove(toParent: containerViewController)

        containerViewController.modalPresentationStyle = .fullScreen
        containerViewController.transitioningDelegate = self as? UIViewControllerTransitioningDelegate
        present(containerViewController, animated: true, completion: nil)

        
        
        
    }
    
    func saveToHistory() {
        /* 履歴への追加処理 */
        let dh = DataHandler()
        /* 履歴Entitiy取得 */
        let entity = dh.createNewEntity("History")
        /* 今日の日付 */
        let today = Date()
        /* 宛先リスト名 */
        let rcp_name:NSString = recipientListName.text! as NSString
        /* 件数 */
        let count = tmpSentCount
        /* 件名を取得 */
        let tmp_name:NSString = selectedTMP?.value(forKey: "title") as? NSString ?? ""
        /* entityに追加*/
        entity.setValue(today, forKey: "sent_date")
        entity.setValue(rcp_name, forKey: "rcp_name")
        entity.setValue(tmp_name, forKey: "tmp_name")
        entity.setValue(methodString, forKey: "method")
        entity.setValue(count, forKey: "count")
        //_t = entity.managedObjectContext
        /* Get ManagedObjectContext from AppDelegate */
        let managedContext:NSManagedObjectContext = entity.managedObjectContext!
        /* Error handling */
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(String(describing:error)), \(String(describing: error?.userInfo))")
        }
        print("object saved")
        /* 保存後元の画面に戻る */
    }
    
    
    /*－－－－－－－－－－　MFMessageComposeView　開始　－－－－－－－－－－*/
    /**
    送信完了後の処理
    */
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        /* カウントをクリア */
        allCount = 0
        
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            /* 成功した場合 */
            print("Message was sent")
            /* 送信完了件数を１増加 */
            tmpSmsSentCount += 1
            /* 送信完了件数と送信リストの数が同じなら*/
            if ( tmpSmsSentPlan == tmpSmsSentCount ) {
                //履歴用カウントに送信数をセット
                tmpSentCount = tmpSmsSentCount + 1
                /* 履歴に保存 */
                saveToHistory()
                showMessageSentAlert()
            }
            
            self.dismiss(animated: true, completion: nil)
            
        default:
            break;
        }
    }
    /*－－－－－－－－－－　MFMessageComposeView　終了　－－－－－－－－－－*/
    
    override func viewDidAppear(_ animated: Bool) {
        if tmpSmsSentPlan > 0 && (tmpSmsSentPlan > tmpSmsSentCount) {
            /* SMS送信 */
            showSMSWindow(tmpSmsBody,list: pickAnAddressFromList())
        }
    }

    func reOrder(_ src:Array<Dictionary<String,Any>>?) -> Array<Dictionary<String,Any>>? {
        var misList:Array<Dictionary<String,Any>>? = []
        var tmpList:Array<Dictionary<String,Any>>? = []
        var dics:Dictionary<Int,Dictionary<String,Any>> = Dictionary<Int,Dictionary<String,Any>>()
        //var groupArray:Array<AnyObject>? = nil
        
        /* CoreDataよりGroupテーブルを読み出す */
        let dh = DataHandler()
        
        for g in src! {
            let res:NSManagedObject? = dh.fetchNSManagedObjectString("Group",targetColumn : "groupIdentifier",targetValue : g["groupIdentifier"] as! String)
            
            if res == nil {
                misList!.append(g)
            } else {
                let order = res!.value(forKey: "order") as! Int
                dics.updateValue(g, forKey: order)
            }
        }
        
        //var keys = dics.keys.array
        var keys: [Int] = [Int](dics.keys)
        keys.sort(by: <)
        
        for cnt in keys {
            print(cnt)
        //for cnt in 0 ..< keys.count {
            
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
        templateArray = dh.fetchEntityDataSort("Template",sort:"order")!
        
        //Property取得
        props = dh.getProperties()
        /* 送信元メールアドレスセット */
        if (props[pkey_fromMail] == nil) {
            props[pkey_fromMail] = defaulfromMail
            dh.writeProperty(pkey_fromMail, value: props[pkey_fromMail]!)
        }
        recipientEmailAddress = props[pkey_fromMail]!
        
        /* AddressBookよりGroupのリスト */
        let cn = CNHandler()
        groupList =  cn.getGroupList()
        groupList =  reOrder(groupList)
        groupListCount = cn.getGroupRecordCountList()
        
        groupListShowCount = Array<String>()
        
        /* メソッドごとの人数をセット */
        for cnt in 0 ..< groupList!.count {
            print("cnt = " + String(cnt))
            let abdics:Dictionary<String,Any> = groupList![cnt]
            let recid:String = abdics["groupIdentifier"] as! String
            //let cn = CNHandler()
            let dics:Dictionary<String,String> = cn.getEachMethodCountByGroup(recid)
            groupListShowCount!.append( (abdics["name"] as! String) + " EM-" + (dics["EM"])! + " LS-" + (dics["LS"])! + " SS-" + (dics["SS"])!)
        }
        
        /* TextFieldに初期値を設定 */
        let list:Dictionary<String,Any> = groupList![0]
        let listCount:Dictionary<String,Any> = groupListCount![0] as! Dictionary<String,Any>
        
        print(listCount["count"]!)
        
        //recipientListName.text = (list["name"] as! String) + " - " + (listCount["count"] as! String) + "名"
        recipientListName.text = groupListShowCount![0]
        templateListName.text = templateArray?.first?.value(forKey: "title") as? String
        /* 選択されたEntitiyに初期値を設定 */
        selectedRCP = list["groupIdentifier"] as! String
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


    /*－－－－－－－－－－　PickerView　開始　－－－－－－－－－－*/
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return groupList!.count
            
        } else {
            return templateArray!.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            //let list:Dictionary<String,Any> = groupList![row] as! Dictionary<String,Any>
            //let listCount:Dictionary<String,Any> = groupListCount![row] as! Dictionary<String,Any>
            return groupListShowCount![row] as String
            /* メソッドごとの人数を表示 */
            //return (list["name"] as! String) + " EM" + (dics["EM"])! + "名 LS" + (dics["LS"])! + "名 SS" + (dics["SS"])! + "名"
            //return (list["name"] as! String) + " - " + (listCount["count"] as! String) + "名"
            
        } else {
            let targetObj:NSManagedObject = templateArray![row] as! NSManagedObject
            return  targetObj.value(forKey: "title") as? String
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            let list:Dictionary<String,Any> = groupList![row]
            //let listCount:Dictionary<String,Any> = groupListCount![row] as! Dictionary<String,Any>
            selectedRCP = list["groupIdentifier"] as! String
            
            recipientListName.text = groupListShowCount![row]
            //recipientListName.text = (list["name"] as! String) + " - " + (listCount["count"] as! String) + "名"
        } else {
            let targetObj:NSManagedObject = templateArray![row] as! NSManagedObject
            selectedTMP = templateArray![row] as? NSManagedObject
            templateListName.text = targetObj.value(forKey: "title") as? String
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
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    /*－－－－－－－－－－　TextField　終了　－－－－－－－－－－*/
    
    
    
    
}
