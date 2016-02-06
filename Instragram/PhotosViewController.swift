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

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = NSDictionary()
    let client_id = "e05c462ebd86446ea48a5af73769b602"
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 320
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        //pull refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "getPopular:", forControlEvents: UIControlEvents.ValueChanged)
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
        
        let image = self.data["data"]![indexPath.section]!["images"]!!["low_resolution"]!!["url"]
        cell.photoImageView.setImageWithURL(NSURL(string: image as!String)!)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var count = 0
        if((self.data["data"]) != nil){
            count = self.data["data"]!.count
        }
        return count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //Set the header
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        //Set the imageview to display the user picture in the header
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).CGColor
        profileView.layer.borderWidth = 1;
        
        // Retrieve and set the profile image
        let profileImage = self.data["data"]![section]!["user"]!!["profile_picture"]
        profileView.setImageWithURL(NSURL(string: profileImage as!String)!)
        
        headerView.addSubview(profileView)
        
        // Set the username in the header
        let nameLabel = UILabel(frame: CGRect(x: 50, y: 10, width: 100, height: 30))
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 14)
        nameLabel.text = (self.data["data"]![section]!["user"]!!["username"] as! String)
        headerView.addSubview(nameLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    /*Function to load more data*/
    func loadMoreData() {
        
        // ... Create the NSURLRequest (myRequest) ...
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(self.client_id)")
        let myRequest = NSURLRequest(URL: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,
            completionHandler: { (data, response, error) in
                
                // Update flag
                self.isMoreDataLoading = false
                
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                
                // ... Use the new data to update the data source ...
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data!, options:[]) as? NSDictionary {
                        
                        //Store the API response
                        self.data = responseDictionary
                        
                }

                // Reload the tableView now that there is new data
                self.tableView.reloadData()
        });
        task.resume()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadMoreData()
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

