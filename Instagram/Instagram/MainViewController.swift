//
//  MainViewController.swift
//  Instagram
//
//  Created by Emily Garcia on 2/24/18.
//  Copyright © 2018 CodePath. All rights reserved.
//
import Parse
import ParseUI
import UIKit

class MainViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    var posts: [PFObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchData()
        
        self.activityIndicator.startAnimating()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MainViewController.didPullToRefresh(_:) ), for: . valueChanged)
        
        didPullToRefresh(refreshControl)
        tableView.insertSubview(refreshControl, at: 0)
        
        
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogOut(_ sender: Any) {
        PFUser.logOutInBackground { (error: Error?) in
            if let error = error {
                print("User log out failed: \(error.localizedDescription)")
            } else {
                print("User logged out successfully")
                // PFUser.current() will now be nil
                // display view controller that needs to shown after successful login
                self.performSegue(withIdentifier: "logoutSegue", sender: nil)
            }
        }
    }
    
    @objc func didPullToRefresh(_ refreshControl:  UIRefreshControl){
        fetchData()
    }
    
    func fetchData(){
        let query = Post.query()
        query?.order(byDescending: "createdAt")
        query?.includeKey("author")
        query?.limit = 20
        
        // fetch data asynchronously
        query?.findObjectsInBackground { (Post, error: Error?) -> Void in
            if let posts = Post {
                self.posts = posts
                //print(self.posts[9])
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            } else {
                print("fetch data failed: \(error?.localizedDescription)")
            }
        }
    self.activityIndicator.stopAnimating()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        //print(indexPath.row)
        let post = posts[indexPath.row]
        print(post)
        let caption = post["caption"] as! String
        let imageFile = post["media"] as? PFFile
        print(imageFile!)
        
        if let imageFile : PFFile = imageFile {
            imageFile.getDataInBackground(block: { (data, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        // Async main thread

                        let image = UIImage(data: data!)
                        cell.postImageView.image = image
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
        cell.captionLabel.text = caption
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue"{
            let cell = sender as!UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                let post = posts[indexPath.row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.post = post
            }
        }
    
    }

}
