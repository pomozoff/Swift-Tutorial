//
//  DetailsViewController.swift
//  SwiftTutorial
//
//  Created by Anton Pomozov on 19.06.14.
//  Copyright (c) 2014 JQ Software LLC. All rights reserved.
//

import UIKit
import MediaPlayer

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {

    @IBOutlet var albumCover : UIImageView
    @IBOutlet var titleLabel : UILabel
    @IBOutlet var tracksTableView : UITableView

    @lazy var api: APIController = APIController(delegate: self)
    
    var tracks: Track[] = []
    var album: Album?
    var mediaPlayer: MPMoviePlayerController = MPMoviePlayerController()
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = album?.title
        albumCover.image = UIImage(data: NSData(contentsOfURL: NSURL(string: album?.largeImageURL)))

        // Load in tracks
        if album?.collectionId? {
            api.lookupAlbum(album!.collectionId!)
        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let count: Int = tracks.count
        return count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = tableView.dequeueReusableCellWithIdentifier("TrackCell") as TrackCell
        
        var track = tracks[indexPath.row]
        cell.titleLabel.text = track.title
        cell.playButton.selected = false
        
        return cell
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var track = tracks[indexPath.row]
        mediaPlayer.stop()
        mediaPlayer.contentURL = NSURL(string: track.previewUrl)
        mediaPlayer.play()
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TrackCell {
            cell.playButton.selected = !cell.playButton.selected
        }
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        if let allResults = results["results"] as? NSDictionary[] {
            for trackInfo in allResults {
                // Create the track
                if let kind = trackInfo["kind"] as? String {
                    if "song" == kind {
                        let track = Track(dict: trackInfo)
                        tracks.append(track)
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.tracksTableView.reloadData()
        })
    }
    
}
