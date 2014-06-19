//
//  ViewController.swift
//  SwiftTutorial
//
//  Created by Jameson Quave on 6/16/14.
//  Copyright (c) 2014 JQ Software LLC. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    @IBOutlet var appsTableView : UITableView
    
    @lazy var api: APIController = APIController(delegate: self)
    @lazy var nf: NSNumberFormatter = NSNumberFormatter()
    
    let imageCache = NSMutableDictionary()
    var albums: Album[] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.api.searchItunesFor("Bob Dylan")
        self.nf.maximumFractionDigits = 2;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell") as UITableViewCell
        
        let album = self.albums[indexPath.row]
        
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        let urlString = album.thumbnailImageURL
        
        // Check our image cache for the existing key. This is just a dictionary of UIImages
        var image: UIImage? = self.imageCache.valueForKey(urlString) as? UIImage
        
        if image? {
            // If image has found in cache set it immediately
            cell.image = image
        } else {
            // Set placeholder image until loading original from the web
            cell.image = UIImage(named: "Blank52")
            
            // If the image does not exist, we need to download it
            let url = NSURL(string: urlString)
            let session = NSURLSession.sharedSession()

            // Download an NSData representation of the image at the URL
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let task = session.dataTaskWithURL(url, completionHandler: { data, response, error -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if error {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                } else {
                    image = UIImage(data: data)
                    dispatch_async(dispatch_get_main_queue(), {
                        // Store the image in to our cache
                        self.imageCache[urlString] = image
                        // Set loaded image instead previously set placeholder
                        if let ownCell = tableView.cellForRowAtIndexPath(indexPath) {
                            ownCell.image = image
                        }
                    })
                }
            })
            task.resume()
        }
        
        cell.text = album.title
        cell.detailTextLabel.text = album.price
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
        var detailsViewController: DetailsViewController = segue.destinationViewController as DetailsViewController
        var albumIndex = appsTableView.indexPathForSelectedRow().row
        var selectedAlbum = self.albums[albumIndex]
        detailsViewController.album = selectedAlbum
    }
    
    
    func didReceiveAPIResults(results: NSDictionary) {
        // Store the results in our table data array
        if results.count > 0 {
            let allResults = results["results"] as NSDictionary[]
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in allResults {
                
                var name: String? = result["trackName"] as? String
                if !name? {
                    name = result["collectionName"] as? String
                }
                
                // Sometimes price comes in as formattedPrice, sometimes as collectionPrice.. and sometimes it's a float instead of a string. Hooray!
                var price: String? = result["formattedPrice"] as? String
                if !price? {
                    price = result["collectionPrice"] as? String
                    if !price? {
                        let priceFloat: Float? = result["collectionPrice"] as? Float
                        if priceFloat? {
                            price = "$" + nf.stringFromNumber(priceFloat)
                        }
                    }
                }
                
                let thumbnailURL: String? = result["artworkUrl60"] as? String
                let imageURL: String? = result["artworkUrl100"] as? String
                let artistURL: String? = result["artistViewUrl"] as? String
                
                var itemURL: String? = result["collectionViewUrl"] as? String
                if !itemURL? {
                    itemURL = result["trackViewUrl"] as? String
                }
                
                var newAlbum = Album(name: name!,
                    price: price!,
                    thumbnailImageURL: thumbnailURL!,
                    largeImageURL: imageURL!,
                    itemURL: itemURL!,
                    artistURL: artistURL!)
                albums.append(newAlbum)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.appsTableView.reloadData()
            })
        }
    }

}
