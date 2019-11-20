//
//  ViewController.swift
//  Ring
//
//  Created by comsoft on 2019. 2. 15..
//  Copyright © 2019년 pigBrothers. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import SnapKit

class LoginController: UIViewController, GIDSignInUIDelegate {
    
    let buttonText = NSAttributedString(string: "FaceBook Login")
    @IBOutlet weak var GIDbtn : GIDSignInButton!
    @IBOutlet weak var FBbtn: FBSDKButton!
    var imageWidth : CGFloat = 200.0
    
    var subTitle : UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.boldSystemFont(ofSize: 15)
        title.text = "우리들의 연결고리"
        title.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
         title.textAlignment = .center
        return title
    }()
    
    var mainTitle : UILabel = {
       let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.boldSystemFont(ofSize: 30)
        title.text = "Ring"
        title.textAlignment = .center
        title.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        return title
    }()
    
    var mainImage : UIImageView = {
       let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = #imageLiteral(resourceName: "main_")
        return image
    }()
    
    var window: UIWindow?
    @IBOutlet var PwText: UITextField!
    @IBOutlet var EmailText: UITextField!
    @IBOutlet var LoginBtn : UIButton!
    @IBOutlet var SignIn : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageWidth = view.frame.width/2
        setup()
        //var preferredStatusBarStyle : UIStatusBarStyle = StatusBarStyle()
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance()?.uiDelegate = self
        
        FBbtn.setAttributedTitle(buttonText, for: .normal)
        view.backgroundColor = UIColor(displayP3Red: 221/255, green: 245/255, blue: 249/255, alpha: 1)
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func facebookLogin(sender: AnyObject){
        let LoginManager = FBSDKLoginManager()
        
        LoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (authResult, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                if authResult != nil {
                    let ref =  Database.database().reference(fromURL: "https://ring-677a1.firebaseio.com/")
                    let Reference = ref.child("users").child((authResult?.uid)!)
                    let values = ["email" : Auth.auth().currentUser?.email, "name" : Auth.auth().currentUser?.displayName, "profileImageUrl" : "https://firebasestorage.googleapis.com/v0/b/ring-677a1.appspot.com/o/profile_images%2F143E6E0A-1589-4BBF-8E2E-74AEBB3F19B4.png?alt=media&token=6a5cbf02-46d6-4d06-90db-8f7e6b33ead9"]
                    
                    Reference.updateChildValues(values)
                }
                let move = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController")
                move?.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                self.present(move!, animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func SignIn(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
        
        if GIDSignIn.sharedInstance()?.currentUser == nil {
            let move = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController")
            move?.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.present(move!, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func LoginBtn(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: EmailText.text!, password: PwText.text!) { (user, error) in
            if user != nil {
                let move = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController")
                move?.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                self.present(move!, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "로그인 실패", message: "잘못된 회원정보를 입력하셨습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    func setup(){
        view.addSubview(subTitle)
        subTitle.snp.makeConstraints { (make) in
            make.width.equalTo(view.snp.width)
            make.height.equalTo(20)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(50)
        }
         view.addSubview(mainImage)
        mainImage.snp.makeConstraints { (make) in
            make.width.equalTo(imageWidth)
            make.height.equalTo(imageWidth)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(subTitle.snp.bottom).offset(10)
        }
         view.addSubview(mainTitle)
        mainTitle.snp.makeConstraints { (make) in
            make.width.equalTo(view.snp.width)
            make.height.equalTo(35)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(mainImage.snp.bottom)
        }
        
        EmailText.snp.makeConstraints { (make) in
            make.width.equalTo(300)
            make.height.equalTo(35)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(mainTitle.snp.bottom).offset(20)
        }
        
        PwText.snp.makeConstraints { (make) in
            make.width.equalTo(300)
            make.height.equalTo(35)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(EmailText.snp.bottom).offset(10)
        }
        
        LoginBtn.snp.makeConstraints { (make) in
            make.width.equalTo(300)
            make.height.equalTo(35)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(PwText.snp.bottom).offset(30)
        }
        
        SignIn.snp.makeConstraints { (make) in
                   make.width.equalTo(300)
                   make.height.equalTo(35)
                   make.centerX.equalTo(view.snp.centerX)
                   make.top.equalTo(LoginBtn.snp.bottom).offset(10)
        }
        
        GIDbtn.snp.makeConstraints { (make) in
            make.width.equalTo(300)
            make.height.equalTo(35)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(SignIn.snp.bottom).offset(10)

        }
        
        FBbtn.snp.makeConstraints { (make) in
                  make.width.equalTo(300)
                  make.height.equalTo(35)
                  make.centerX.equalTo(view.snp.centerX)
                  make.top.equalTo(GIDbtn.snp.bottom).offset(10)

              }
    }
}
