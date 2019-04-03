//
//  ShareViewController.swift
//  SwiftPetSNS
//
//  Created by seijiro on 2019/04/03.
//  Copyright © 2019 norainu. All rights reserved.
//

import UIKit
import Photos
import VisualRecognitionV3
import SVProgressHUD
import Firebase
import FirebaseDatabase
import FirebaseStorage
import EMAlertController

class ShareViewController: UIViewController,UIImagePickerControllerDelegate,UITextViewDelegate,UINavigationControllerDelegate {


  @IBOutlet var textView: UITextView!
  @IBOutlet var cameraImageView: UIImageView!
  
  var fullName_Array = [String]();
  var postImage_Array = [String]();
  var comment_Array = [String]();

  var fullName = String()
  var image = UIImage()
  var iamgeURL:URL!

  let apiKey = "Ewc4-Ul-iLrMU21MzhS0n2nBdVxkRJibsAailRLxuuS2"
  let version = "2019-04-03"

  var dogOrNot = true
  var resultString = String()
  var classificationResult:[String] = []

  var userName = String()


    override func viewDidLoad() {
        super.viewDidLoad()
      textView.delegate = self
      PHPhotoLibrary.requestAuthorization { (status) in
        switch(status){
        case .authorized:
          break;
        case .denied:
          break;
        case .notDetermined:
          break;
        case .restricted:
          break;
        default:
          break;
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.userName = UserDefaults.standard.object(forKey: "userName") as! String

  }


  @IBAction func camera(_ sender: Any) {
    print("camera")
    let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.camera
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
      let cameraPicker =  UIImagePickerController()
      cameraPicker.sourceType = sourceType
      cameraPicker.delegate = self
      cameraPicker.allowsEditing = true
      self.present(cameraPicker,animated: true,completion: nil)
    } else {
        print("error")
    }
  }


  @IBAction func album(_ sender: Any) {
    let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
      let cameraPicker =  UIImagePickerController()
      cameraPicker.sourceType = sourceType
      cameraPicker.delegate = self
      cameraPicker.allowsEditing = true
      self.present(cameraPicker,animated: true,completion: nil)
    } else {
      print("error")
    }
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    SVProgressHUD.show()
    //if let pickedImage = info[  .originalImage] as? UIImage {
    if let pickedImage = info[.originalImage] as? UIImage {
      // imageViewに画像セット
      self.cameraImageView.image = pickedImage

      // watsonに犬か聞く
      let visualRecognition = VisualRecognition(version: version, apiKey: apiKey, iamUrl: nil)
      let imageData = pickedImage.jpegData(compressionQuality: 1.0)
      let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
      let fileURL = documentURL?.appendingPathComponent("tempImage.jpg")
      try! imageData?.write(to: fileURL!, options: [])

      self.classificationResult = [String]()

      visualRecognition.classify(imagesFile: imageData, imagesFilename: nil, imagesFileContentType: nil, url: nil, threshold: nil, owners: nil, classifierIDs: ["default"], acceptLanguage: "ja", headers: nil) { (response, error) in

        if let error = error {
          print(error)
        }
        guard let classifiedImages = response?.result else {
          print("Failed to classify the image")
          return
        }
        print(classifiedImages)

        let classes = classifiedImages.images.first!.classifiers.first!.classes

        for index in 1..<classes.count{
          self.classificationResult.append(classes[index].className)
        }
        if self.classificationResult.contains("楽器"){
          DispatchQueue.main.async{
            print("楽器です")
            self.dogOrNot = true
            SVProgressHUD.dismiss()
          }
        }else{
          DispatchQueue.main.async{
            print("楽器ではないです")
            self.dogOrNot = false
            SVProgressHUD.dismiss()

          }
        }
      }
      picker.dismiss(animated: true, completion: nil)
    }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }

  func postData(){
    let rootRef = Database.database().reference(fromURL:"https://petsns-3cd2f.firebaseio.com/").child("post")
    let storage = Storage.storage().reference(forURL: "gs://petsns-3cd2f.appspot.com/")
    let key = rootRef.child("User").childByAutoId().key!
//    let imageRef = storage.child("Users").child("\(key).jpg")
    let imageRef = storage.child("Users").child("\(key)")

    var data:NSData = NSData()
    if let image = cameraImageView.image{

      data = image.jpegData(compressionQuality: 0.01)! as NSData
    }

    let uploadTask = imageRef.putData(data as Data, metadata: nil) { (metaData, error) in

      if error != nil{

        SVProgressHUD.show()
        return
      }

      imageRef.downloadURL(completion: { (url, error) in

        if url != nil{

          let feed = ["postImage":url?.absoluteString,"comment":self.textView.text,"fullName":self.userName] as [String:Any]
          let postFeed = ["\(key)":feed]
          rootRef.updateChildValues(postFeed)
          SVProgressHUD.dismiss()

        }

      })

    }

    uploadTask.resume()
    if let controller = self.presentingViewController as? TimeLineViewController {
      controller.fetchPosts()
      controller.tableView.reloadData()
    }
    let alert = EMAlertController(icon: nil, title: "Share", message: "投稿できました")
    let action = EMAlertAction(title: "OK", style: .normal) {
      print(1)
    }
    alert.addAction(action)
    present(alert,animated:true,completion:nil)

    //self.dismiss(animated: true, completion: nil)

    }

  @IBAction func share(_ sender: Any) {
    if dogOrNot == true{
      
      postData()

    }else{

      let alert = EMAlertController(icon: UIImage(named: "dogIcon.jpg"), title: "ごめんなさい。", message: "楽器ではないようです。")

      let action = EMAlertAction(title: "OK", style: .cancel)
      alert.addAction(action)
      present(alert,animated:true,completion:nil)
    }
  }

  @IBAction func back(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    textView.resignFirstResponder()
  }

  /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
