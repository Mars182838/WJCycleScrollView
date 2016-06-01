//
//  ViewController.swift
//  WJCycleScrollViewDemo
//
//  Created by 俊王 on 16/6/1.
//  Copyright © 2016年 WJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageNames = ["h1.jpg","h2.jpg","h3.jpg","h4.jpg"]
        
        //***********************本地图片 默认轮播 **************************//
        
        let cycleScrollView = WJCycleScrollView.init(frame: CGRectMake(0, 64, self.view.w, 180), images:imageNames)
        
        cycleScrollView.itemScrollBlock { (currentIndex:Int) in
            
            print("itemBlcok:\(currentIndex)")
        }
        
        cycleScrollView.clickItemBlock { (currentIndex:Int) in
            
            print("clickBlcok:\(currentIndex)")
            
        }
        self.view.addSubview(cycleScrollView)
        
        //*********************** 本地图片 & 控制是否轮播 **************************//
        
        let cycleScrollView1 = WJCycleScrollView.init(frame: CGRectMake(0,264, self.view.w, 180), images: imageNames, infiniteLoop: false)
        cycleScrollView1.itemScrollBlock { (currentIndex:Int) in
            
            print("itemBlcok:\(currentIndex)")
        }
        
        cycleScrollView1.clickItemBlock { (currentIndex:Int) in
            
            print("clickBlcok:\(currentIndex)")
            
        }
        self.view.addSubview(cycleScrollView1)
        
        //*********************** 网络图片 **************************//
        
        let urlImageNames = [
            "https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
            "https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
            "http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"
        ]
        
        let cycleScrollView2 = WJCycleScrollView.init(frame: CGRectMake(0,464, self.view.w, 180), urlImages: urlImageNames, placeholderImage:UIImage.init(named: "placeholder")!)
        
        cycleScrollView2.titlesGroup = ["我们很好啊!","我们其实没那么好！！","我们非常棒哦！！！！"]
        cycleScrollView2.itemScrollBlock { (currentIndex:Int) in
            
            print("itemBlcok:\(currentIndex)")
        }
        
        cycleScrollView2.clickItemBlock { (currentIndex:Int) in
            
            print("clickBlcok:\(currentIndex)")
            
        }
        self.view.addSubview(cycleScrollView2)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

