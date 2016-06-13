# XBCycleView
无限循环图片轮播器，纯swift

##基本使用方法：
* 创建

<code>let frame = CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 180)<p></p>
let cycleView: XBCycleView = XBCycleView(frame: frame, imageUrlStringArray: urls)</code>
* 添加到视图上

<code>view.addSubview(cycleView)</code>

<p>具体使用，参考示例工程！</p>
![image](https://github.com/xiabob/XBCycleView/blob/master/screenshots/sample.gif)
