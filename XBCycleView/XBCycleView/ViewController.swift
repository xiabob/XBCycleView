//
//  ViewController.swift
//  XBCycleView
//
//  Created by xiabob on 16/6/13.
//  Copyright © 2016年 xiabob. All rights reserved.
//

import UIKit

class ViewController: UIViewController, XBCycleViewDelegate {
    var imgs = [XBCycleViewImageModel]()
    var urls = ["http://hiphotos.baidu.com/praisejesus/pic/item/e8df7df89fac869eb68f316d.jpg",
                "http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg",
                "http://file27.mafengwo.net/M00/B2/12/wKgB6lO0ahWAMhL8AAV1yBFJDJw20.jpeg"]
    var locals = [UIImage(named: "img1.jpg"),UIImage(named: "img2.jpg"),UIImage(named: "img3.jpg")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let frame = CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 180)
        let cycleView: XBCycleView = XBCycleView(frame: frame, imageUrlStringArray: urls)
        //轮播间隔时间
        cycleView.autoScrollTimeInterval = 2.5
        //设置代理，监听点击图片的事件
        cycleView.delegate = self
        self.view.addSubview(cycleView)
    }
    
    //代理方法
    func tapImage(_ cycleView: XBCycleView, currentImage: UIImage?, currentIndex: Int) {
        cycleView.isAutoCycle = true
        imgs = [
            XBCycleViewImageModel(imageUrlString: "http://hiphotos.baidu.com/praisejesus/pic/item/e8df7df89fac869eb68f316d.jpg", localImage: nil),
            XBCycleViewImageModel(imageUrlString: "http://hiphotos.baidu.com/praisejesus/pic/item/e8df7df89fac869eb68f316d.jpg", localImage: UIImage(named: "img3.jpg")),
            XBCycleViewImageModel(imageUrlString: "http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg", localImage: UIImage(named: "img1.jpg")),
            XBCycleViewImageModel(imageUrlString: "http://file27.mafengwo.net/M00/B2/12/wKgB6lO0ahWAMhL8AAV1yBFJDJw20.jpeg", localImage: nil)]
        cycleView.imageModelArray = imgs
        //修改pageControl的小圆点颜色值
        cycleView.setPageControl(UIColor.gray, currentPageIndicatorTintColor: UIColor.yellow)
        
        print("cycleView:\(cycleView), currentImage:\(currentImage), currentIndex:\(currentIndex)")
    }


}

