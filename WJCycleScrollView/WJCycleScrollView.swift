//
//  WJCycleScrollView.swift
//  UICollectionScrollViewDemo
//
//  Created by 俊王 on 16/5/30.
//  Copyright © 2016年 WJ. All rights reserved.
//

import UIKit

enum WJCycleScrollViewPageContolAliment {
    case Right
    case Center
}

public enum WJCycleScrollViewPageContolStyle : Int {
    case classic   // 系统自带经典样式
    case animated  // 动画效果pagecontrol
    case none      // 不显示pagecontrol
}

/** block方式监听点击 */
typealias clickItemOperationBlock = (currentIndex:Int) -> Void

/** block方式监听滚动 */
typealias itemDidScrollOperationBlock = (currentIndex:Int) -> Void

class WJCycleScrollView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {

    var mainView:UICollectionView! //显示图片的collectionView
    var flowLayout:UICollectionViewFlowLayout!
    
    var clickItemBlock:clickItemOperationBlock?
    
    var itemDidScrollBlock:itemDidScrollOperationBlock?

    var imagePathsGroup:NSArray! {
        
        didSet{
        
            self.totalItemsCount = self.imagePathsGroup.count
            
            if self.infiniteLoop == true {
                
                self.totalItemsCount = self.imagePathsGroup.count * 100
            }
            
            if imagePathsGroup.count != 1 {
                mainView.scrollEnabled = true
                setupAutoScroll()
            }
            else{
                invalidateTimer()
                mainView.scrollEnabled = false
            }
            
            setupPageControl()
            self.mainView.reloadData()
        }
    }

    var locationPathsGroup:NSArray
        {
        get {
            return self.imagePathsGroup
        }
        set {
            self.imagePathsGroup = newValue
        }
    }
    
    var imageURLStringsGroup:NSArray {
        get {
            return self.imagePathsGroup
        }
        set{
            
            var temp = Array<String>()
            for (_, object) in newValue.enumerate() {
                
                var urlString:String?
                if object is String {
                    
                    urlString = object as? String
                }
                else if object is NSURL {
                    
                    let url = object as? NSURL
                    urlString = url?.absoluteString
                }
                
                if urlString?.characters.count > 0 {
                    
                    temp.append(urlString!)
                }
            }
            
            self.imagePathsGroup = temp
        }
        
    }

    var pageControl:UIControl!
    var timer:NSTimer!
    
    var backgroundImageView: UIImageView! // 当imageURLs为空时的背景图
    var totalItemsCount:Int? = 0
    
    var collectionCell:WJCollectionViewCell!
    
    // MARK: - 滚动控制属性
    
    /** 是否无限循环,默认Yes */
    var infiniteLoop:Bool? = false
    /** 是否自动滚动,默认Yes */
    var autoScroll:Bool? = false
    /** 图片滚动方向，默认为水平滚动 */
    var scrollDirection:UICollectionViewScrollDirection?
    /** 自动滚动间隔时间,默认2s */
    var autoScrollTimeInterval: Double?
    
