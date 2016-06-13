# XBCycleView
无限循环图片轮播器，纯swift

#基本使用方法：
1、let frame = CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 180) 
 
   let cycleView: XBCycleView = XBCycleView(frame: frame, imageUrlStringArray: urls)

2、view.addSubview(cycleView)
