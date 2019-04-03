//
//  ViewController.swift
//  SwiftPetSNS
//
//  Created by seijiro on 2019/04/02.
//  Copyright © 2019 norainu. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {

  @IBOutlet var userNameTextField: UITextField!
  override func viewDidLoad() {
    super.viewDidLoad()
    userNameTextField.delegate = self
    // Do any additional setup after loading the view.
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if UserDefaults.standard.object(forKey: "userName") != nil {
      performSegue(withIdentifier: "next", sender: nil)
    }
  }

  @IBAction func login(_ sender: Any) {
    UserDefaults.standard.set(userNameTextField.text, forKey: "userName")
    performSegue(withIdentifier: "next", sender: nil)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    userNameTextField.resignFirstResponder();
    return true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    userNameTextField.resignFirstResponder()
  }
  
}

