//
//  AFNViewController.swift
//  ImageCollectionNSandAFN
//
//  Created by amarron on 2015/07/01.
//  Copyright (c) 2015年 amarron. All rights reserved.
//

import Foundation
import UIKit

enum AFN_TYPE: Int {
    case AFN_OPERATION = 0
    case AFN_SESSION = 1
    case AFN_IMG = 2
}

// TODO: AFHTTPRequestOperationManager,AFHTTPSessionManagerを分ける

class AFNViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
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
        
        switch self.type {
        case AFN_TYPE.self.AFN_OPERATION.rawValue :
            let manager:AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
            manager.responseSerializer = AFImageResponseSerializer()
            let requestSuccess = {
                (operation :AFHTTPRequestOperation!, responseObject :AnyObject!) -> Void in
                if let image:UIImage = responseObject as? UIImage {
                    cell.photoImageView.image = image
                }
            }
            let requestFailure = {
                (operation :AFHTTPRequestOperation!, error :NSError!) -> Void in
                print("failure: \(error.localizedDescription)")
            }
            
            manager.GET(photoUrlString, parameters: nil, success: requestSuccess, failure: requestFailure)
        case AFN_TYPE.self.AFN_SESSION.rawValue:
            let manager:AFHTTPSessionManager = AFHTTPSessionManager()
            manager.responseSerializer = AFImageResponseSerializer()
            manager.GET(photoUrlString, parameters: nil,
                success: { (task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
                    if let image:UIImage = responseObject as? UIImage {
                        cell.photoImageView.image = image
                    }
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
                    print("failure:\(error.localizedDescription)")
            })
        default:
            let imageRequestSuccess = {
                (request : NSURLRequest!, response : NSHTTPURLResponse!, image : UIImage!) -> Void in
                cell.photoImageView.image = image;
                cell.photoImageView.alpha = 0
                UIView.animateWithDuration(0.2, animations: {
                    cell.photoImageView.alpha = 1.0
                })
            }
            let imageRequestFailure = {
                (request : NSURLRequest!, response : NSHTTPURLResponse!, error : NSError!) -> Void in
                print("failure:\(error.localizedDescription)")
            }
            let photoUrlRequest : NSURLRequest = NSURLRequest(URL: NSURL(string:photoUrlString)!)
            cell.photoImageView.setImageWithURLRequest(photoUrlRequest, placeholderImage: nil, success: imageRequestSuccess, failure: imageRequestFailure)
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
        
        let manager :AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        let url :String = "https://api.flickr.com/services/rest/"
        let parameters :Dictionary = [
            "method"         : "flickr.interestingness.getList",
            "api_key"        : "9a0554259914a86fb9e7eb014e4e5d52",
            "per_page"       : String(photoCount),
            "format"         : "json",
            "nojsoncallback" : "1",
            "extras"         : "url_q,url_z",
        ]
        let requestSuccess = {
            (operation :AFHTTPRequestOperation!, responseObject :AnyObject!) -> Void in
            if let array:Array = responseObject.objectForKey("photos")?.objectForKey("photo") as? Array<Dictionary<String, AnyObject>> {
                self.photos = array
            }
            self.collectionView!.reloadData()
        }
        let requestFailure = {
            (operation :AFHTTPRequestOperation!, error :NSError!) -> Void in
            let alert = UIAlertController(title: "failure", message: error!.description, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        manager.GET(url, parameters: parameters, success: requestSuccess, failure: requestFailure)
    }
    
    private func createCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: marginSize, left: marginSize, bottom: marginSize, right: marginSize)
        layout.minimumInteritemSpacing = marginSize
        layout.minimumLineSpacing = marginSize*2
        let itemSize = (Int(self.view.frame.width) - Int(marginSize*2))/columnCount-Int(marginSize)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        let frame:CGRect = CGRect(x: 0, y: 80, width: self.view.frame.width, height: self.view.frame.height-80)
        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        self.collectionView!.registerClass(CustomCell.self, forCellWithReuseIdentifier: "CustomCell")
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.view.addSubview(self.collectionView)
        
    }
    
}