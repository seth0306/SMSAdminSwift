//
//  HistorySMSViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/06.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit
import CoreData

class HistorySMSViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var historyTableView: UITableView!
    
    var historyArray = [];
    
    override func viewDidLoad() {
        self.title = "送信履歴"
        /* CoreDataよりHistoryテーブルを読み出す */
        var dh = DataHandler()
        historyArray = dh.fetchEntityData("History")!
    }
    
    /* TableView内のセクション数を返す */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }

    /* TableView内のCellの表示 */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //let cell: HistoryTableViewCell = HistoryTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "hisotryTableCell")
        let  cell = tableView.dequeueReusableCellWithIdentifier("hisotryTableCell") as HistoryTableViewCell
        let row = indexPath.row
        let sent_date:NSDate? = historyArray[row].valueForKey("sent_date") as? NSDate
        let objectRCP:NSManagedObject = historyArray[row].valueForKey("recipient") as NSManagedObject
        let objectTMP:NSManagedObject = historyArray[row].valueForKey("template") as NSManagedObject
        
        // NSDateFormatter を用意
        let formatter = NSDateFormatter()
        // 変換用の書式を設定
        formatter.timeStyle = .NoStyle
        formatter.dateFormat = "YYYY-MM-dd"
        /* セルに値を設定 */
        cell.sentTitle.text = objectTMP.valueForKey("title")as NSString ?? ""
        cell.sentDate.text = formatter.stringFromDate(sent_date!);
        cell.sentRcpName.text = objectRCP.valueForKey("name")as NSString ?? ""
        
        return cell
    }
    
    /* TableView内のセクション内の行数を返す */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
    
    /* headerの高さを指定 */
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  32
    }
    
    /* headerを作成 */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("hisotryTableHeaderCell") as HistoryTableViewHeaderCell
        headerCell.backgroundColor = UIColor.cyanColor()
        return headerCell
    }
    

}
