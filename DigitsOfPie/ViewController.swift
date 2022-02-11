//
//  ViewController.swift
//  DigitsOfPie
//
//  Created by Michael Griebling on 4/9/19.
//  Copyright © 2019 Computer Inspirations. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    // This is the same as the first Machin-based Pi
    // program, except that it uses the "Integer" package's
    // infinite-sized integers to get as many digits as we
    // want.  It still computes the formula:
    // pi := 4 * (4 * arccot(5) - arccot(239))
    
    // We start out by defining a high-precision arc cotangent
    // function.  This one returns the response as an integer
    // - normally it would be a floating point number.  Here,
    // the integer is multiplied by the "unity" that we pass in.
    // If unity is 10, for example, and the answer should be "0.5",
    // then the answer will come out as 5
    
    @IBOutlet weak var digits: NSTextField!
    @IBOutlet var display: NSTextView!
    @IBOutlet weak var slider: NSSlider!
    
    var dispatchQueue = DispatchQueue(label: "MyQueue", qos: .background)
    
    func arccot(_ x : Int64, _ unity : Integer) -> Integer {
        let bigx = Integer(x)
        let xsquared = Integer(x * x)
        var sum = unity.div(bigx)
        var xpower = sum
        var n = Int64(3)
        var sign = false
        
        var term = Integer(0)
        while true {
            xpower = xpower.div(xsquared)
            term = xpower.div(Integer(n))
            if term.isZero {
                break
            }
            if sign {
                sum += term
            } else {
                sum -= term
            }
            sign = !sign
            n += 2
        }
        return sum
    }

    @IBAction func computePie(_ sender: NSSlider) {
        digits.stringValue = "\(sender.integerValue) digits"
        
        display.string = "Computing \(sender.integerValue) digits of π..."
        
        let digits = sender.integerValue + 10
        let unity = Integer(10) ** digits
        let four = Integer(4)
        
        dispatchQueue.async {
            let pi = four * (four * self.arccot(5, unity) - self.arccot(239, unity))
            
            DispatchQueue.main.async {
                var s = "\(pi)"
                s.insert(".", at: s.index(after: s.startIndex))  // add decimal point
                var index = s.startIndex
                while index < s.endIndex {
                    index = s.index(index, offsetBy: 6, limitedBy: s.endIndex) ?? s.endIndex
                    if index == s.endIndex { break }
                    s.insert(" ", at: index)
                }
                self.display.string = "π = \n\(s)"
            }
        }
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()

        // Do any additional setup after loading the view.
        computePie(slider)  // initial computation
    }
    
}

