//
//  ViewController.swift
//  SearchAndRefresh
//
//  Created by Prajwal Kedilaya on 3/1/16.
//  Copyright © 2016 Prajwal Kedilaya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var filteredPosts = [String]()
    var originalPosts = [String]()
    var resultSearchController: UISearchController!
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        refresh.backgroundColor = UIColor.whiteColor()
        table.addSubview(refresh)
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = true
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        table.tableHeaderView = resultSearchController.searchBar
        
        getData { (posts) -> Void in
            self.originalPosts = posts
            self.filteredPosts = posts
            self.table.reloadData()
        }
    }
    
    func getData(completion: (posts:[String])-> Void) {
        var posts = [String]()
        let request = NSURLRequest(URL: NSURL(string: "http://jsonplaceholder.typicode.com/posts")!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                if let data = data, json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [[String: AnyObject]] {
                    for elem in json {
                        if let post = elem["body"] as? String {
                            posts.append(post)
                        }
                    }
                }
            }
            catch {}
            dispatch_async(dispatch_get_main_queue(), {
                completion(posts: posts)
            })
        }
        task.resume()
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        getData { (posts) -> Void in
            self.originalPosts = posts
            self.filteredPosts = posts
            self.table.reloadData()
            refreshControl.endRefreshing()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.active {
            return filteredPosts.count
        }
        else {
            return originalPosts.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCellWithIdentifier("Cell")
        if resultSearchController.active {
            cell!.textLabel?.text = filteredPosts[indexPath.row]
        }
        else {
            cell!.textLabel?.text = originalPosts[indexPath.row]
        }
        
        return cell!
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredPosts.removeAll(keepCapacity: false)
        for elem in originalPosts {
            if elem.containsString(searchController.searchBar.text!) {
                filteredPosts.append(elem)
            }
        }
        table.reloadData()
    }
}