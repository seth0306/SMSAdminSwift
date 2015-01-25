//
//  SelectItemViewController.swift
//  SMSAdminSwift
//
//  Created by Seth on 2015/01/20.
//  Copyright (c) 2015年 Information Shower, Inc. All rights reserved.
//

import UIKit

class SelectItemViewController: UIPopoverPresentationController {
    
    
    func dismissScreen(){
        self.presentedViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
