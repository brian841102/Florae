import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'wiki_detail.dart';

const Color darkTeal = Color.fromARGB(255, 0, 90, 48);
const Color lightTeal = Color.fromARGB(255, 244, 255, 252);

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
    final listItemOffset = listItemBox.localToGlobal(listItemBox.size.centerLeft(Offset.zero),
        ancestor: scrollableBox);

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(0.0, scrollFraction * 1.7 - 1);
    // Decide scroll speed of image

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox).size;
    final listItemSize = context.size;
    final childRect = verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(
      0,
      transform: Transform.translate(offset: Offset(0.0, childRect.top)).transform,
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
  void updateRenderObject(BuildContext context, covariant RenderParallax renderObject) {
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
    final backgroundImageConstraints = BoxConstraints.tightFor(width: size.width);
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
    final backgroundOffset = localToGlobal(size.centerLeft(Offset.zero), ancestor: scrollableBox);

    // Determine the percent position of this list item within the
    // scrollable area.
    final scrollFraction = (backgroundOffset.dy / viewportDimension).clamp(0.0, 1.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final background = child!;
    final backgroundSize = background.size;
    final listItemSize = size;
    final childRect = verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(background,
        (background.parentData as ParallaxParentData).offset + offset + Offset(0.0, childRect.top));
  }
}

class Location {
  const Location({
    required this.name,
    required this.place,
    required this.imagePath,
    required this.realName,
    required this.birth,
  });

  final String name;
  final String place;
  final String imagePath;
  final String realName;
  final String birth;
}

const locations = [
  Location(
    name: 'Cyclommatus',
    place: '細身屬',
    imagePath: 'assets/images/cyclommatus.png',
    realName: '雞冠細身赤鍬形蟲',
    birth: '新北三峽',
  ),
  Location(
    name: 'Dorcus',
    place: '大鍬屬',
    imagePath: 'assets/images/dorcus.png',
    realName: '台灣大鍬',
    birth: '新竹尖石',
  ),
  Location(
    name: 'Lucanus',
    place: '深山屬',
    imagePath: 'assets/images/lucanus.png',
    realName: '台灣深山鍬形蟲',
    birth: '苗栗加里山',
  ),
  Location(
    name: 'Neolucanus',
    place: '圓翅屬',
    imagePath: 'assets/images/neolucanus.png',
    realName: '紅圓翅鍬形蟲',
    birth: '桃園東眼山',
  ),
  Location(
    name: 'Odontolabis',
    place: '艷鍬屬',
    imagePath: 'assets/images/odontolabis.png',
    realName: '鬼艷鍬形蟲',
    birth: '台中觀霧',
  ),
  Location(
    name: 'Prosopocoilus',
    place: '鋸鍬屬',
    imagePath: 'assets/images/prosopocoilus.png',
    realName: '兩點赤鋸鍬形蟲',
    birth: '高雄藤枝',
  ),
  Location(
    name: 'Rhaetulus',
    place: '鹿角屬',
    imagePath: 'assets/images/rhaetulus.png',
    realName: '鹿角鍬形蟲',
    birth: '台東啞口',

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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_setOffset);
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

  double _calculateOpacity(double zeroOpacityOffset, double fullOpacityOffset) {
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

  void _openWikiDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WikiDetail(title: 'name')),
    );
  }

  @override
  Widget build(BuildContext context) {
    Location location = locations.firstWhere((loc) => loc.name == widget.title,
        orElse: () => const Location(name:'',place:'',imagePath:'', realName:'',birth:''));
    return Scaffold(
      body: Container(
        color: lightTeal, // Set the background color here
        child: CustomScrollView(
          //cacheExtent: 500,
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          //physics: ClampingScrollPhysics(),
          slivers: [
            _buildAppBar(location.imagePath,location.realName,location.birth),
            _buildCardBorder(),
            _buildGridView(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    const double boxHeight = 6.0;
    const double title1Height = 15.0;
    const double title2Height = 12.0;
    //const double containerHeight = 185.0;
    const double horizontalEdge = 16.0;
    const double horizontalEdgeMid = 12.0;
    double containerHeight = MediaQuery.of(context).size.width/2-horizontalEdge-horizontalEdgeMid;
    double totalBoxHeight = boxHeight + title1Height + title2Height + containerHeight;
    
    return SliverPadding(
      padding: const EdgeInsets.only(top: 0.0),
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalEdge),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: horizontalEdgeMid,
            mainAxisSpacing: 0,
            childAspectRatio: (((MediaQuery.of(context).size.width) / 2) / totalBoxHeight) / 1.25,
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  _openWikiDetail(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: containerHeight, // Adjust the height of the box
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(index.toString()),
                        // child: const Image(
                        //   image: //TODO
                        // ),
                      ),
                    ),
                    const SizedBox(height: boxHeight), // Space between the grid box and titles
                    const Padding(
                      padding: EdgeInsets.only(left: 8, right: 10), // Add indentation to titles
                      child: Text(
                        '美他利佛細身赤鍬形蟲',
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                          color: darkTeal,
                          fontSize: title1Height,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'MPLUS',
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 9, right: 10), // Add indentation to titles
                      child: Text(
                        'Cyclommatus metallifer f.',
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: title2Height,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'MPLUS',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: 20,
          ),
        ),
      ),
    );
  }

  void _launchMaps(String keyword) async {
  // String googleUrl =
  //   'comgooglemaps://?center=${trip.origLocationObj.lat},${trip.origLocationObj.lon}';
  Uri googleUrl =
      Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(keyword)}');
  // String appleUrl =
  //   'https://maps.apple.com/?sll=${trip.origLocationObj.lat},${trip.origLocationObj.lon}';
  Uri appleUrl =
      Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(keyword)}');
  if (await canLaunchUrl(googleUrl)) {
    print('launching google url');
    await launchUrl(googleUrl);
  } else if (await canLaunchUrl(appleUrl)) {
    print('launching apple url');
    await launchUrl(appleUrl);
  } else {
    throw 'Could not launch url';
  }
}

  Widget _buildAppBar(String imagePath, String realName, String birth) {
    titleOpacity = _calculateOpacity(0,160);
    ColorTween colorTween = ColorTween(begin: Colors.white, end: darkTeal);
    Color? backButtonColor = colorTween.lerp(titleOpacity);
    return SliverAppBar(
      elevation: 0.0,
      pinned: true,
      snap: false,
      foregroundColor: backButtonColor, // back button color
      backgroundColor: Colors.transparent,
      floating: false,
      expandedHeight: 240.0,
      stretch: true,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.6, 0.95],
              ),
            ),
          ),
          FlexibleSpaceBar(
            expandedTitleScale: 1,
            stretchModes: const [],
            titlePadding: const EdgeInsets.only(left: 40, bottom: 16),
            title: Container(
              alignment: Alignment.bottomLeft, // Align the title at the bottom left
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(realName,
                      style: const TextStyle(
                        fontSize: 25,
                        letterSpacing: 4,
                        fontFamily: 'MPLUS',
                        fontWeight: FontWeight.normal,
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Text(birth,
                        style: const TextStyle(
                          fontSize: 15,
                          letterSpacing: 2,
                          fontFamily: 'MPLUS',
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(right: 20, bottom: 9),
            child: TextButton(
              onPressed: () {
                _launchMaps(birth);
              },
              child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/map.png'),
                  )
              ),
              style: TextButton.styleFrom(shape: const CircleBorder()),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: lightTeal.withOpacity(titleOpacity),
              //backgroundColor: Colors.white.withOpacity(titleOpacity),
              elevation: 0.0,
              title: Opacity(
                opacity: titleOpacity,
                child: Text(widget.title),
              ),
              titleTextStyle: const TextStyle(
                color: darkTeal,
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

Widget _buildCardBorder() {
  return SliverWidget(
    child: Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black,
          ),
        ),
        Container(
          width: double.infinity,
          height: 50,
          decoration: const BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        ),
      ],
    ),
  );
}


class SliverWidget extends StatelessWidget {
  const SliverWidget({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: child,);
  }
}
