# XBCycleView
无限循环图片轮播器，纯swift

##基本使用方法：
* 创建

<pre>
let frame = CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 180)
let cycleView: XBCycleView = XBCycleView(frame: frame, imageUrlStringArray: urls)
</pre>

* 添加到视图上

<pre>
view.addSubview(cycleView)
</pre>

<p>具体使用，参考示例工程！</p>
![image](https://github.com/xiabob/XBCycleView/blob/master/screenshots/sample.gif)
<p>修改小圆点颜色</p>
![image](https://github.com/xiabob/XBCycleView/blob/master/screenshots/sample2.PNG)
