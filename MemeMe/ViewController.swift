//
//  ViewController.swift
//  MemeMe
//
//  Created by Lili Weinberger on 8/17/16.
//  Copyright © 2016 Lili Weinberger. All rights reserved.
//

import UIKit


struct Meme {
    var tTextField: String
    var bTextField: String
    var image: UIImage
    var memedImage: UIImage
    
}


class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate,UITextFieldDelegate {
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationItem!
    
    // need a variable for our struct in this VC
    var meme: Meme?
    var memeObject: Meme?
    
    
    // font setup
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0,
        ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // text field setup
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        
        // set the delegate
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        // enable the camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
     
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func textFieldShouldReturn(textfield: UITextField) -> Bool {
        bottomTextField.resignFirstResponder()
        topTextField.resignFirstResponder()
        return true
    }
    
    // MARK: Keyboard toggle
    
    func subscribeToKeyboardNotifications() {
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)

    }
    
    func unsubscribeFromKeyboardNotifications() {
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
       
    }
    
    
    func keyboardWillShow(notification: NSNotification)
    {
        if bottomTextField.isFirstResponder() {
        self.view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    
    func keyboardWillHide() {
            view.frame.origin.y = 0.0
    }
    
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // share the meme method
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        
        // instantiate activity view controller
        let activityViewController = UIActivityViewController.init(activityItems: [generateMemedImage()], applicationActivities: nil)
        //activityViewController.popoverPresentationController?.sourceView = sender as? UIView
        
        // present the view controller
        presentVC(activityViewController)
        
        // save it in the completionWithItemsHandler closure
        activityViewController.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
            
            // Return if cancelled
            if (!completed) {
                return
            }
            
            //activity complete
            self.saveMeme()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }


    
    func presentVC(controller: UIActivityViewController){
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func saveMeme() -> Meme{
        // Create the meme, by using the struct variables
        memeObject = Meme(tTextField: topTextField.text!, bTextField: bottomTextField.text!, image: imageView.image!, memedImage: generateMemedImage())
        
        return memeObject!
    }
    
    func generateMemedImage() -> UIImage
    {
        // Hide toolbar and navbar
        navigationController?.navigationBarHidden = true
        self.bottomToolbar.hidden = true
        
        
        // Render view to an image
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar, again
        navigationController?.navigationBarHidden = false
        self.bottomToolbar.hidden = false
        
        
        return memedImage
    }


    // brings up the album
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    // shows the camera via the UIImage picker
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }

    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)

    }

}
