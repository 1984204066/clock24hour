import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:clock24hour/clock.dart';

///气泡属性配置
class BobbleBean {
  Offset postion; //位置
  Color color; //颜色
  double speed; //运动的速度
  double theta; //角度
  double radius; //半径
}

///获取随机透明的白色
Color getRandonWhightColor(Random random) {
  //0~255 0为完全透明 255 为不透明
  //这里生成的透明度取值范围为 10~200
  int a = random.nextInt(190)+10;
  return Color.fromARGB(a, 255, 255, 255);
}
class BobblePage extends StatefulWidget {
  @override
  _BobblePageState createState() => _BobblePageState();
}

class _BobblePageState extends State<BobblePage>
    with TickerProviderStateMixin {
  //创建的气泡保存集合
  List<BobbleBean> _list = [];
  //随机数据
  Random _random = new Random(DateTime.now().microsecondsSinceEpoch);
  //气泡的最大半径
  double maxRadius = 100;
  //气泡动画的最大速度
  double maxSpeed = 0.7;
  //气泡计算使用的最大弧度（360度）
  double maxTheta = 2.0 * pi;
  //动画控制器
  AnimationController _animationController;
  AnimationController _fadeAnimationController;
  //流控制器
  StreamController<double> _streamController = new StreamController();

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 20; i++) {
      BobbleBean particle = new BobbleBean();
      //获取随机透明度的白色颜色
      particle.color = getRandonWhightColor(_random);
      //指定一个位置 每次绘制时还会修改
      particle.postion = Offset(-1, -1);
      //气泡运动速度
      particle.speed = _random.nextDouble() * maxSpeed;
      //随机角度
      particle.theta = _random.nextDouble() * maxTheta;
      //随机半径
      particle.radius = _random.nextDouble() * maxRadius;
      //集合保存
      _list.add(particle);
    }

    //动画控制器
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    //刷新监听
    _animationController.addListener(() {
      //流更新
      _streamController.add(0.0);
    });
    _fadeAnimationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    _fadeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //重复执行动画
        _animationController.repeat();
      }
    });
    //重复执行动画
    _fadeAnimationController.forward();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          buildBackground(), //第一部分 第一层 渐变背景
          buildBubble(context), //第二部分 第二层 气泡
          buildBlureWidget(), //第三部分 高斯模糊
          //buildTopText(), //第四部分 顶部的文字
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FadeTransition( //第五部分 Clock
                opacity: _fadeAnimationController,
                child: buildClock(context),
              ),
            ],
          )
        ]
    );
  }

  //第一部分 第一层 渐变背景
  Container buildBackground() {
    return Container(
      decoration: BoxDecoration(
        //线性渐变
        gradient: LinearGradient(
          //渐变角度
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          //渐变颜色组
          colors: [
            Colors.lightBlue.withOpacity(0.3),
            Colors.lightBlueAccent.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
          ],
        ),
      ),
    );
  }

  //第一部分 图片背景
  buildImage() {
    return Positioned.fill(
      child: Image.asset(
        "assets/welcome_bg.jpeg",
        fit: BoxFit.fill,
      ),
    );
  }

  //第二部分 第二层 气泡
  Widget buildBubble(BuildContext context) {
    //使用Stream流实现局部更新
    return StreamBuilder<double>(
      stream: _streamController.stream,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        //自定义画板
        return CustomPaint(
          //自定义画布
          painter: BubblePainter(
            list: _list,
            random: _random,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height,
          ),
        );
      },
    );


  }

  //第三部分 高斯模糊
  buildBlureWidget() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 0.3, sigmaY: 0.3),
      child: Container(
        color: Colors.white.withOpacity(0.1),
      ),
    );
  }

  //第四部分 顶部的文字
  Positioned buildTopText() {
    //顶部对齐
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Text('自强不息 & 厚德载物',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.blue,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget buildClock(BuildContext context) {
    return ClockPage();
  }
  @override
  void dispose() {
    _animationController.dispose(); //销毁
    super.dispose();
  }
}

class BubblePainter extends CustomPainter {
  Paint _paint = Paint(); //创建画笔
  List<BobbleBean> list; //保存气泡的集合
  Random random; //随机数变量

  BubblePainter({this.list, this.random});

  @override
  void paint(Canvas canvas, Size size) {
    //每次绘制都重新计算位置
    list.forEach((element) {
      //计算偏移
      var velocity = calculateXY(element.speed, element.theta);
      //新的坐标 微偏移
      var dx = element.postion.dx + velocity.dx;
      var dy = element.postion.dy + velocity.dy;
      //x轴边界计算
      if (element.postion.dx < 0 || element.postion.dx > size.width) {
        dx = random.nextDouble() * size.width;
      }
      //y轴边界计算
      if (element.postion.dy < 0 || element.postion.dy > size.height) {
        dy = random.nextDouble() * size.height;
      }
      //新的位置
      element.postion = Offset(dx, dy);

      print("dx $dx dy $dy  ${element.postion}");
    });

    //循环绘制所有的气泡
    list.forEach((element) {
      //画笔颜色
      _paint.color = element.color;
      //绘制圆
      canvas.drawCircle(element.postion, element.radius, _paint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

///计算坐标
Offset calculateXY(double speed, double theta) {
  return Offset(speed * cos(theta), speed * sin(theta));
}
