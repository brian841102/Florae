import 'dart:math' as math;
import 'package:flutter/material.dart';

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.topRight,
        clipBehavior: Clip.none,
        children: [
          _buildDimmingOverlay(),
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildDimmingOverlay() {
    return IgnorePointer(
      ignoring: !_open,
      child: AnimatedOpacity(
          opacity: _open ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            color: Colors.black.withOpacity(0.3), // Adjust the opacity as needed
          )),
    );
  }

  Widget _buildTapToCloseFab() {
    return Positioned(
      right: 20,
      top: 60,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Material(
            color: Theme.of(context).colorScheme.secondary,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            elevation: 3,
            child: InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0; i < count; i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          index: i,
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return Positioned(
      right: 20,
      top: 60,
      child: IgnorePointer(
        ignoring: _open,
        child: AnimatedContainer(
          transformAlignment: Alignment.center,
          // transform: Matrix4.diagonal3Values(
          //   _open ? 0.7 : 1.0,
          //   _open ? 0.7 : 1.0,
          //   1.0,
          // ),
          duration: const Duration(milliseconds: 250),
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          child: AnimatedOpacity(
            opacity: _open ? 0.0 : 1.0,
            curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
            duration: const Duration(milliseconds: 250),
            child: FloatingActionButton.small(
              shape: _open
                  ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))
                  : RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              elevation: 3,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: _toggle,
              child: const Icon(Icons.more_vert),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.index,
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final int index;
  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: progress,
//       builder: (context, child) {
//         final offset = Offset.fromDirection(
//           directionInDegrees * (math.pi / 180.0),
//           progress.value * maxDistance,
//         );
//         return Positioned(
//           right: 24 + offset.dx,
//           top: 64 + offset.dy,
//           child: Transform.rotate(
//             angle: (1.0 - progress.value) * math.pi / 2,
//             child: child!,
//           ),
//         );
//       },
//       child: FadeTransition(
//         opacity: progress,
//         child: child,
//       ),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          90 * (math.pi / 180.0),
          index * maxDistance,
        );
        return Positioned(
          right: 24,
          top: 64 + offset.dy - index * maxDistance,
          child: Transform.translate(
            offset: Offset(0, progress.value * maxDistance * (index+1)),
            child: child,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    this.text,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget? text;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 120,
          height: 40,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: text ?? const Text(""),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            color: theme.colorScheme.surfaceTint,
            elevation: 3,
            child: IconButton(
              onPressed: onPressed,
              icon: icon,
              iconSize: 20,
              color: theme.colorScheme.onSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
