//
//  TimeLineViewController.swift
//  SwiftPetSNS
//
//  Created by seijiro on 2019/04/03.
//  Copyright © 2019 norainu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage
import SVProgressHUD

class TimeLineViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

  @IBOutlet var tableView: UITableView!

  var refreshC = UIRefreshControl()

  var fullName_Array = [String]();
  var postImage_Array = [String]();
  var comment_Array = [String]();

  var posts = [Post]()
  var post = Post()

  override func viewDidLoad() {
        super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    refreshC.attributedTitle = NSAttributedString(string: "引っ張って更新")
    refreshC.addTarget(self, action: #selector(refresh), for: .valueChanged)
    tableView.addSubview(refreshC)

    }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    SVProgressHUD.dismiss()
  }
  override func viewWillAppear(_ animated: Bool) {
    print("viewwillappear")
    super.viewWillAppear(animated)
    fetchPosts()
    tableView.reloadData()
  }



  @objc func refresh(){
    fetchPosts()
    refreshC.endRefreshing()
  }

  func fetchPosts(){
    self.posts = [Post]()
    self.fullName_Array = [String]()
    self.postImage_Array = [String]()
    self.comment_Array = [String]()
    self.post = Post()

    let ref = Database.database().reference()
    ref.child("post").queryLimited(toFirst: 10).observeSingleEvent(of: .value) { (snap, error) in
      let postsSnap = snap.value as? [String:NSDictionary]
      if postsSnap == nil {
        return
      }
      self.posts = [Post]()
      self.fullName_Array = [String]()
      self.postImage_Array = [String]()
      self.comment_Array = [String]()
      for (_, p) in postsSnap! {
        self.post = Post()
        if let comment = p["comment"] as? String, let userName = p["fullName"] as? String,let postImage = p["postImage"] as? String{
          self.post.comment = comment
          self.post.fullName = userName
          self.post.postImage = postImage
        }
        self.posts.append(self.post)
      }

      self.tableView.reloadData()
    }
  }
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.posts.count
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

    print("row:" + String(indexPath.row))
    print("r-row:" + String((self.posts.count - 1) - indexPath.row))
    let post = self.posts[(self.posts.count - 1) - indexPath.row]
    let imageView = cell.viewWithTag(1) as! UIImageView
    let fullNameLabel = cell.viewWithTag(2) as! UILabel
    let commentLabel = cell.viewWithTag(3) as! UILabel
    let imageURL = URL(string: post.postImage )!
    imageView.sd_setImage(with: imageURL, completed: nil)
    imageView.layer.cornerRadius = 8.0
    imageView.clipsToBounds = true
    fullNameLabel.text = post.fullName
    commentLabel.text = post.comment

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 443
  }


}
