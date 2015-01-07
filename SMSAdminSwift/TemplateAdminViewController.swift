//
//  TemplateAdminViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/07.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit

class TemplateAdminViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var templateArray = []
    
    override func viewDidLoad() {
        self.title = "テンプレート管理"
    }
    
    /* TableView内のセクション数を返す */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    /* TableView内のCellの表示 */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //let cell: HistoryTableViewCell = HistoryTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "hisotryTableCell")
        let  cell = tableView.dequeueReusableCellWithIdentifier("templateTableCell") as TemplateTableViewCell
        var row = indexPath.row
        let template_title:NSString? = templateArray[row].valueForKey("title") as? NSString
        let template_summary:NSString? = templateArray[row].valueForKey("summary") as? NSString
        /* セルに値を設定 */
        cell.template_summary.text = template_summary
        cell.template_title.text = template_title
        return cell
    }
    
    /* TableView内のセクション内の行数を返す */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templateArray.count
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
    }}
