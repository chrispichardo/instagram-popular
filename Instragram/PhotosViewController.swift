//
//  ViewController.swift
//  Instragram
//
//  Created by christian pichardo on 1/31/16.
//  Copyright © 2016 christian pichardo. All rights reserved.
//
import UIKit
import OAuthSwift
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = NSDictionary()
    let client_id = "e05c462ebd86446ea48a5af73769b602"
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 320
        
        //pull refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "getRecent:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        //Retrieve the data from the Popular Endpoint
        self.getPopular(refreshControl)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //Gets the recent media from the API
    func getPopular(refreshControl: UIRefreshControl){
        //Hook with the popular endpoint
        //let url = NSURL(string:"https://api.instagram.com/v1/tags/nofilter/media/recent?access_token=\(self.access_token)")
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(self.client_id)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            //Store the API response
                            self.data = responseDictionary
                            self.tableView.reloadData()
                            
                            // Tell the refreshControl to stop spinning
                            refreshControl.endRefreshing()
                            
                    }
                }
        });
        task.resume()
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("IG.PhotosTableViewCell", forIndexPath: indexPath) as! PhotosTableViewCell
        
        let image = self.data["data"]![indexPath.row]!["images"]!!["low_resolution"]!!["url"]
        cell.photoImageView.setImageWithURL(NSURL(string: image as!String)!)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if((self.data["data"]) != nil){
            count = self.data["data"]!.count
        }
        return count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let vc = segue.destinationViewController as! PhotoDetailsViewController
        
        let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        
        let image = self.data["data"]![indexPath!.row]!["images"]!!["low_resolution"]!!["url"]
        
        vc.imgURL = NSURL(string: image as!String)!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
          self.getPopular(refreshControl)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

