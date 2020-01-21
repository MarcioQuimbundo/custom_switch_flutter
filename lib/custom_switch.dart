library custom_switch;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const CustomSwitch({Key key, this.value, this.onChanged, this.activeColor})
      : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  Animation _circleAnimation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 60));
    _circleAnimation = AlignmentTween(
            begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.value ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            widget.value == false
                ? widget.onChanged(true)
                : widget.onChanged(false);
          },
          child: InnerShadow(
            color: Color(0xFF4D70A6).withOpacity(.2),
            offset: Offset(5, 5),
            blur: 2,
            child: Container(
              width: 70.0,
              height: 35.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: _circleAnimation.value == Alignment.centerLeft
                      ? Colors.transparent
                      : widget.activeColor),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 4.0, right: 4.0, left: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _circleAnimation.value == Alignment.centerRight
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 4.0, right: 4.0),
                            child: Text(
                              '    ',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.0),
                            ),
                          )
                        : Container(),
                    Align(
                      alignment: _circleAnimation.value,
                      child: Container(
                        width: 35.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(width: 1, color: Colors.grey[300]),
                            color: Colors.transparent),
                      ),
                    ),
                    _circleAnimation.value == Alignment.centerLeft
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 4.0, right: 5.0),
                            child: Text(
                              '   ',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.0),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class InnerShadow extends SingleChildRenderObjectWidget {
  const InnerShadow({
    Key key,
    this.color,
    this.blur,
    this.offset,
    Widget child,
  }) : super(key: key, child: child);

  final Color color;
  final double blur;
  final Offset offset;

  @override
  RenderInnerShadow createRenderObject(BuildContext context) {
    return RenderInnerShadow()
      ..color = color
      ..blur = blur
      ..offset = offset;
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderInnerShadow renderObject) {
    renderObject
      ..color = color
      ..blur = blur
      ..offset = offset;
  }
}

class RenderInnerShadow extends RenderProxyBox {
  RenderInnerShadow({
    RenderBox child,
  }) : super(child);

  @override
  bool get alwaysNeedsCompositing => child != null;

  Color _color;
  double _blur;
  Offset _offset;

  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  double get blur => _blur;
  set blur(double value) {
    if (_blur == value) return;
    _blur = value;
    markNeedsPaint();
  }

  Offset get offset => _offset;
  set offset(Offset value) {
    if (_offset == value) return;
    _offset = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      var layerPaint = Paint()..color = Colors.white;

      var canvas = context.canvas;
      canvas.saveLayer(offset & size, layerPaint);
      context.paintChild(child, offset);
      var shadowPaint = Paint()
        ..blendMode = ui.BlendMode.srcATop
        ..imageFilter = ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur)
        ..colorFilter = ui.ColorFilter.mode(color, ui.BlendMode.srcIn);
      canvas.saveLayer(offset & size, shadowPaint);

      // Invert the alpha to compute inner part.
      var invertPaint = Paint()
        ..colorFilter = const ui.ColorFilter.matrix([
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          -1,
          255,
        ]);
      canvas.saveLayer(offset & size, invertPaint);
      canvas.translate(_offset.dx, _offset.dy);
      context.paintChild(child, offset);
      context.canvas.restore();
      context.canvas.restore();
      context.canvas.restore();
    }
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (child != null) visitor(child);
  }
}
