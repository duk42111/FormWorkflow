//
//  ViewController.swift
//  FormWorkflow
//
//  Created by Olivier Halligon on 12/12/2015.
//  Copyright © 2015 AliSoftware. All rights reserved.
//

import UIKit
import PromiseKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  @IBAction func startWorkflow(sender: UIButton) {
    let nc = UINavigationController()
    self.presentViewController(nc, animated: true, completion: nil)
    
    firstly {
      self.pushScreen1(nc)
    }
    .then {
      self.pushScreen2(nc)
    }
    .recover { (error: ErrorType) -> Void in
      try self.handleCancellation(error)
    }
    .always {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    .error { e in
      print("Wooops, something bad (other than a cancellation) happened: \(e)")
    }
  }
  
  
  
  
  private func pushScreen1(nc: UINavigationController) -> Promise<Void> {
    let firstNameEntry = FormEntry<String>(label: "Prénom", value: "Paul") { $0?.characters.count > 0 }
    let lastNameEntry = FormEntry<String>(label: "Nom", value: "Auchon") { $0?.characters.count > 0 }
    let checkEntry = FormEntry<Bool>(label: "Plus de 21 ans") { $0 == true }
    let form = FormViewController.instance(items: [firstNameEntry, lastNameEntry, checkEntry])
    
    nc.pushViewController(form, animated: false)
    
    return form.promise().then { () -> () in
      // Process result of this screen before moving to next screen
      let (surname, lastname, okAge) = (firstNameEntry.value!, lastNameEntry.value!, checkEntry.value)
      print("\(surname) \(lastname) — Age OK = \(okAge ?? false)")
    }
  }
  
  
  
  
  private func pushScreen2(nc: UINavigationController) -> Promise<Void> {
    let licenseEntry = FormEntry<String>(label: "Numéro de permis", value: "12345054321") { $0?.characters.count > 0 }
    let cbEntry = FormEntry<String>(label: "Carte Bleue", value: "**** **** 4242") { $0?.characters.count > 0 }
    let form = FormViewController.instance(items: [licenseEntry, cbEntry])
    
    nc.pushViewController(form, animated: true)
    
    return form.promise().then { () -> () in
      // Process result of this screen before moving to next screen
      print("License \(licenseEntry.value!), CB = \(cbEntry.value!)")
    }
  }
  
  
  
  private func handleCancellation(error: ErrorType) throws -> Void {
    guard let exitError = error as? ExitPointError else { throw error }
    switch exitError {
    case .CancelCheckInOut:
      print("Cancelled the CheckIn or CheckOut")
    case .CancelBooking:
      print("Cancelled the whole Booking!")
    }
  }
  
}
