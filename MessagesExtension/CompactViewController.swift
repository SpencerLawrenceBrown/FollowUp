//
//  CompactViewController.swift
//  FollowUp
//
//  Created by Spencer Brown on 4/15/17.
//  Copyright © 2017 Spencer Brown. All rights reserved.
//
// A 'UIViewController at displays the basic view for a reminder -- prompts to create the whole reminder
//

import UIKit

class CompactViewController: UIViewController, UIPickerViewDelegate{

    //MARK: Properties
    var viewState: MessagesViewController.AppState = MessagesViewController.AppState.initialView
    

    @IBOutlet weak var picker: UIPickerView!
    var pickerKeys: [String] = [String]()
    
    //Identifier
    static let storyboardIdentifier = "CompactVC"
    
    //MARK: Controller Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("compact view show");
        
        //Get a reference to the parent view
        guard let messageController = self.parent as? MessagesViewController else {
            fatalError("can't open")
        }
        
        //Set up picker
        picker.delegate = self
        picker.dataSource = messageController
        print(messageController.pickerKeys)
        pickerKeys = messageController.pickerKeys
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Picker Delegate Functions
    //When naming the picker rows
    func pickerView(_ pickerView: UIPickerView,
                             titleForRow row: Int,
                             forComponent component: Int) -> String?{
        
        return pickerKeys[row]
    }
    
    //When a value is selected in the picker
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int){
        
        //Get a reference to the parent view
        guard let parentController = self.parent as? MessagesViewController else {
            fatalError("can't open")
        }
        
        parentController.setPickerValue(row: row)
        
        //Request the expanded view
        progressToNextView()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    //Expand the view to an extended view
    private func progressToNextView(){
        
        //Get the parent controller so that I can manage the views
        guard let messageController = self.parent as? MessagesViewController else {
            fatalError("can't open")
        }
        
        messageController.changeState(viewState, shouldProgress: true)
        
        
    }
    

}
