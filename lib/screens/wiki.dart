import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

class ExampleParallax extends StatelessWidget {
  const ExampleParallax({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          for (final location in locations)
            LocationListItem(
              imagePath: location.imagePath,
              name: location.name,
              country: location.place,
              context: context,
            ),
        ],
      ),
    );
  }
}

class LocationListItem extends StatelessWidget {
  LocationListItem({
    super.key,
    required this.imagePath,
    required this.name,
    required this.country,
    required this.context,
  });

  final String imagePath;
  final String name;
  final String country;
  final BuildContext context;
  final GlobalKey _backgroundImageKey = GlobalKey();

  void _openWikiChild(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WikiChild(title: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: AspectRatio(
        aspectRatio: 2 / 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _buildParallaxBackground(context),
              _buildGradient(),
              _buildTitleAndSubtitle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
      ),
      children: [
        Image.asset(
          imagePath,
          key: _backgroundImageKey,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent, // avoid any background color from Material
        child: InkWell(
          onTap: () {
            _openWikiChild(context);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.black.withOpacity(0.2), // Customize the splash color
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.6, 0.95],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Positioned(
      left: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            country,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);


  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      width: constraints.maxWidth,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Calculate the position of this list item within the viewport.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
        listItemBox.size.centerLeft(Offset.zero),
        ancestor: scrollableBox);

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction =
    (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(0.0, scrollFraction * 1.7 - 1);
    // Decide scroll speed of image

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect =
    verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(
      0,
      transform:
      Transform.translate(offset: Offset(0.0, childRect.top)).transform,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

class Parallax extends SingleChildRenderObjectWidget {
  const Parallax({
    super.key,
    required Widget background,
  }) : super(child: background);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParallax(scrollable: Scrollable.of(context));
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderParallax renderObject) {
    renderObject.scrollable = Scrollable.of(context);
  }
}

class ParallaxParentData extends ContainerBoxParentData<RenderBox> {}

class RenderParallax extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin {
  RenderParallax({
    required ScrollableState scrollable,
  }) : _scrollable = scrollable;

  ScrollableState _scrollable;

  ScrollableState get scrollable => _scrollable;

  set scrollable(ScrollableState value) {
    if (value != _scrollable) {
      if (attached) {
        _scrollable.position.removeListener(markNeedsLayout);
      }
      _scrollable = value;
      if (attached) {
        _scrollable.position.addListener(markNeedsLayout);
      }
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _scrollable.position.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _scrollable.position.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ParallaxParentData) {
      child.parentData = ParallaxParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    // Force the background to take up all available width
    // and then scale its height based on the image's aspect ratio.
    final background = child!;
    final backgroundImageConstraints =
    BoxConstraints.tightFor(width: size.width);
    background.layout(backgroundImageConstraints, parentUsesSize: true);

    // Set the background's local offset, which is zero.
    (background.parentData as ParallaxParentData).offset = Offset.zero;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Get the size of the scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;

    // Calculate the global position of this list item.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final backgroundOffset =
    localToGlobal(size.centerLeft(Offset.zero), ancestor: scrollableBox);

    // Determine the percent position of this list item within the
    // scrollable area.
    final scrollFraction =
    (backgroundOffset.dy / viewportDimension).clamp(0.0, 1.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final background = child!;
    final backgroundSize = background.size;
    final listItemSize = size;
    final childRect =
    verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(
        background,
        (background.parentData as ParallaxParentData).offset +
            offset +
            Offset(0.0, childRect.top));
  }
}

class Location {
  const Location({
    required this.name,
    required this.place,
    required this.imagePath,
  });

  final String name;
  final String place;
  final String imagePath;
}

const locations = [
  Location(
    name: 'Cyclommatus',
    place: '細身屬',
    imagePath: 'assets/cyclommatus.png',
  ),
  Location(
    name: 'Dorcus',
    place: '大鍬屬',
    imagePath: 'assets/dorcus.png',
  ),
  Location(
    name: 'Lucanus',
    place: '深山屬',
    imagePath: 'assets/lucanus.png',
  ),
  Location(
    name: 'Neolucanus',
    place: '圓翅屬',
    imagePath: 'assets/neolucanus.png',
  ),
  Location(
    name: 'Odontolabis',
    place: '艷鍬屬',
    imagePath: 'assets/odontolabis.png',
  ),
  Location(
    name: 'Prosopocoilus',
    place: '鋸鍬屬',
    imagePath: 'assets/prosopocoilus.png',
  ),
  Location(
    name: 'Rhaetulus',
    place: '鹿角屬',
    imagePath: 'assets/rhaetulus.png',
  ),
];

class WikiChild extends StatefulWidget {
  const WikiChild({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _WikiChildState createState() => _WikiChildState();
}

class _WikiChildState extends State<WikiChild> {
  late ScrollController _scrollController;
  late double titleOpacity;
  double _offset = 0.0;
  final double zeroOpacityOffset = 0;
  final double fullOpacityOffset = 100;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_setOffset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_setOffset);
    _scrollController.dispose();
    super.dispose();
  }

  void _setOffset() {
    setState(() {
      _offset = _scrollController.offset;
    });
  }

  double _calculateOpacity() {
    if (fullOpacityOffset == zeroOpacityOffset) return 1;
    else if (fullOpacityOffset > zeroOpacityOffset) {
      // fading in
      if (_offset <= zeroOpacityOffset) return 0;
      else if (_offset >= fullOpacityOffset) return 1;
      else return (_offset - zeroOpacityOffset) / (fullOpacityOffset - zeroOpacityOffset);
    } else {
      // fading out
      if (_offset <= fullOpacityOffset) return 1;
      else if (_offset >= zeroOpacityOffset) return 0;
      else return (_offset - fullOpacityOffset) / (zeroOpacityOffset - fullOpacityOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    Location location = locations.firstWhere(
            (loc) => loc.name == widget.title,
            orElse: () => const Location(name: '', place: '', imagePath: ''));
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(location.imagePath),
          _buildGridView(),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150.0,
      ),

      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return Container(
            alignment: Alignment.center,
            child: Text(index.toString()),
          );
        },
        childCount: 27,
      ),
    );
  }

  Widget _buildAppBar(String imagePath) {
    titleOpacity = _calculateOpacity();
    return SliverAppBar(
      pinned: true,
      snap: true,
      backgroundColor: Colors.teal,
      floating: true,
      expandedHeight: 240.0,
      stretch: true,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.teal.withOpacity(titleOpacity),
              elevation: titleOpacity == 1 ? 2.0 : 0.0,
              title: Opacity(
                opacity: titleOpacity,
                child: Text(widget.title),
              ),
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'NotoSans',
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}