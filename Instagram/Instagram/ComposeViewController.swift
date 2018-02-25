//
//  ComposeViewController.swift
//  Instagram
//
//  Created by Emily Garcia on 2/24/18.
//  Copyright © 2018 CodePath. All rights reserved.
//

import UIKit
import Parse

class ComposeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        // vc.sourceType = UIImagePickerControllerSourceType.photoLibrary

        self.present(vc, animated: true, completion: nil)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available :camera_with_flash:")
            vc.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            print("Camera :no_entry_sign: available so we will use photo library instead")
            vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        // Do any additional setup after loading the view.
        PFUser.registerSubclass()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let newImage = resize(image: originalImage, newSize: CGSize(width: 300, height: 300))
        
        // Do something with the images (based on your use case)
        self.photoImageView.image = newImage
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
    }
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRect(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    @IBAction func onShare(_ sender: Any) {
        Post.postUserImage(image: self.photoImageView.image, withCaption: captionField.text) { (success: Bool, error: Error?) in
            
            if let error = error {
                print("post failed: \(error.localizedDescription)")
            } else {
                print("post succeded")
                // display view controller that needs to shown after successful login
                self.performSegue(withIdentifier: "mainSegue", sender: nil)
            }
        }
    }
}

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}

class Post: PFObject, PFSubclassing {
    @NSManaged var media : PFFile
    @NSManaged var author: PFUser
    @NSManaged var caption: String
    @NSManaged var likesCount: Int
    @NSManaged var commentsCount: Int
    
    /* Needed to implement PFSubclassing interface */
    class func parseClassName() -> String {
        return "Post"
    }
    
    /*
     Method to add a user post to Parse (uploading image file)
     
     - parameter image: Image that the user wants upload to parse
     - parameter caption: Caption text input by the user
     - parameter completion: Block to be executed after save operation is complete
     */
    class func postUserImage(image: UIImage?, withCaption caption: String?, withCompletion completion: PFBooleanResultBlock?) {
        // use subclass approach
        let post = Post()
        
        // Add relevant fields to the object
        post.media = getPFFileFromImage(image: image)! // PFFile column type
        post.author = PFUser.current()! // Pointer column type that points to PFUser
        post.caption = caption!
        post.likesCount = 0
        post.commentsCount = 0
        
        // Save object (following function will save the object in Parse asynchronously)
        post.saveInBackground(block: completion)
    }
    
    /**
     Method to convert UIImage to PFFile
     
     - parameter image: Image that the user wants to upload to parse
     
     - returns: PFFile for the the data in the image
     */
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
}

