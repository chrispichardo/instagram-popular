//
//  PhotoDetailsViewController.swift
//  Instragram
//
//  Created by christian pichardo on 2/5/16.
//  Copyright © 2016 christian pichardo. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    
    internal var imgURL : NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailImageView.setImageWithURL(imgURL)
       
        
    

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
