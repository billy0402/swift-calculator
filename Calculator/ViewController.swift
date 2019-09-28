//
//  ViewController.swift
//  Calculator
//
//  Created by User on 2019/7/18.
//  Copyright © 2019 User. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var numberArray = Array<Decimal>()
    var symbolArray = Array<Symbol>()
    var textLimitLength = 0
    
    @IBOutlet weak var inputLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textLimitLength = inputLabel.getMaxTextLength()
    }
    
    // 所有按鍵
    @IBAction func tapAny(_ button: UIButton) {
        print("Tapping: \(button.currentTitle!)")
        let originLabelText = inputLabel.text!
        
        // 限制最大字數
        if originLabelText.count > textLimitLength * 2 {
            textLimitAlert()
        }
    }
    
    // 運算元
    @IBAction func tapDigit(_ button: UIButton) {
        let digit = button.currentTitle!
        let originLabelText = inputLabel.text!
        
        // 消除 Label 的 ０
        if originLabelText == "0" {
            inputLabel.text! = digit
        } else {
            inputLabel.text! += digit
        }
    }
    
    // 小數點
    @IBAction func tapDot(_ button: UIButton) {
        let dot = button.currentTitle!
        let originLabelText = inputLabel.text!
        
        // 防止小數點連點
        if originLabelText.last != "." {
            inputLabel.text! += dot
        }
    }
    
    // 運算子
    @IBAction func tapSymbol(_ button: UIButton) {
        let symbol = button.currentTitle!
        let originLabelText = inputLabel.text!
        
        // +/- % 運算
        if symbol == "+/-" || symbol == "%" {
            guard originLabelText.isNumber || originLabelText.first == "-" else {
                return
            }
            
            let number = Decimal(string: originLabelText)!
            let result = symbol == "+/-" ? number * -1 : number / 100
            inputLabel.text! = resultFormatter(result)
            return
        }
        
        // 防止符號連點
        if !originLabelText.last!.isNumber {
            inputLabel.text!.removeLast()
        }
        
        inputLabel.text! += symbol
    }
    
    // 等號
    @IBAction func tapEqual(_ button: UIButton) {
        let originLabelText = inputLabel.text!
        
        // 特殊情況 URL
        if originLabelText == "11+22" {
            specialUrlAlert()
            return
        }
        
        // 防止符號句尾
        if !originLabelText.last!.isNumber {
            return
        }
        
        numberArray.removeAll()
        symbolArray.removeAll()
        
        divideNumberSymbol()
        
        let result = getResult()
        inputLabel.text! = resultFormatter(result)
    }
    
    // 刪除
    @IBAction func tapDelete(_ button: UIButton) {
        inputLabel.text!.removeLast()
        
        // 防止完全清空畫面
        if inputLabel.text!.isEmpty {
            inputLabel.text! = "0"
        }
    }
    
    // 清除
    @IBAction func tapClear(_ button: UIButton) {
        inputLabel.text! = "0"
    }
    
    // 將輸入框的 數字 與 符號 分開
    func divideNumberSymbol() {
        var originLabelText = inputLabel.text!
        
        // 防止負號開頭
        if originLabelText.first == "-" {
            originLabelText = "0" + originLabelText
        }
        
        for text in originLabelText {
            if let symbol = Symbol(rawValue: text) {
                let index = originLabelText.firstIndex(of: text)!
                let nextIndex = originLabelText.index(after: index)
                
                let front = String(originLabelText[..<index]) // 前面數字
                let back = String(originLabelText[nextIndex...]) // 後面數字
                
                if front.isNumber {
                    numberArray.append(Decimal(string: front)!)
                }
                if back.isNumber {
                    numberArray.append(Decimal(string: back)!)
                }
                symbolArray.append(symbol)
                
                originLabelText.removeSubrange(..<nextIndex)
            }
        }
    }
    
    func getResult() -> Decimal {
        let originLabelText = inputLabel.text!
        var result = numberArray.isEmpty ? Decimal(string: originLabelText)! : Decimal()
        
        while !symbolArray.isEmpty {
            let sortedSymbolArray = getSortedSymbolArray()
            
            let frontIndex = sortedSymbolArray.first!
            let backIndex = frontIndex + 1
            let frontNumber = numberArray[frontIndex]
            let backNumber = numberArray[backIndex]
            
            switch symbolArray[frontIndex] {
            case .multiplied:
                result = frontNumber * backNumber
            case .divided:
                result = frontNumber / backNumber
            case .plus:
                result = frontNumber + backNumber
            case .minus:
                result = frontNumber - backNumber
            }
            
            numberArray[backIndex] = result
            numberArray.remove(at: frontIndex)
            symbolArray.remove(at: frontIndex)
        }
        
        return result
    }
    
    func getSortedSymbolArray() -> Array<Int> {
        let prioritySymbolArray = symbolArray.indexes(of: Symbol.multiplied, or: Symbol.divided)
        let normalSymbolArray = symbolArray.indexes(of: Symbol.plus, or: Symbol.minus)
        
        return prioritySymbolArray + normalSymbolArray
    }
    
    func resultFormatter(_ result: Decimal) -> String {
        // 防止 ÷0 和 超出上限
        if !result.isComputable {
            return "error"
        }
        
        var resultString = result.description
        let resultIntString = String(Int(truncating: result as NSNumber))
        
        if resultString.count > textLimitLength {
            let numberFormatter = NumberFormatter()
            if Decimal(string: resultIntString) == result {
                numberFormatter.numberStyle = .scientific
                numberFormatter.maximumIntegerDigits = textLimitLength - 3
                numberFormatter.maximumFractionDigits = 2
            } else {
                let intLength = resultIntString.count
                let pointLength = textLimitLength - intLength - 1
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumIntegerDigits = intLength
                numberFormatter.maximumFractionDigits = pointLength
            }
            
            resultString = numberFormatter.string(from: result as NSDecimalNumber)!
        }
        
        return resultString
    }
    
    func textLimitAlert() {
        let controller = UIAlertController(title: "⚠️ 警告", message: "超過字數上限", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.inputLabel.text!.removeLast()
        })
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    func specialUrlAlert() {
        let controller = UIAlertController(title: "外部連結", message: "Ｇoogle", preferredStyle: .alert)
        let linkAction = UIAlertAction(title: "前往", style: .default, handler: { (action) in
            let url = URL(string: "https://www.google.com.tw/")!
            UIApplication.shared.open(url)
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(linkAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }

}

enum Symbol: Character {
    case plus = "+"
    case minus = "-"
    case multiplied = "×"
    case divided = "÷"
}
