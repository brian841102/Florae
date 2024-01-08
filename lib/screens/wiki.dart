import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/svg.dart';
import 'package:animations/animations.dart';
import 'wiki_detail.dart';
import '../services/hive_operations.dart';
import '../locator.dart';
import '../main.dart';

const Color darkTeal = Color.fromARGB(255, 0, 90, 48);
const Color lightTeal = Color.fromARGB(255, 244, 255, 252);

class ExampleParallax extends StatelessWidget {
  const ExampleParallax({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // locations.sort((a, b) {
    //   if (a.isFavorite && !b.isFavorite) return -1;
    //   else if (!a.isFavorite && b.isFavorite) return 1;
    //   else return 0;
    // });
    locations.sort((a, b) => a.isFavorite ? 1 : 0.compareTo(b.isFavorite ? 1 : 0));
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
              locations: locations,
            ),
        ],
      ),
    );
  }
}

class LocationListItem extends StatefulWidget {
  LocationListItem({
    super.key,
    required this.imagePath,
    required this.name,
    required this.country,
    required this.context,
    required this.locations,
  });

  final String imagePath;
  final String name;
  final String country;
  final BuildContext context;
  final List<Location> locations;
  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  State<LocationListItem> createState() => _LocationListItemState();
}

class _LocationListItemState extends State<LocationListItem> {
  bool isFavorite = false;

