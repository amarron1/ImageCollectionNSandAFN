//
//  ViewController.swift
//  ImageCollectionNSandAFN
//
//  Created by amarron on 2015/07/01.
//  Copyright (c) 2015年 amarron. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var columnCount:UITextField!
    @IBOutlet var marginSize:UITextField!
    @IBOutlet var photoCount:UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dispNSView(sender: UIButton) {
        let viewController = NSViewController(nibName: "NSView", bundle: nil)
        viewController.columnCount = Int(self.columnCount.text!)!
        viewController.marginSize = CGFloat(Int(self.marginSize.text!)!)
        viewController.photoCount = Int(self.photoCount.text!)!
        viewController.type = sender.tag
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    @IBAction func dispAFNView(sender: UIButton) {
        let viewController = AFNViewController(nibName: "AFNView", bundle: nil)
        viewController.columnCount = Int(self.columnCount.text!)!
        viewController.marginSize = CGFloat(Int(self.marginSize.text!)!)
        viewController.photoCount = Int(self.photoCount.text!)!
        viewController.type = sender.tag
        self.presentViewController(viewController, animated: true, completion: nil)

    }
    


}

