import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'plugins/tap_to_expand.dart';
import 'plugins/expandable_card.dart';

const Color darkTeal = Color.fromARGB(255, 0, 90, 48);
const Color lightTeal = Color.fromARGB(255, 244, 255, 252);

class WikiDetail extends StatefulWidget {
  const WikiDetail({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _WikiDetailState createState() => _WikiDetailState();
}

class _WikiDetailState extends State<WikiDetail> {
  late ScrollController _scrollController;
  late double titleOpacity;
  late double subTitleOpacity;
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

  @override
  Widget build(BuildContext context) {
    Location location = locations.firstWhere((loc) => loc.name == widget.title,
        orElse: () => const Location(name: '', place: '', imagePath: '', realName: '', birth: ''));
    return Scaffold(
      body: Container(
        color: lightTeal, // Set the background color here
        child: CustomScrollView(
          shrinkWrap: true,
          //cacheExtent: 500,
          controller: _scrollController,
          physics: const ClampingScrollPhysics(), //const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(location.imagePath, location.realName, location.birth),
            _buildCardBorder(),
            _buildCardView(),
          ],
        ),
      ),
    );
  }


  Widget _buildCardView() {
    const double boxHeight = 6.0;
    const double title1Height = 15.0;
    const double title2Height = 12.0;
    const double horizontalEdge = 16.0;
    const double horizontalEdgeMid = 12.0;
    const loremIpsum =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

    double containerHeight = MediaQuery.of(context).size.width / 2 - horizontalEdge - horizontalEdgeMid;
    double totalBoxHeight = boxHeight + title1Height + title2Height + containerHeight;

    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return TapToExpand(
            content: const Column(
              children: <Widget>[
                  Text(
                    loremIpsum,
                    style: TextStyle(
                      color: darkTeal,
                      fontSize: 16,
                      fontFamily: 'MPLUS',
                    ),
                  ),
              ],
            ),
            title: const Text(
              '幼蟲照護',
              style: TextStyle(
                color: darkTeal,
                fontSize: 20,
                fontFamily: 'MPLUS',
              ),
            ),
            onTapPadding: 16,
            closedHeight: 80,
            scrollable: false,
            borderRadius: 20,
            openedHeight: 300,
            logo: SvgPicture.asset("assets/images/pediatrics_FILL0_wght400_GRAD0_opsz48.svg",
              height: 36,
              color: darkTeal,
            ),
          );
        },
        childCount: 10,
      ),
    );
  }
  
  // Widget _buildCardView() {
  //   const double boxHeight = 6.0;
  //   const double title1Height = 15.0;
  //   const double title2Height = 12.0;
  //   //const double containerHeight = 185.0;
  //   const double horizontalEdge = 16.0;
  //   const double horizontalEdgeMid = 12.0;
  //   double containerHeight =
  //       MediaQuery.of(context).size.width / 2 - horizontalEdge - horizontalEdgeMid;
  //   double totalBoxHeight = boxHeight + title1Height + title2Height + containerHeight;
  //
  //   return SliverPadding(
  //     padding: const EdgeInsets.only(top: 0.0),
  //     sliver: SliverPadding(
  //       padding: const EdgeInsets.symmetric(horizontal: horizontalEdge),
  //       sliver: SliverGrid(
  //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisCount: 2,
  //           crossAxisSpacing: horizontalEdgeMid,
  //           mainAxisSpacing: 0,
  //           childAspectRatio: (((MediaQuery.of(context).size.width) / 2) / totalBoxHeight) / 1.25,
  //         ),
  //         delegate: SliverChildBuilderDelegate(
  //           (BuildContext context, int index) {
  //             return InkWell(
  //               onTap: () {},
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Container(
  //                     height: containerHeight, // Adjust the height of the box
  //                     decoration: const BoxDecoration(
  //                       color: Colors.black12,
  //                       borderRadius: BorderRadius.all(Radius.circular(16)),
  //                     ),
  //                     child: Container(
  //                       alignment: Alignment.center,
  //                       child: Text(index.toString()),
  //                       // child: const Image(
  //                       //   image: //TODO
  //                       // ),
  //                     ),
  //                   ),
  //                   const SizedBox(height: boxHeight), // Space between the grid box and titles
  //                   const Padding(
  //                     padding: EdgeInsets.only(left: 8, right: 10), // Add indentation to titles
  //                     child: Text(
  //                       '美他利佛細身赤鍬形蟲',
  //                       overflow: TextOverflow.fade,
  //                       softWrap: false,
  //                       style: TextStyle(
  //                         color: darkTeal,
  //                         fontSize: title1Height,
  //                         fontWeight: FontWeight.w600,
  //                         fontFamily: 'MPLUS',
  //                       ),
  //                     ),
  //                   ),
  //                   const Padding(
  //                     padding: EdgeInsets.only(left: 9, right: 10), // Add indentation to titles
  //                     child: Text(
  //                       'Cyclommatus metallifer f.',
  //                       overflow: TextOverflow.fade,
  //                       softWrap: false,
  //                       style: TextStyle(
  //                         color: Colors.grey,
  //                         fontSize: title2Height,
  //                         fontWeight: FontWeight.w600,
  //                         fontFamily: 'MPLUS',
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //           childCount: 20,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _launchMaps(String keyword) async {
    // String googleUrl =
    //   'comgooglemaps://?center=${trip.origLocationObj.lat},${trip.origLocationObj.lon}';
    Uri googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$keyword');
    // String appleUrl =
    //   'https://maps.apple.com/?sll=${trip.origLocationObj.lat},${trip.origLocationObj.lon}';
    Uri appleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$keyword');
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
    titleOpacity = _calculateOpacity(0, 160);
    ColorTween colorTween = ColorTween(begin: Colors.white, end: darkTeal);
    Color? backButtonColor = colorTween.lerp(titleOpacity);
    return SliverAppBar(
      automaticallyImplyLeading: false,
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
            child: const FlutterLogo(size: 10),
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
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Text(birth,
                          style: const TextStyle(
                            fontSize: 15,
                            letterSpacing: 2,
                            fontFamily: 'MPLUS',
                          )),
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
                  )),
              style: TextButton.styleFrom(shape: const CircleBorder()),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close), // Use the "close" icon here
                onPressed: () {
                  Navigator.pop(context); // Go back when the "X" button is pressed
                },
              ),
              backgroundColor: lightTeal.withOpacity(titleOpacity),
              surfaceTintColor: Colors.transparent,
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
            decoration: const BoxDecoration(
                color: lightTeal,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          ),
        ],
      ),
    );
  }
}

class SliverWidget extends StatelessWidget {
  const SliverWidget({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: child,
    );
  }
}

// class WikiDetail extends StatelessWidget {
//   const WikiDetail({
//     super.key,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: ExampleSliverScrollView(),
//       ),
//     );
//   }
// }
//
// class ExampleSliverScrollView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         SliverAppBar(
//           expandedHeight: 200,
//           flexibleSpace: FlexibleSpaceBar(
//             title: Text('SliverScrollView Example'),
//             background: Image.network(
//               'https://via.placeholder.com/400x200',
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         SliverList(
//           delegate: SliverChildBuilderDelegate(
//             (BuildContext context, int index) {
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: CardItem(),
//               );
//             },
//             childCount: 10,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class CardItem extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       child: Column(
//         children: [
//           ListTile(
//             title: Text('Card Title'),
//             subtitle: Text('Subtitle'),
//           ),
//           Divider(),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: 5,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text('Item $index'),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

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
