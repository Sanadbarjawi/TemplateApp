 //
//  ViewController.swift
//  TemplateApp
//
//  Created by Sanad Barjawi on 8/9/18.
//  Copyright © 2018 Sanad Barjawi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ColorUpdatable{
    @IBOutlet weak var txtField1: UITextField!
    @IBOutlet weak var txtField2: UITextField!
    @IBOutlet weak var txtField3: UITextField!
    @IBOutlet weak var txtField4: UITextField!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomButton: UIButton!
    
    func updateColors(for theme: Theme) {
        navigationController?.navigationBar.barTintColor = .navbarTintColor(for: theme)
        containerView.backgroundColor = .contentBackground(for: theme)
        txtField1.backgroundColor = .txtfieldBackground(for: theme)
        txtField2.backgroundColor = .txtfieldBackground(for: theme)
        txtField3.backgroundColor = .txtfieldBackground(for: theme)
        txtField4.backgroundColor = .txtfieldBackground(for: theme)
        bottomButton.setTitleColor(.buttonTextColor(for: theme), for: .normal)
    }
    var theme: Theme = .light

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addDidChangeColorThemeObserver()
        updateColors(for: theme)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        removeDidChangeColorThemeObserver()
    }
    @IBAction func changeThemePressed(_ sender: Any) {
       
       CustomNotification.didChangeColorTheme.post(userInfo: Theme.dark)
        bottomButton.setTitle("Welcome to the dark side", for: .normal)
    }
    
}

