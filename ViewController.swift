//
//  ViewController.swift
//  Jocelyn Decipher Code
//
//  Created by 钟立 on 16/7/20.
//  Copyright © 2016年 钟立. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let computer = CodeGenerator()
    
    @IBOutlet weak var inputNumber: UITextField!

    @IBOutlet weak var slogan: UILabel!
    @IBOutlet weak var hint: UILabel!
    @IBOutlet weak var remainingChances: UILabel!
    @IBOutlet weak var conclusion: UILabel!
    @IBOutlet weak var history: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var bubble1: UIImageView!
    @IBOutlet weak var bubble2: UIImageView!
    @IBOutlet weak var bubble3: UIImageView!
    @IBOutlet weak var bubble4: UIImageView!
    @IBOutlet weak var bubble5: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = view.frame.width
        hint.center.x -= width
        inputNumber.center.x += width
        button.center.x -= width
        remainingChances.center.x += width
        slogan.frame.origin.y = -50
        
        conclusion.isHidden = true
        conclusion.numberOfLines = 2
        
        imageView.alpha = 0
        
        //下面的代码让用户在点击文本框之外时，让文本框失焦，键盘因此能够自动缩回
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ViewController.viewTapped(_:)))
        //tapGesture.cancelsTouchesInView = false   //OC里面好像需要该行代码
        self.view.addGestureRecognizer(tapGesture)
        
        // 为气泡动画做准备
        bubble1.transform = CGAffineTransform(scaleX: 0, y: 0)
        bubble2.transform = CGAffineTransform(scaleX: 0, y: 0)
        bubble3.transform = CGAffineTransform(scaleX: 0, y: 0)
        bubble4.transform = CGAffineTransform(scaleX: 0, y: 0)
        bubble5.transform = CGAffineTransform(scaleX: 0, y: 0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startNewGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func guessTap(_ sender: AnyObject) {
        
        if button.titleLabel?.text == "Restart" {
            startNewGame()
            UIView.transition(with: self.remainingChances, duration: 0.8, options: .transitionFlipFromTop, animations: {self.remainingChances.isHidden = true}, completion: { _ in
                UIView.transition(with: self.remainingChances, duration: 0.5, options: .transitionFlipFromTop, animations: {self.remainingChances.isHidden = false}, completion: nil)
            })
            
            return
            
        } else if inputNumber.text == "" {
            //如果输入文本框什么都没有，就左右震一下，提示用户输入，并不计入猜的次数
            inputNumber.center.x -= 20
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0, options: [], animations: {
                self.inputNumber.center.x += 20}, completion: nil)
            return
        }
        
        if computer.count > 0 {
            guard inputNumber.text != "" else {return}
            
            //computer在执行checkGuess时，会对自身count变量进行－1
            let message = computer.checkGuess(inputNumber.text!)
            
            //让remainingChances每一回合都有一个翻转的效果
            UIView.transition(with: remainingChances, duration: 0.5, options: .transitionFlipFromTop, animations: {
                self.remainingChances.isHidden = false}, completion: nil)
            remainingChances.text = "\(computer.count) chances left"
            
            //让remainingChances的颜色随着所剩次数越来越少，从黑色逐渐变成红色
            let redCGFloat = CGFloat(10 - computer.count) / 10
            remainingChances.textColor = UIColor.init(red: redCGFloat, green: 0, blue: 0, alpha: 1)
            
            history.text?.append(message)
            
            //下面两行代码比较关键，决定了history这个Label能够根据字数的行数自动调整高度和宽度，并且在自适应之后再把宽度控制在了一个固定的值，这样就实现了宽度固定，高度自动调整的效果
            history.sizeToFit()
            history.frame.size.width = scrollView.frame.size.width
            
            scrollView.contentSize = CGSize(width: 0, height: history.frame.size.height * 1.2)
            
            let extraHeight = history.frame.size.height - scrollView.frame.size.height
            
            if extraHeight > 0 {
                //如果实际内容高度高于显示区域高度，就自动往上滑，保证最下面的信息能够显示出来
                scrollView.setContentOffset(CGPoint(x: 0, y: extraHeight), animated: true)
            } else {
                //如果实际内容高度小于显示区域高度，则加上一点上下震动的动画效果
                history.center.y += 10
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.15, initialSpringVelocity: 0, options: [], animations: {
                    self.history.center.y -= 10}, completion: nil)
            }
            

            inputNumber.text = ""
            
            if (computer.checkWin() == true){
                remainingChances.textColor = UIColor.init(red: 0, green: 0.5, blue: 0.3, alpha: 1)
                
                conclusion.text = "Brilliant Work!!! You've reasoned out the code successfully for Tommy!!"
                endGame()
            } else if computer.count == 0 {
                conclusion.text = "You didn't break the code within 10 guesses. Press 'Restart' to try again."
                endGame()
            }
        }
        
    }
    
    //刚刚进入程序时，以及一局游戏结束点击Restart键时，都会调用该函数
    func startNewGame() {
        computer.generate()
        button.setTitle("Guess", for: UIControlState())
        button.setTitleColor(UIColor.init(red: 0.05, green: 0.58, blue: 0.99, alpha: 1), for: UIControlState())
        remainingChances.text = "\(computer.count) chances left"
        remainingChances.textColor = UIColor.black
        inputNumber.text = ""
        hint.textColor = UIColor.gray
        
        startAnimation()
        
        inputNumber.keyboardType = UIKeyboardType.numberPad
        inputNumber.becomeFirstResponder()
        
        //history.text = "" //为了配合startAnimation中的动画，把这一步放到移出上一轮的history后自动完成了
        history.lineBreakMode = NSLineBreakMode.byWordWrapping
        history.numberOfLines = 0
        
    }
    
    //一局游戏结束，调用该函数重新设置各项组件，完成结束动画，并且为新的一局游戏做准备
    func endGame() {
        
        button.setTitle("Restart", for: UIControlState())
        button.setTitleColor(UIColor.orange, for: UIControlState())
        
        //结束时因为conclusion的动画还未完成，如果快速点击按钮会出现组件重叠的情况，所以先让按钮禁用，直到动画完成再解冻按钮
        button.isEnabled = false
        
        conclusion.sizeToFit()
        conclusion.frame = CGRect(x: 15, y: 50, width: view.frame.width - 30, height: 60)
        
        inputNumber.resignFirstResponder()
        
        endAnimation()
        
    }
    
    func viewTapped(_ tap: UITapGestureRecognizer) {
        inputNumber.resignFirstResponder()
    }
    
    func startAnimation() {
        
        //让五个气泡缩小消失
        let width = view.frame.width
        UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.bubble1.center.x += width
            self.bubble4.center.x += width
            }, completion: nil)
        UIView.animate(withDuration: 0.7, delay: 0.2, options: UIViewAnimationOptions(), animations: {
            self.bubble2.center.x -= width
            self.bubble5.center.x += width
            }, completion: nil)
        UIView.animate(withDuration: 0.8, delay: 0.4, options: UIViewAnimationOptions(), animations: {
            self.bubble3.center.x -= width
            }, completion: nil)
        
        //上一局的游戏结果从上面翻转进去消失
        UIView.transition(with: conclusion, duration: 0.3, options: .transitionFlipFromTop, animations: {self.conclusion.isHidden = true}, completion: nil)
        
        //四个控件分别从左右滑进来
        let centerX = self.view.center.x
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
            self.hint.center.x = centerX}, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut, animations: {
            self.inputNumber.center.x = centerX}, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseOut, animations: {
            self.button.center.x = centerX}, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 0.3, options: .curveEaseOut, animations: {
            self.remainingChances.center.x = centerX}, completion: nil)
        
        //上一局的history滑出屏幕，滑出后再将其内容清空，最后再把空的history放回原位
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseIn, animations: {
            self.history.frame.origin.y += self.view.frame.height
            }, completion: {_ in
                self.history.text = ""
                self.history.frame.origin = CGPoint(x: 0, y: 0)})
        
        //slogan从上方弹进屏幕
        UIView.animate(withDuration: 1.0, delay: 0.8, usingSpringWithDamping: 0.15, initialSpringVelocity: 0, options: [], animations: {self.slogan.frame.origin.y = 30}, completion: nil)
        
        
        UIView.animate(withDuration: 3, animations:{self.imageView.alpha = 0.2})
    
    }
    
    func endAnimation() {
        let width = view.frame.width
        
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseIn, animations: {
            self.hint.center.x -= self.view.frame.width}, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseIn, animations: {
            self.inputNumber.center.x += self.view.frame.width}, completion: nil)
        
        //先让slogan往上移，接着让conclusion翻转显示出来，完毕后再解冻button
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseIn, animations: {
            self.slogan.frame.origin.y = -50}, completion: {_ in
                UIView.transition(with: self.conclusion, duration: 0.3, options: .transitionFlipFromTop, animations: {
                    self.conclusion.isHidden = false}, completion: {_ in
                        self.button.isEnabled = true})})
        
        UIView.animate(withDuration: 1, animations:{self.imageView.alpha = 0.5})
        
        //先让五个气泡回归原位并且缩小至0
        bubble1.center.x -= width
        bubble2.center.x += width
        bubble3.center.x += width
        bubble4.center.x -= width
        bubble5.center.x -= width
        self.bubble1.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.bubble2.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.bubble3.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.bubble4.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.bubble5.transform = CGAffineTransform(scaleX: 0, y: 0)

        
        //再让五个气泡弹出来
        UIView.animate(withDuration: 0.8, delay: 0.8, usingSpringWithDamping: 0.2, initialSpringVelocity: 2, options: [], animations: {
            self.bubble1.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.bubble4.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        UIView.animate(withDuration: 0.9, delay: 0.9, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: [], animations: {
            self.bubble2.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.bubble5.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        UIView.animate(withDuration: 1.1, delay: 0.7, usingSpringWithDamping: 0.3, initialSpringVelocity: 4, options: [], animations: {
            self.bubble3.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
    }

}

