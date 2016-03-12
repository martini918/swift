//
//  ViewController.swift
//  TexasHoldem
//
//  Created by larryhou on 6/3/2016.
//  Copyright © 2016 larryhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var progressInfo: UILabel!
    @IBOutlet weak var progressIndicator: UIProgressView!
    
    @IBOutlet weak var peopleStepper: UIStepper!
    @IBOutlet weak var peopleInput: UITextField!
    
    @IBOutlet weak var roundStepper: UIStepper!
    @IBOutlet weak var roundInput: UITextField!
    
    private let background_queue = dispatch_queue_create("TexasHoldem.background", nil)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func generateGameRounds(roundCount:Int, personCount:Int)
    {
        var digitCount = 0
        var value = Double(roundCount)
        while value >= 1
        {
            value /= 10
            digitCount++
        }
        
        print(digitCount, personCount, roundCount)
        dispatch_async(background_queue)
        {
            var stats:[Int:[HandPattern:Int]] = [:]
            var data:[Int:UniqueRound] = [:]
            
            let start = NSDate()
            for n in 0..<roundCount
            {
                let round = UniqueRound(index: n)
                data[round.index] = round
                
                let result = PokerDealer.deal(personCount)
                for i in 0..<result.count
                {
                    result[i].evaluate()
                    round.list.append(RawPokerHand(id: UInt8(i), data: result[i].rawValue))
                    
                    let hand = result[i]
                    if stats[i] == nil
                    {
                        stats[i] = [:]
                    }
                    
                    if stats[i]?[hand.pattern] == nil
                    {
                        stats[i]?[hand.pattern] = 0
                    }
                    
                    stats[i]?[hand.pattern]?++
                }
                
                dispatch_async(dispatch_get_main_queue())
                {
                    self.updateProgressIndicator(n + 1, total: roundCount, digitCount: digitCount, elapse: NSDate().timeIntervalSinceDate(start))
                }
            }
            
            print(stats)
            dispatch_async(dispatch_get_main_queue())
            {
                self.setViewModel(data, stats: stats);
            }
        }
    }
    
    func setViewModel(data:[Int:UniqueRound], stats:[Int:[HandPattern:Int]])
    {
        
    }
    
    func updateProgressIndicator(count:Int, total:Int, digitCount:Int, elapse:NSTimeInterval)
    {
        progressInfo.text = String(format: "%0\(digitCount)d/%d %5.2f%% %5.3fs", count, total, Double(count) * 100 / Double(total), elapse)
        progressIndicator.progress = Float(count)/Float(total)
    }
    
    @IBAction func simulate(sender: AnyObject)
    {
        let roundCount = roundInput.text != "" ? NSString(string: roundInput.text!).integerValue : Int(roundStepper.value)
        let personCount = peopleInput.text != "" ? NSString(string: peopleInput.text!).integerValue : Int(peopleStepper.value)
        
        generateGameRounds(roundCount, personCount: personCount)
    }
    
    //MARK:text input
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField == peopleInput
        {
            var value = NSString(string: peopleInput.text!).doubleValue
            value = max(min(peopleStepper.maximumValue, value), peopleStepper.minimumValue);
            
            peopleInput.text = String(format: "%.0f", value)
            peopleStepper.value = value
        }
        else
        if textField == roundInput
        {
            var value = NSString(string: roundInput.text!).doubleValue
            value = max(min(roundStepper.maximumValue, value), roundStepper.minimumValue);
            
            roundInput.text = String(format: "%.0f", value)
            roundStepper.value = value
        }
        
        return true
    }
    
    @IBAction func setPeopleCount(sender: AnyObject)
    {
        if sender is UIStepper
        {
            peopleInput.text = String(format: "%.0f", peopleStepper.value)
        }
    }
    
    @IBAction func setRoundCount(sender: AnyObject)
    {
        if sender is UIStepper
        {
            roundInput.text = String(format: "%.0f", roundStepper.value)
        }
    }
    
//    override func prefersStatusBarHidden() -> Bool
//    {
//        return true
//    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
