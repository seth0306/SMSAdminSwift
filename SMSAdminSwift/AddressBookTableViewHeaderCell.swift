//
//  AddressBookTableViewHeaderCell.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/09.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit

class AddressBookTableViewHeaderCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        name.layer.borderColor = UIColor.blackColor().CGColor
        name.layer.borderWidth = 1
        
        phone.layer.borderColor = UIColor.blackColor().CGColor
        phone.layer.borderWidth = 1
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
