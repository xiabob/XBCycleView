//
//  XBCycleView.swift
//  XBCycleView
//
//  Created by xiabob on 16/6/13.
//  Copyright © 2016年 xiabob. All rights reserved.
//

import UIKit

public protocol XBCycleViewDelegate: NSObjectProtocol {
    func tapImage(cycleView: XBCycleView, currentImage: UIImage?, currentIndex: Int)
}

public class XBCycleView: UIView, UIScrollViewDelegate {
    //MARK: - private var
    //size
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    
    //index
    private var currentIndex: Int = 0
    private var nextIndex: Int = 0
    
    //subviews
    private lazy var scrollView: UIScrollView = self.configScrollView()
    private lazy var currentImageView: UIImageView = self.configImageView()
    private lazy var nextImageView: UIImageView = self.configImageView()
    private lazy var pageControl: UIPageControl = self.configPageControl()
    private lazy var tapGesture: UITapGestureRecognizer = { [unowned self] in
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(tapImageView))
        return tap
        }()
    
    //timer
    private var timer: NSTimer?
    
    private var downloader = XBImageDownloader()
    
    //MARK: - public api var
    public var imageModelArray = [XBCycleViewImageModel]() {
        didSet { updateCycleView() }
    }
    ///是否是自动循环轮播，默认为true
    public var isAutoCycle: Bool = true {
        didSet {
            if isAutoCycle {
                addTimer()
            } else {
                removeTimer()
            }
        }
    }
    
    ///自动轮播的时间间隔，默认是2s。如果设置这个参数，之前不是自动轮播，现在就变成了自动轮播
    public var autoScrollTimeInterval: NSTimeInterval = 2 {
        didSet { isAutoCycle = true }
    }
    
    ///处理图片点击事件的代理
    weak public var delegate: XBCycleViewDelegate?
    
    //MARK: - init cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        width = frame.size.width
        height = frame.size.height
        
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    ///用于显示网络图片
    public init(frame: CGRect, imageUrlStringArray: [String]) {
        super.init(frame: frame)
        
        var modelArray = [XBCycleViewImageModel]()
        var model: XBCycleViewImageModel
        for item in imageUrlStringArray {
            model = XBCycleViewImageModel(imageUrlString: item)
            modelArray.append(model)
        }
        imageModelArray = modelArray
        
        commonInit()
    }
    
    ///用于显示本地图片
    public init(frame: CGRect, localImageArray: [UIImage]) {
        super.init(frame: frame)
        
        var modelArray = [XBCycleViewImageModel]()
        var model: XBCycleViewImageModel
        for item in localImageArray {
            model = XBCycleViewImageModel(localImage: item)
            modelArray.append(model)
        }
        imageModelArray = modelArray
        
        commonInit()
    }
    
    ///网络图片、本地图片混合显示
    public init(frame: CGRect, imageArray: [(urlString: String, localImage: UIImage)]) {
        super.init(frame: frame)
        
        var modelArray = [XBCycleViewImageModel]()
        var model: XBCycleViewImageModel
        for item in imageArray {
            model = XBCycleViewImageModel(imageUrlString: item.urlString,
                                          localImage: item.localImage)
            modelArray.append(model)
        }
        imageModelArray = modelArray
        
        commonInit()
    }
    
    ///使用图片Model数组初始化轮播器
    public init(frame: CGRect, imageModelArray: [XBCycleViewImageModel]) {
        super.init(frame: frame)
        
        self.imageModelArray = imageModelArray
        
        commonInit()
    }
    
    deinit {
        removeTimer()
        removeNotification()
        scrollView.removeGestureRecognizer(tapGesture)
    }
    
    private func commonInit() {
        width = frame.size.width
        height = frame.size.height
        
        configViews()
        addNotification()
        updateCycleView()
    }
    
    //MARK: - config views
    private func configViews() {
        addSubview(scrollView)
        scrollView.addSubview(currentImageView)
        scrollView.addSubview(nextImageView)
        addSubview(pageControl)
        
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    private func configScrollView() -> UIScrollView {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let view: UIScrollView = UIScrollView(frame: rect)
        view.contentSize = CGSize(width: width*3, height: 0)
        view.contentOffset = CGPoint(x: width, y: 0)
        view.pagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = UIColor.whiteColor()
        view.delegate = self
        
        return view;
    }
    
    private func configImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView(frame: CGRect(x: width, y: 0, width: width, height: height))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }
    
    private func configPageControl() -> UIPageControl {
        let pageControl: UIPageControl = UIPageControl()
        pageControl.currentPage = currentIndex
        pageControl.hidesForSinglePage = true
        return pageControl
    }
    
    //MARK: - set layout
    private func setPageControlLayout() {
        //pageControl
        pageControl.numberOfPages = imageModelArray.count
        pageControl.currentPage = currentIndex
        let size = pageControl.sizeForNumberOfPages(pageControl.numberOfPages)
        let point = CGPoint(x: width/2 - size.width/2, y: height - size.height)
        pageControl.frame = CGRect(origin: point, size: size)
    }
    
    //MARK: - update model array and page control
    private func updateCycleView() {
        setImageModelArray()
        setPageControlLayout()
    }
    
    
    //MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset: CGFloat = scrollView.contentOffset.x
        if offset < width {  //right
            nextImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            nextIndex = (currentIndex - 1) < 0 ? imageModelArray.count - 1 : (currentIndex - 1)
            
            if offset <= 0 {
                nextPage()
            }
        } else if offset > width { //left
            nextImageView.frame = CGRect(x: 2*width, y: 0, width: width, height: height)
            nextIndex = (currentIndex + 1) > imageModelArray.count - 1 ? 0 : (currentIndex + 1)
            
            if offset >= 2 * width {
                nextPage()
            }
        }
        
        let model = imageModelArray[nextIndex]
        if model.localImage == nil && model.imageUrlString != nil {
            downloader.getImageWithUrl(urlString: model.imageUrlString!,
                                       completeClosure: { [unowned self](image) in
                                        if self.nextIndex ==
                                            self.imageModelArray.indexOf(model) {
                                            self.nextImageView.image = image
                                        }
                })
        } else {
            //本地图片
            nextImageView.image = model.localImage
        }
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        removeTimer()
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        addTimer()
    }
    
    //MARK: - add/remove timer
    private func addTimer() {
        if isAutoCycle && imageModelArray.count > 1 {
            if timer != nil {
                removeTimer()
            }
            
            timer = NSTimer.xb_scheduledTimerWithTimeInterval(autoScrollTimeInterval,
                                                              isRepeat: true,
                                                              closure: { [unowned self] in
                                                                self.autoCycle()
                })
            NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        }
    }
    
    private func removeTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    //MARK: - add/remove notification
    private func addNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(stopTimer), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(startTimer), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    private func removeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    //MARK: - action
    private func autoCycle() {
        scrollView.setContentOffset(CGPoint(x: 2*width, y: 0), animated: true)
    }
    
    private func nextPage() {
        currentImageView.image = nextImageView.image
        scrollView.contentOffset = CGPoint(x: width, y: 0)
        currentIndex = nextIndex
        pageControl.currentPage = currentIndex
    }
    
    private func setImageModelArray() {
        for model in imageModelArray {
            if model.localImage == nil && model.imageUrlString != nil {
                downloader.getImageWithUrl(urlString: model.imageUrlString!,
                                           completeClosure: { [unowned self](image) in
                                            if self.currentIndex ==
                                                self.imageModelArray.indexOf(model) {
                                                self.currentImageView.image = image
                                            }
                    })
            } else {
                if currentIndex == imageModelArray.indexOf(model) {
                    currentImageView.image = model.localImage
                }
            }
        }
    }
    
    func tapImageView() {
        if let delegate = self.delegate {
            delegate.tapImage(self,
                              currentImage: currentImageView.image,
                              currentIndex: currentIndex)
        }
    }
    
    func stopTimer() {
        removeTimer()
    }
    
    func startTimer() {
        addTimer()
    }
    
    //MARK: - public api method
    
    ///修改PageControl的小圆点颜色值
    public func setPageControl(pageIndicatorTintColor: UIColor,
                               currentPageIndicatorTintColor: UIColor) {
        pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
    }
}

