//
//  NSViewController.swift
//  ImageCollectionNSandAFN
//
//  Created by amarron on 2015/07/01.
//  Copyright (c) 2015年 amarron. All rights reserved.
//

import Foundation
import UIKit

enum NS_TYPE: Int {
    case ASYNC_SESSION
    case ASYNC_CONNECTION
    case SYNC_CONNECTION
}

class NSViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    var type:Int!
    
    var marginSize:CGFloat = 1
    var columnCount:Int = 3
    var photoCount:Int = 100
    
    var photos:[Dictionary<String, AnyObject>] = []
    
    var collectionView:UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getPhotos()
        
        self.createCollectionView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("CustomCell", forIndexPath: indexPath) as! CustomCell
        
        let photoInfo = photos[indexPath.row] as Dictionary
        let photoUrlString = photoInfo["url_q"] as! String
//        let photoUrlString = photoInfo["url_z"] as! String

        // 通信先のURLを生成.
        let url:NSURL = NSURL(string: photoUrlString)!
        
        switch self.type {
            
        case NS_TYPE.self.ASYNC_SESSION.rawValue :
            /* NSURLSession */
            // セッションの生成.
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            // 通信のタスクを生成.
            let task = session.dataTaskWithURL(url, completionHandler: {
                (data, response, err) in
                cell.photoImageView.image = UIImage(data: data)!
            })
            // タスクの実行.
            task.resume()
        case NS_TYPE.self.ASYNC_CONNECTION.rawValue :

            /* NSURLConnection */
            // リクエストを生成.
            let request:NSURLRequest = NSURLRequest(URL:url)
            let queue:NSOperationQueue = NSOperationQueue()
            // NSURLConnectionを使ってアクセス
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                cell.photoImageView.image = UIImage(data: data!)!
            })
            
            
        default:
            /* NSURLConnection (Sync)*/
            // リクエストを生成.
            let request:NSURLRequest = NSURLRequest(URL:url)
            // NSURLConnectionを使ってアクセス
            var response: NSURLResponse?
            var error: NSError?
            let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
            if error == nil{
                cell.photoImageView.image = UIImage(data:data!)!
            } else {
                println("failure: \(error!.localizedDescription)")
            }
        }
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count;
    }
    
    // MARK: - IBAction
    @IBAction func dissmiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - private
    private func getPhotos() {
        // 通信先のURLを生成.
        let url:NSURL = NSURL(string:"https://api.flickr.com/services/rest/")!
        // リクエストを生成.
        let request = NSMutableURLRequest(URL:url)
        request.HTTPMethod = "POST"
        request.HTTPBody = "method=flickr.interestingness.getList&api_key=9a0554259914a86fb9e7eb014e4e5d52&per_page=\(photoCount)&format=json&nojsoncallback=1&extras=url_q,url_z".dataUsingEncoding(NSUTF8StringEncoding)

        // NSURLConnectionを使ってアクセス
        var response: NSURLResponse?
        var error: NSError?
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        if error == nil{
            var result = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            let json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data!,
                options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
            
            if let array:Array = json.objectForKey("photos")?.objectForKey("photo") as? Array<Dictionary<String, AnyObject>> {
                self.photos = array
            }
        } else {
            let alert = UIAlertController(title: "failure", message: error!.description, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    
    private func createCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: marginSize, left: marginSize, bottom: marginSize, right: marginSize)
        layout.minimumInteritemSpacing = marginSize
        layout.minimumLineSpacing = marginSize*2
        var itemSize = (Int(self.view.frame.width) - Int(marginSize*2))/columnCount-Int(marginSize*2)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        let frame:CGRect = CGRect(x: 0, y: 80, width: self.view.frame.width, height: self.view.frame.height-80)
        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        self.collectionView!.registerClass(CustomCell.self, forCellWithReuseIdentifier: "CustomCell")
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.view.addSubview(self.collectionView)
        
    }
    
}