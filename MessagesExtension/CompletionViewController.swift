//
//  CompletionViewController.swift
//  FollowUp
//
//  Created by Spencer Brown on 5/19/17.
//  Copyright © 2017 Spencer Brown. All rights reserved.
//

import UIKit

class CompletionViewController: UIViewController {
    
    //MARK: - Properties
    
    var viewState: MessagesViewController.AppState = MessagesViewController.AppState.completionView

    //Identifier
    static let storyboardIdentifier = "CompletionVC"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - UI Actions
    
    @IBAction func returnToFirstView(_ sender: UIButton) {
        
        progressToNextView();
        
    }
    
    
    
    //MARK: - Private Functions
    
    //Expand the view to an extended view
    private func progressToNextView(){
        
        //Get the parent controller so that I can manage the views
        guard let messageController = self.parent as? MessagesViewController else {
            fatalError("can't open")
        }
        
        messageController.changeState(viewState, shouldProgress: true)
        
        
    }

}
