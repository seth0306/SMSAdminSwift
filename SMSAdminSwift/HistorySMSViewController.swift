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
    
    //var historyArray:NSArray? = [];
    var historyArray:Array<AnyObject> = [];
    
    override func viewDidLoad() {
        self.title = "送信履歴"
        /* CoreDataよりHistoryテーブルを読み出す */
        let dh = DataHandler()
        
        //historyArray = dh.fetchEntityDataNoSort("History")! as NSArray
        //historyArray = dh.fetchEntityDataNoSort("History")! as Array<AnyObject>
        
        historyArray = dh.fetchEntityDataSort("History",sort:"sent_date")!
        historyArray.reverse()
        
        /* sent_dateでソートする */
        //let dateSortDescriptor:NSSortDescriptor = NSSortDescriptor(key:"sent_date", ascending:false)
        //historyArray = historyArray.sortedArray(using: [dateSortDescriptor])
        /*
        historyArray.sort(by: {
            (a:AnyObject,b:AnyObject) -> Bool in return
            ((a as! NSManagedObject).value(forKey: "sent_date") as! Date) >
                ((b as! NSManagedObject).value(forKey: "sent_date") as! Date)
        });
        */
        
    }
    
    /* TableView内のセクション数を返す */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    /* TableView内のCellの表示 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell: HistoryTableViewCell = HistoryTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "hisotryTableCell")
        let  cell = tableView.dequeueReusableCell(withIdentifier: "hisotryTableCell") as! HistoryTableViewCell
        let row = (indexPath as NSIndexPath).row
        let sent_date:Date? = (historyArray[row] as AnyObject).value(forKey: "sent_date") as? Date
        let methodString:String? = (historyArray[row] as AnyObject).value(forKey: "method") as? String ?? ""
        let rcp_name:String? = (historyArray[row] as AnyObject).value(forKey: "rcp_name") as? String ?? ""
        let tmp_name:String? = (historyArray[row] as AnyObject).value(forKey: "tmp_name") as? String ?? ""
        let count:NSNumber? = (historyArray[row] as AnyObject).value(forKey: "count") as? NSNumber ?? 0
        
        // NSDateFormatter を用意
        let formatter = DateFormatter()
        // 変換用の書式を設定
        formatter.timeStyle = .none
        formatter.dateFormat = "YYYY-MM-dd"
        /* セルに値を設定 */
        cell.sentTitle.text = tmp_name
        cell.sentDate.text = formatter.string(from: sent_date!);
        cell.sentRcpName.text = rcp_name
        cell.sentMethodType.text = methodString
        cell.sentCount.text = count?.stringValue
        return cell
    }
    
    /* TableView内のセクション内の行数を返す */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
    
    /* headerの高さを指定 */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  32
    }
    
    /* headerを作成 */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "hisotryTableHeaderCell") as! HistoryTableViewHeaderCell
        headerCell.backgroundColor = UIColor.cyan
        return headerCell
    }
    

}
