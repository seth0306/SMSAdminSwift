//
//  templateModifyScrollView.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/03/11.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit

class TemplateModifyScrollView: UIScrollView {

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.superview?.endEditing(true)
    }

}
