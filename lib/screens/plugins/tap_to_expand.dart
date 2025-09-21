import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color darkTeal = Color.fromARGB(255, 0, 90, 48);
const Color lightTeal = Color.fromARGB(255, 244, 255, 252);

class TapToExpand extends StatefulWidget {
  /// A parameter that is used to show the content of the widget.
  final Widget content;

  /// A parameter that is used to show the title of the widget.
  final Widget? logo;
  final Widget title;

  /// A parameter that is used to show the trailing widget.
  final Widget? trailing;

  /// A parameter that is used to set the color of the widget.
  final Color? color;

  /// Used to set the color of the shadow.
  final List<BoxShadow>? boxShadow;

  /// Used to make the widget scrollable.
  final bool? scrollable;

  /// Used to give the widget Inkwell.
  final bool? useInkWell; 

  /// Used to set the height of the widget when it is closed.
  final double? closedHeight;

  /// Used to set the height of the widget when it is opened.
  final double? openedHeight;

  /// Used to set the duration of the animation.
  final Duration? duration;

  /// Used to set the padding of the widget when it is opened.
  final double? onTapPadding;

  /// Used to set the padding of the widget when it is closed.
  final double? closedPadding;

  /// Used to set the border radius of the widget.
  final double? borderRadius;

  /// Used to set the physics of the scrollable widget.
  final ScrollPhysics? scrollPhysics;

  /// 展開狀態回調
  final ValueChanged<bool>? onExpansionChanged;

  /// 外部控制展開狀態
  final bool? isExpanded;

  const TapToExpand({
    super.key,
    required this.content,
    required this.title,
    this.logo,
    this.color,
    this.scrollable,
    this.useInkWell,
    this.closedHeight,
    this.openedHeight,
    this.boxShadow,
    this.duration,
    this.onTapPadding,
    this.closedPadding,
    this.borderRadius,
    this.scrollPhysics,
    this.trailing,
    this.onExpansionChanged,
    this.isExpanded,
  });
  @override
  State<TapToExpand> createState() => _TapToExpandState();
}

class _TapToExpandState extends State<TapToExpand> {
  late bool _internalExpanded;
  //double contentHeight = 0; TODO: make contentHeight dynamic adjust openedHeight

  @override
  void initState() {
    super.initState();
    _internalExpanded = widget.isExpanded ?? true;
  }

  bool get isExpanded => widget.isExpanded ?? _internalExpanded;

  void _toggleExpand() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (widget.isExpanded == null) { // 使用內部狀態
        _internalExpanded = !_internalExpanded;
        widget.onExpansionChanged?.call(_internalExpanded);
      } else {                         // 外部控制，僅呼叫回調
        widget.onExpansionChanged?.call(!widget.isExpanded!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool scrollable = widget.scrollable ?? false;
    double closedHeight = widget.closedHeight ?? 70;

    /// Used to make the widget clickable.
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: _toggleExpand,
      child: AnimatedContainer(
        margin: EdgeInsets.symmetric(
          /// Used to set the padding of the widget when it is closed.
          horizontal: isExpanded ?  widget.closedPadding ?? 30 : widget.onTapPadding ?? 10,
          vertical: 6,
        ),
        padding: EdgeInsets.symmetric(vertical: (closedHeight-34-6)/2, horizontal: 18),
        //alignment: isExpanded ? Alignment.bottomLeft : AlignmentDirectional.bottomEnd,
        curve: Curves.fastLinearToSlowEaseIn,
        duration: widget.duration ?? const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          /// Used to set the default value of the boxShadow parameter.
          boxShadow: widget.boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
          color: widget.color ?? Colors.white,//Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(
            Radius.circular(isExpanded ? widget.borderRadius ?? 10 : 30),
          ),
        ),
        child: scrollable
            ? ListView(
                physics: widget.scrollPhysics,
                shrinkWrap: true,
                padding: const EdgeInsets.all(0.0),
                children: [
                  /// Creating a row with two widgets. The first widget is the title widget and the
                  /// second widget is the trailing widget. If the trailing widget is null, then it will
                  /// show an arrow icon.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// A parameter that is used to show the title of the widget.
                      widget.title,

                      /// Checking if the trailing widget is null or not. If it is null, then it will
                      /// show an arrow icon.
                      widget.trailing ??
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: darkTeal,
                            size: 27,
                          ),
                    ],
                  ),

                  /// Used to add some space between the title and the content.
                  isExpanded ? const SizedBox() : const SizedBox(height: 20),

                  /// Used to show the content of the widget.
                  AnimatedCrossFade(
                    firstChild: const Text(
                      '',
                      style: TextStyle(
                        fontSize: 0,
                      ),
                    ),

                    /// Showing the content of the widget.
                    secondChild: widget.content,
                    crossFadeState: isExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration:
                        widget.duration ?? const Duration(milliseconds: 1000),
                    reverseDuration: Duration.zero,
                    sizeCurve: Curves.fastLinearToSlowEaseIn,
                  ),
                ],
              )
            : ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(0.0),
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Creating a row with two widgets. The first widget is the title widget and the
                      /// second widget is the trailing widget. If the trailing widget is null, then it will
                      /// show an arrow icon.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widget.logo ?? const Icon(Icons.info_outline, color: darkTeal, size: 20),
                          const SizedBox(width: 5),
                          widget.title,
                          const Spacer(),
                          if (widget.useInkWell ?? true) // 根據 useInkWell 決定是否顯示箭頭
                            InkWell(
                              onTap: () {
                                _toggleExpand();
                              },
                              customBorder: const CircleBorder(),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: darkTeal.withOpacity(0.15),
                                child: isExpanded
                                    ? const Icon(Icons.keyboard_arrow_down, color: darkTeal, size: 27)
                                    : const Icon(Icons.keyboard_arrow_up, color: darkTeal, size: 27),
                              ),
                            ),
                        ],
                      ),

                      /// Used to add some space between the title and the content.
                      isExpanded ? const SizedBox() : const SizedBox(height: 15),

                      /// Used to show the content of the widget.
                      AnimatedCrossFade(
                        firstChild: const Text(
                          '',
                          style: TextStyle(
                            fontSize: 0,
                          ),
                        ),
                        secondChild: widget.content,
                        crossFadeState: isExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        secondCurve: Curves.easeInCubic,

                        /// Used to set the duration of the animation.
                        duration:
                            widget.duration ?? const Duration(milliseconds:1000),
                        reverseDuration: Duration.zero,

                        /// Used to set the curve of the animation.
                        sizeCurve: Curves.fastLinearToSlowEaseIn,
                        alignment: AlignmentDirectional.bottomCenter,
                      ),
                      isExpanded ? const SizedBox(height: 0) : const SizedBox(height: 5),
                    ],
                ),
              ],
              ),
      ),
    );
  }
}