  void _openWikiChild(BuildContext context) {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        Navigator.of(context).push(_createRoute());
      },
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => WikiChild(title: widget.name),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: AspectRatio(
        aspectRatio: 2 / 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _buildParallaxBackground(context),
              _buildGradient(),
              _buildTitleAndSubtitle(),
              const Positioned(
                right: 20,
                bottom: 20,
                child: Icon(Icons.arrow_right, color: Colors.white, size: 30),
              ),
              Material(
                color: Colors.transparent, // avoid any background color from Material
                child: InkWell(
                  onTap: () {
                    _openWikiChild(context);
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.black.withOpacity(0.2),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: IconButton(
                  onPressed: () {
                    setState(() {isFavorite = !isFavorite;});
                    final location = widget.locations.firstWhere((loc) => loc.name == widget.name);
                    if (location != null) {location.isFavorite = isFavorite;}
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ),
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
        backgroundImageKey: widget._backgroundImageKey,
      ),
      children: [
        Image.asset(
          widget.imagePath,
          key: widget._backgroundImageKey,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.5, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Positioned(
      left: 20,
      bottom: 18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.country,
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
  Location({
    required this.name,
    required this.place,
    required this.imagePath,
    required this.realName,
    required this.birth,
    this.isFavorite = false,
  });

  final String name;
  final String place;
  final String imagePath;
  final String realName;
  final String birth;
  bool isFavorite;
}

var locations = [
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

// class OptionsModel {
//   OptionsModel._();

//   static List<BeetleWiki> options() {
//     var _favModelList = <BeetleWiki>[];

//     final _optionRoutes = OptionAndRoutes.optionRoutes;
//     final _linkRoutes = OptionAndRoutes.linksRoutes;
//     final _favModel = BeetleWiki.fromJson(jsonDecode(json));

//     for (var _optionRoute in _optionRoutes.entries) {
//       //final _favModel = BeetleWiki();

//       _favModel.articleID = _optionRoute.value;
//       _favModel.articleName = _optionRoute.key;
//       _favModel.articleRoute = _optionRoute.value;
//       _favModel.articleLinks = _linkRoutes[_optionRoute.key];
//       _favModel.isFavorite = false;

//       _favModelList.add(_favModel);
//     }
//     return _favModelList;
//   }
// }

class WikiChild extends StatefulWidget {
  const WikiChild({super.key, required this.title});
  final String title;

  @override
  State<WikiChild> createState() => _WikiChildState();
}

class _WikiChildState extends State<WikiChild> {
  late ScrollController _scrollController;
  late double titleOpacity;
  late double radius;
  double _offset = 0.0;
  //late Box beetleWikiBox;

  static final _hiveService = locator<HiveOperationService>();

  late Image image1, image2, image3, image4, image5, image6, image7, image8, image9, image10,
             image11, image12, image13, image14, image15, image16, image17, image18;


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_setOffset);
    //beetleWikiBox = Hive.box(beetleWikiBoxName);
    //WidgetsBinding.instance.addPostFrameCallback((_) async {await loadJsonDataToHive();});
    image1  = Image.asset("assets/images/indicator.png");
    image2  = Image.asset("assets/images/barcode.png");
    image3  = Image.asset("assets/images/starry4.png");
    image4  = Image.asset("assets/images/span1.png");
    image5  = Image.asset("assets/images/span2.png");
    image6  = Image.asset("assets/images/span3.png");
    image7  = Image.asset("assets/images/span4.png");
    image8  = Image.asset("assets/images/dif1.png");
    image9  = Image.asset("assets/images/dif2.png");
    image10 = Image.asset("assets/images/dif3.png");
    image11 = Image.asset("assets/images/dif4.png");
    image12 = Image.asset("assets/images/dif5.png");
    image13 = Image.asset("assets/images/pop1.png");
    image14 = Image.asset("assets/images/pop2.png");
    image15 = Image.asset("assets/images/pop3.png");
    image16 = Image.asset("assets/images/pop4.png");
    image17 = Image.asset("assets/images/pop5.png");
    image18 = Image.asset("assets/images/pop6.png");
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

  String _shortenName(String input) {
    List<String> words = input.split(RegExp(r'\s+'));
    if (words.length > 2) {
      String firstWord = words[0];
      String secondWord = words[1];
      String thirdWordInit = words[2][0];
      String result = firstWord + ' ' + secondWord + ' ' + thirdWordInit + '.';
      return result;
    } else {
      return input;
    }
  }

  void _openWikiDetail(BuildContext context, int i) {
    precacheImage(image1.image, context);
    precacheImage(image2.image, context);
    precacheImage(image3.image, context);
    precacheImage(image4.image, context);
    precacheImage(image5.image, context);
    precacheImage(image6.image, context);
    precacheImage(image7.image, context);
    precacheImage(image8.image, context);
    precacheImage(image9.image, context);
    precacheImage(image10.image, context);
    precacheImage(image11.image, context);
    precacheImage(image12.image, context);
    precacheImage(image13.image, context);
    precacheImage(image14.image, context);
    precacheImage(image15.image, context);
    precacheImage(image16.image, context);
    precacheImage(image17.image, context);
    precacheImage(image18.image, context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WikiDetail(title: '美他利佛細身赤鍬形蟲', index: i)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Location location = locations.firstWhere((loc) => loc.name == widget.title,
        orElse: () => Location(name:'',place:'',imagePath:'', realName:'',birth:''));
    //final _nav = Navigator.of(context);
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
            _buildGridView2(),
            // ValueListenableBuilder(
            //   builder: (_, Box<BeetleWiki> model, child) => _buildGridView2(
            //     children: _displayOptions(_nav),
            //   ),
            //   valueListenable: _hiveService.favBox.listenable(),
            // ),
          ],
        ),
      ),
    );
  }
  // List<Widget> _displayOptions(NavigatorState nav) {
  //   var _list = <Widget>[];
  //   var _count = OptionsModel.options().length;
  //   var _favBox = _OptionHomeState._hiveService.favBox;

  //   if (_favBox.isNotEmpty) {
  //     var _favCount = _favBox.length;

  //     for (var i = 0; i < _count; i++) {
  //       final _model = OptionsModel.options()[i];
  //       var _insertion = false;

  //       // FOR FAV CHECK
  //       for (var j = 0; j < _favCount; j++) {
  //         if (_model.articleID == _favBox.values.toList()[j].articleID) {
  //           _list.add(_addToList(nav, true, _model));
  //           _insertion = true;
  //           break;
  //         }
  //       }

  //       if (!_insertion) {
  //         _list.add(_addToList(nav, false, _model));
  //       }
  //     }
  //   } else {
  //     for (var i = 0; i < _count; i++) {
  //       final _model = OptionsModel.options()[i];
  //       _list.add(_addToList(nav, false, _model));
  //     }
  //   }

  //   return _list;
  // }
  
  // Widget _addToList(NavigatorState nav, bool value, BeetleWiki _model) =>
  //     ParallaxButton(
  //       isFavorite: value,
  //       medium: _model.articleLinks.first,
  //       model: _model,
  //       text: _model.articleName,
  //       website: _model.articleLinks[1],
  //       youtubeLink: _model.articleLinks.last,
  //     ).clickable(() => nav.pushNamed(_model.articleRoute));

  Widget _buildGridView2() {
    const double boxHeight = 6.0;
    const double title1Height = 15.0;
    const double title2Height = 12.2;
    const double horizontalEdge = 16.0;
    const double horizontalEdgeMid = 12.0;
    double containerHeight =
        (MediaQuery.of(context).size.width - horizontalEdge * 2 - horizontalEdgeMid) / 2;
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
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int i) {
              return Stack(
                children: [
                  InkWell(
                    onTap: () {
                      _openWikiDetail(context, i);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: containerHeight, // Adjust the height of the box
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            image: DecorationImage(
                              image: AssetImage(beetleWikiBox.getAt(i).imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: boxHeight), // Space between the grid box and titles
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 8, right: 10), // Add indentation to titles
                          child: Text(
                            beetleWikiBox.getAt(i).name,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              color: darkTeal,
                              fontSize: title1Height,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'MPLUS',
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 9, right: 10), // Add indentation to titles
                          child: Text(
                            _shortenName(beetleWikiBox.getAt(i).nameSci),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 110, 157, 134),
                              fontSize: title2Height,
                              fontWeight: FontWeight.w300,
                              //fontFamily: 'MPLUS',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ContainerTransition(
                    closedBuilder: (_, _open) {
                      return InkWell(
                        onTap: () {
                          _open();
                        },
                        child: Container(
                          height: containerHeight, // Adjust the height of the box
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            image: DecorationImage(
                              image: AssetImage(beetleWikiBox.getAt(i).imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                    closedShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    index: i,
                  ),
                ],
              );
            },
            childCount: beetleWikiBox.length,
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    const double boxHeight = 6.0;
    const double title1Height = 15.0;
    const double title2Height = 12.0;
    const double horizontalEdge = 16.0;
    const double horizontalEdgeMid = 12.0;
    double containerHeight = (MediaQuery.of(context).size.width-horizontalEdge*2-horizontalEdgeMid)/2;
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
          delegate: SliverChildBuilderDelegate((BuildContext context, int i) {
              return InkWell(
                onTap: () {
                  _openWikiDetail(context, i);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: containerHeight, // Adjust the height of the box
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        image: DecorationImage(
                          image: AssetImage('assets/images/cmf.png'),
                          fit: BoxFit.cover,
                        ),
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
                          color: Color.fromARGB(255, 110, 157, 134),
                          fontSize: title2Height,
                          fontWeight: FontWeight.w300,
                          //fontFamily: 'MPLUS',
                          fontStyle: FontStyle.italic,
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
    titleOpacity = _calculateOpacity(60,160);
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
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end, // Align the title at the bottom left
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
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(right: 20, bottom: 9),
            child: TextButton(
              onPressed: () {
                _launchMaps(birth);
              },
              style: TextButton.styleFrom(shape: const CircleBorder()),
              child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/map.png'),
                  )
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: lightTeal.withOpacity(titleOpacity),
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

  Widget _buildCardBorder() {
    const cardHeight = 80.0;
    titleOpacity = _calculateOpacity(60,200);
    radius = 30 * (1 - titleOpacity);
    return SliverWidget(
      child: Stack(
        children: [
          Container(
            height: cardHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, lightTeal],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: cardHeight,
            decoration: BoxDecoration(
                color: lightTeal,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius))),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    lightTeal.withOpacity(titleOpacity*0.9), // Set your desired opacity and color
                    BlendMode.srcATop,
                  ),
                  child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                      child:  Transform.translate(
                        offset: Offset(titleOpacity*(-6), 3),
                        child: SvgPicture.asset("assets/images/beetle-deco.svg", height: 30))
                  ),
                ),
                const SizedBox(width: 15),
                Transform.scale(
                  alignment: Alignment.center,
                  scaleX: 1-titleOpacity*0.1,
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: darkTeal.withOpacity(1-titleOpacity*0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    lightTeal.withOpacity(titleOpacity*0.9), // Set your desired opacity and color
                    BlendMode.srcATop,
                  ),
                  child: Transform.translate(
                      offset: Offset(titleOpacity*(-6), 3),
                      child: SvgPicture.asset("assets/images/beetle-deco.svg", height: 30)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SliverWidget extends StatelessWidget {
  const SliverWidget({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: child,);
  }
}

class ContainerTransition extends StatelessWidget {
  const ContainerTransition({super.key,
    required this.closedBuilder,
    required this.closedShape,
    required this.index,
  });

  final CloseContainerBuilder closedBuilder;
  final ShapeBorder closedShape ;
  final int index;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      tappable: false,
      //transitionDuration: const Duration(milliseconds: 400),
      transitionType:  ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return WikiDetail(title: '美他利佛細身赤鍬形蟲', index: index);
      },
      openColor: Colors.transparent,
      closedColor:Colors.transparent,
      closedShape: closedShape,
      closedBuilder: closedBuilder,
    );
  }
}
