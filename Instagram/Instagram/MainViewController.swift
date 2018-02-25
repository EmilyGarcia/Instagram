//
//  MainViewController.swift
//  Instagram
//
//  Created by Emily Garcia on 2/24/18.
//  Copyright © 2018 CodePath. All rights reserved.
//
import Parse
import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell

        let query = Post.query()
        query?.order(byDescending: "createdAt")
        query?.includeKey("author")
        query?.limit = 20
        
        // fetch data asynchronously
        query?.findObjectsInBackground { (Post, error: Error?) -> Void in
            if let posts = Post {
                print(posts)
                print("you there fam?")
//                cell.postImageView = posts[]
//                cell.captionLabel = posts[]
            } else {
                print("User log out failed: \(error?.localizedDescription)")
            }
        }
        
        return cell
    }

}
