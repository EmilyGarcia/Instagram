//
//  DetailViewController.swift
//  Instagram
//
//  Created by Emily Garcia on 2/24/18.
//  Copyright © 2018 CodePath. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class DetailViewController: UIViewController {

    @IBOutlet weak var lgPostImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    var post: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let post = post {
            print(post)
            captionLabel.text = post["caption"] as? String
//            timeStampLabel.text = post["_created_at"] as? String
            let imageFile = post["media"] as? PFFile
            
            if let imageFile : PFFile = imageFile {
                imageFile.getDataInBackground(block: { (data, error) in
                    if error == nil {
                        DispatchQueue.main.async {
                            // Async main thread
                            
                            let image = UIImage(data: data!)
                            self.lgPostImageView.image = image
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
