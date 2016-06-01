//
//  WJCollectionViewCell.swift
//  UICollectionScrollViewDemo
//
//  Created by 俊王 on 16/5/30.
//  Copyright © 2016年 WJ. All rights reserved.
//

import UIKit

class WJCollectionViewCell: UICollectionViewCell {
    
    var imageView:UIImageView!
    var titleLabel:UILabel!

    var title:String?{
        
        get{return self.title}
        
        set{
            if newValue?.characters.count > 0 {
                
                self.titleLabel.hidden = false
            }
            
            self.titleLabel.text = newValue
            print(self.titleLabel.text)
        }
    }
    
    var titleLabelTextColor:UIColor {
        
        get {return self.titleLabelTextColor}
        
        set {self.titleLabel.textColor = newValue}
    }
    
    var titleLabelTextFont:UIFont {
        
        get { return self.titleLabelTextFont }
       
        set { self.titleLabel.font = newValue }
    }
    
    var titleLabelBackgroundColor:UIColor {
        
        get { return self.titleLabelBackgroundColor }
        set { self.titleLabel.backgroundColor = newValue }
    }
    
    var titleLabelHeight:CGFloat! = 0
    var hasConfigured:Bool? = false
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setupImageView()
        self.setupTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupImageView() {
        
        let imageView = UIImageView.init()
        self.imageView = imageView
        self.contentView.addSubview(self.imageView)
    }
    
    func setupTitleLabel() {
        
        let titleLabel = UILabel.init()
        self.titleLabel = titleLabel
        self.titleLabel.hidden = true
        self.titleLabel.textAlignment = NSTextAlignment.Left
        self.contentView.addSubview(self.titleLabel)
    }
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.titleLabel.frame = CGRectMake(0, self.h - self.titleLabelHeight, self.w, self.titleLabelHeight)
    }
}
