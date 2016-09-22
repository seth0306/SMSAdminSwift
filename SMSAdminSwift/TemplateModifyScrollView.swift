//
//  templateModifyScrollView.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/03/11.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit

class TemplateModifyScrollView: UIScrollView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.superview?.endEditing(true)
    }

}
