//
//  EventViewController.swift
//  FollowUp
//
//  Created by Spencer Brown on 5/24/17.
//  Copyright © 2017 Spencer Brown. All rights reserved.
//

import UIKit
import EventKit

class EventViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    var viewState: MessagesViewController.AppState = MessagesViewController.AppState.initialView
    
    //Details stack
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var reminderContentLabel: UILabel!
    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var reminderTimeLabel: UILabel!
    @IBOutlet weak var createReminder: UIButton!
    
    //Completion stack
    @IBOutlet weak var confirmationLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    
    //Stack views
    @IBOutlet weak var detailsStack: UIStackView!
    @IBOutlet weak var completionStack: UIStackView!

    let eventStore = EKEventStore()
    
    var pickerKeys: [String] = [String]()
    
    var pickerValues: [MessagesViewController.PickerValue] = []
    
    var pickerIndex: Int = 0
    
    var eventTitle: String = ""

    
    //Identifier
    static let storyboardIdentifier = "EventVC"

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        updateVisuals()
        
        //Get a reference to the parent view
        guard let messageController = self.parent as? MessagesViewController else {
            fatalError("can't open")
        }
        
        //Set up picker
        picker.delegate = self
        picker.dataSource = messageController
        pickerKeys = messageController.pickerKeys
        pickerValues = messageController.pickerValues
        pickerIndex = messageController.pickerIndex
        
        picker.selectRow(messageController.pickerIndex, inComponent: 0, animated: true)
        
        setDateString(index: pickerIndex)
        
        //Set up text field
        reminderTextField.delegate = self
        
        //make the button have rounded corners
        

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
        
        setDateString(index: row)
        self.pickerIndex = row
        
        //update the state
        if (viewState == MessagesViewController.AppState.initialView){
            progressToNextState()
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Actions
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        
        checkCalendarAccess()
        
        //Create calendar event
        let event = EKEvent(eventStore: self.eventStore)
        
        event.title = eventTitle
        let cal = eventStore.defaultCalendarForNewEvents
        
        if cal == nil{
            
            print("calendar is null")
            event.calendar = EKCalendar(for: .event, eventStore: self.eventStore)
            
        } else {
            
            print("calendar is not null")
            event.calendar = cal
            print(event.calendar.title)
            
        }
        
        event.startDate = self.pickerValues[self.pickerIndex].date
        event.endDate   = Calendar.current.date(byAdding: .minute, value: 10, to: event.startDate)!
        
        do{
            
            try eventStore.save(event, span: EKSpan.thisEvent)
            sender.setTitle("Added Successfully!", for: .disabled)
            sender.isEnabled = false
            
            confirmationLabel.text = "Your Follow Up \nhas been set!"
            confirmationLabel.textColor = .green
            
            restartButton.setTitle("Create Another Follow Up", for: .normal)
            
        } catch let error {
            
            sender.setTitle("Something went wrong...", for: .disabled)
            sender.isEnabled = false
            print("Calendar failed with error \(error.localizedDescription)")
            
            confirmationLabel.text = "Something Went Wrong. \nYour Follow Up Was Not Set."
            confirmationLabel.textColor = .red
            
            restartButton.setTitle("Try Again", for: .normal)
            
        }
        
        progressToNextState()

    }
    
    //MARK: - Private Functions
    //Value of the text field changed
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        
        let message = "Follow up with " + sender.text!
        eventTitle = message
        reminderContentLabel.text = "\"" + message + "\""
        
    }
    
    //Get rid of the keyboard when editing done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    private func setDateString(index: Int){
        
        reminderTimeLabel.text = pickerValues[index].string
        
    }
    
    private func addPickerView(){
        
        
        
    }
    
    private func updateVisuals(){
        
        //Get a reference to the parent view
        guard let messageController = self.parent as? MessagesViewController else {
            fatalError("can't open")
        }
    
        switch viewState {
        case .initialView:
            print("in initial view")
            
            //Remove completion message
            completionStack.isHidden = true
            
            //Add picker view
            detailsStack.isHidden = false
            
            //Change to compact view
            messageController.requestPresentationStyle(.compact)
            break
        case .detailView:
            print("in detail view")
            //Change to expanded view
            messageController.requestPresentationStyle(.expanded)
            break
        case .completionView:
            print("in completion view")
            
            //Remove picker view
            detailsStack.isHidden = true
            
            //Add completion message
            completionStack.isHidden = false
            
            //change to compact view
            messageController.requestPresentationStyle(.compact)

        default:
            fatalError("PresentVC App State Switch Called Default with value \(viewState). This shouldnt be possible")
        }
    }
    
    //Check if the user has given access to the calendar
    private func checkCalendarAccess(){
        
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch status{
        case EKAuthorizationStatus.notDetermined:
            //On first time through
            requestAccessToCalendar()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            print("Access Denied")
        default:
            print("Access Available")
        }
        
    }
    
    //request access to calendar
    private func requestAccessToCalendar(){
        
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            //Eventually this will print access granted
            if !accessGranted{
                print("Access to store not granted")
            }
        }) //completion
    }//requestAccess...
    

    //Expand the view to an extended view
    private func progressToNextState(){
        
        //Get the parent controller so that I can manage the views
        guard let messageController = self.parent as? MessagesViewController else {
            fatalError("can't open")
        }

        //update the state
        viewState = messageController.changeState(viewState, shouldProgress: true)
        
        //Determine correct visuals
        updateVisuals()
        
    }

}