    // MARK: -  自定义样式接口
    /** 轮播图片的ContentMode，默认为 UIViewContentModeScaleToFill */
    var bannerImageViewContentMode:UIViewContentMode?
    /** 占位图，用于网络未加载到图片时 */
    var placeholderImage:UIImage!
    /** 是否显示分页控件 */
    var showPageControl:Bool?
    /** 是否在只有一张图时隐藏pagecontrol，默认为YES */
    var hidesForSinglePage:Bool?
    /** pagecontrol 样式，默认为动画样式 */
    var pageControlStyle:WJCycleScrollViewPageContolStyle!
    /** 分页控件位置 */
    var pageControlAliment:WJCycleScrollViewPageContolAliment?
    /** 分页控件小圆标大小 */
    var pageControlDotSize:CGSize?
    /** 当前分页控件小圆标颜色 */
    var currentPageDotColor:UIColor?
    /** 其他分页控件小圆标颜色 */
    var pageDotColor:UIColor?
    /** 当前分页控件小圆标图片 */
    var currentPageDotImage:UIImage?
    /** 其他分页控件小圆标图片 */
    var pageDotImage:UIImage?
    /** 轮播文字label字体颜色 */
    var titleLabelTextColor:UIColor?
    /** 轮播文字label字体大小 */
    var titleLabelTextFont:UIFont?
    /** 轮播文字label背景颜色 */
    var titleLabelBackgroundColor:UIColor?
    /** 轮播文字label高度 */
    internal var titleLabelHeight:CGFloat?
    //** 每张图片对应要显示的文字数组 */
    var titlesGroup:NSArray?
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupMainView()
        initializiton()
    }
    
    convenience init(frame: CGRect, images: Array<String>) {
        self.init(frame:frame)
        
        self.locationPathsGroup = images
    }
    
    convenience init(frame: CGRect, images: Array<String>, infiniteLoop:Bool) {
        self.init(frame:frame)
        
        self.infiniteLoop = infiniteLoop
        self.locationPathsGroup = images
    }
    
    convenience init(frame: CGRect, urlImages: Array<String>, placeholderImage:UIImage) {
        self.init(frame:frame)
        
        self.placeholderImage = placeholderImage
        self.imageURLStringsGroup = urlImages
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializiton() {
        
        self.pageControlAliment = WJCycleScrollViewPageContolAliment.Center
        self.autoScrollTimeInterval = 2.0
        self.titleLabelTextColor = UIColor.whiteColor()
        self.titleLabelTextFont = UIFont.systemFontOfSize(12)
        self.titleLabelBackgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.titleLabelHeight = 30
        self.autoScroll = true
        self.infiniteLoop = true
        self.pageControlDotSize = CGSizeMake(self.titleLabelHeight!, self.titleLabelHeight!)
        self.pageControlStyle = WJCycleScrollViewPageContolStyle.classic
        self.hidesForSinglePage = true
        self.currentPageDotColor = UIColor.whiteColor()
        self.pageDotColor = UIColor.lightGrayColor()
        self.bannerImageViewContentMode = UIViewContentMode.ScaleToFill
        self.showPageControl = true
        setupAutoScroll()
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    
    // 设置显示的图片的collectionView
    func setupMainView() {
        
        self.flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        self.mainView = UICollectionView.init(frame: self.bounds, collectionViewLayout: self.flowLayout)
        mainView.backgroundColor = UIColor.clearColor()
        mainView.pagingEnabled = true
        mainView.showsHorizontalScrollIndicator = false
        mainView.showsVerticalScrollIndicator = false
        mainView.registerClass(WJCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(WJCollectionViewCell.self))
        mainView.delegate = self
        mainView.dataSource = self
        mainView.scrollsToTop = false
        self.addSubview(mainView)
    }
    
    
    // MARK: - life circles
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.flowLayout.itemSize = self.size
        self.mainView.frame = self.bounds
        
        if mainView.contentOffset.x == 0 && totalItemsCount > 0 {
            
            let targetIndex = 0
            
            mainView.scrollToItemAtIndexPath(NSIndexPath.init(forRow: targetIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
        }
        
        var size = CGSizeZero
        size = CGSizeMake(CGFloat(self.imagePathsGroup.count) * CGFloat(self.pageControlDotSize!.width) * 1.2, self.pageControlDotSize!.height)
        
        var x  = (self.frame.size.width - size.width)/2
        
        if self.pageControlAliment == WJCycleScrollViewPageContolAliment.Right {
            
            x = self.mainView.w - size.width
        }
        
        let y = self.mainView.h - (self.titleLabelHeight! - size.height)/2 - size.height

        self.pageControl.frame = CGRectMake(x, y, size.width, size.height)
        self.pageControl.hidden = !self.showPageControl!
    }
    
    // MARK: - actions
    func setupTimer() {
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(self.autoScrollTimeInterval!, target: self, selector: #selector(WJCycleScrollView.automaticScroll), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
    }
    
    func setupAutoScroll() {
        
        invalidateTimer()
        if self.autoScroll == true {
            
            setupTimer()
        }
    }
    
    func invalidateTimer() {
        
        if (self.timer != nil) {

            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    func setupPageControl() {
        
        if (self.pageControl != nil) {
            
            pageControl.removeFromSuperview()
        }
        
        if self.imagePathsGroup.count == 0 {return}
        if self.imagePathsGroup.count == 1 && self.hidesForSinglePage == true {return}
        
        let indexOnPageControl = self.currentIndex() % self.imagePathsGroup.count
        
        switch self.pageControlStyle as WJCycleScrollViewPageContolStyle {
        case .classic:
            
            let pageControl = UIPageControl.init()
            pageControl.numberOfPages = self.imagePathsGroup.count
            pageControl.currentPageIndicatorTintColor = self.currentPageDotColor
            pageControl.pageIndicatorTintColor = self.pageDotColor
            pageControl.userInteractionEnabled = false
            pageControl.currentPage = indexOnPageControl
            self.pageControl = pageControl
            self.addSubview(self.pageControl)

            break
            
        default:
            break
        }
        
    }
    
    func automaticScroll() {
        
        if totalItemsCount == 0 {return}
        let currentIndex = self.currentIndex()
        var targetIndex = currentIndex + 1
        
        if targetIndex >= totalItemsCount {
            if self.infiniteLoop == true {

                targetIndex = 0
                mainView.scrollToItemAtIndexPath(NSIndexPath.init(forRow: targetIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: true)
            }
            
            return
        }
        mainView.scrollToItemAtIndexPath(NSIndexPath.init(forRow: targetIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: true)
    }
    
    func currentIndex() -> Int {
        
        if (self.mainView.w == 0 || self.mainView.h == 0) {return 0}
        
        var index  = 0
        
        if self.flowLayout.scrollDirection == UICollectionViewScrollDirection.Horizontal {
            
            index = Int((mainView.contentOffset.x + flowLayout.itemSize.width/2) / flowLayout.itemSize.width)
        }
        else{
            
            index = Int((mainView.contentOffset.y + flowLayout.itemSize.height/2) / flowLayout.itemSize.height)
        }
        
        return index
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.totalItemsCount!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(WJCollectionViewCell.self), forIndexPath: indexPath)
        self.collectionCell = cell as! WJCollectionViewCell
        let itemIndex = indexPath.item % self.imagePathsGroup.count;
        let imagePath = self.imagePathsGroup[itemIndex]

        if imagePath is String {
            
            if imagePath.hasPrefix("http") {
                
                collectionCell.imageView.sd_setImageWithURL(NSURL.init(string: imagePath as! String), placeholderImage: self.placeholderImage)
            }
            else{
                
                let image = UIImage.init(named: imagePath as! String)
                collectionCell.imageView.image = image
            }
        }
        else if (imagePath is UIImage){
            
            collectionCell.imageView.image = imagePath as? UIImage
        }
        
        if self.titlesGroup?.count > 0 && itemIndex < self.titlesGroup?.count {
            
            collectionCell.title = self.titlesGroup![itemIndex] as? String
        }
        
        if (!collectionCell.hasConfigured!) {
            collectionCell.titleLabelBackgroundColor = self.titleLabelBackgroundColor!
            collectionCell.titleLabelHeight = self.titleLabelHeight!
            collectionCell.titleLabelTextColor = self.titleLabelTextColor!
            collectionCell.titleLabelTextFont = self.titleLabelTextFont!
            collectionCell.hasConfigured = true
            collectionCell.imageView.contentMode = self.bannerImageViewContentMode!
            collectionCell.clipsToBounds = true
        }
        
        return self.collectionCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            
        if (self.clickItemBlock != nil){
            
            self.clickItemBlock!(currentIndex: indexPath.item % self.imagePathsGroup.count)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if self.imagePathsGroup.count == 0 {return}
        
        let itemIndex = self.currentIndex()
        let indexOnPageControl = itemIndex % self.imagePathsGroup.count
        
        let pControl:UIPageControl = self.pageControl as! UIPageControl
        pControl.currentPage = indexOnPageControl
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        if self.autoScroll == true {
            invalidateTimer()
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if self.autoScroll == true {
            setupTimer()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        self.scrollViewDidEndScrollingAnimation(self.mainView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        if self.imagePathsGroup.count == 0 {
            return
        }
        
        let itemIndex = self.currentIndex()
        let indexOnPageControl = itemIndex % self.imagePathsGroup.count
        
        if (self.itemDidScrollBlock != nil){
            
            self.itemDidScrollBlock!(currentIndex: indexOnPageControl)
        }
    }
    
    func itemScrollBlock(scrollBlock:(Int)-> Void) {
        
        self.itemDidScrollBlock = scrollBlock
        
    }
    
    func clickItemBlock(clickBlock:(Int) -> Void) {
        
        self.clickItemBlock = clickBlock
    }
}
