import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'plugins/tap_to_expand.dart';
import 'wiki.dart';

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
            _buildListView(),
            SliverToBoxAdapter(child: Container(height: 24)),
            _buildCardView(),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          bool isOdd = index % 2 == 1;
          return Container(
            decoration: BoxDecoration(
              color: isOdd ? Colors.transparent : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          Beetle.cmf.getPropertyNameByIndex(index)+' :',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontFamily: 'MPLUS',
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          Beetle.cmf.getPropertyByIndex(index),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontFamily: 'MPLUS',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        childCount: 7,
      ),
    );
  }


  Widget _buildCardView() {
    const loremIpsum =
        "我自己的CMF在不溫控的環境下，最大紀錄差不多就是7公分左右了，要8公分以上的話大概還是要靠溫控跟更好的食材吧。然後記得，飼育幼蟲的容器大小跟他羽化後的大小絕對有正相關，想養大蟲絕對不要混養跟用直徑小於10公分的盒子。比起產卵環境，幼蟲乾濕度就不是這麼挑，一般程度就好，以免太濕造成雜蟲孳生或木屑朽化。幼蟲食量不大，假設從分出公母的L3換木屑分裝飼養的話，不論公母蟲都可以一盒500cc就可以一瓶到底 (但是公蟲會較小隻)如果公蟲丟1000cc的方盒，甚至2200cc的大桶一罐到底，通常都可以有不錯的成績";

    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return TapToExpand(
            content: const Column(
              children: <Widget>[
                  Text(
                    loremIpsum,
                    style: TextStyle(
                      color: darkTeal,
                      fontSize: 15,
                      fontFamily: 'MPLUS',
                    ),
                  ),
              ],
            ),
            title: const Text(
              'Larva Care',
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

enum Beetle {
  cmf(
    difficulty: 2,
    popularity: 4,
    larvaTime: '6~10',
    larvaTemp: '22°C',
    adultTime: '6~10',
    adultSize: '36~100',
    birth: 'Taiwan, Japan, India, America, Canada',
  ),
  pgk(
    difficulty: 2,
    popularity: 4,
    larvaTime: '6~10',
    larvaTemp: '22°C',
    adultTime: '6~10',
    adultSize: '36~100',
    birth: 'Taiwan, Japan, India, America, Canada',
  );

  const Beetle({
    required this.difficulty,
    required this.popularity,
    required this.larvaTime,
    required this.larvaTemp,
    required this.adultTime,
    required this.adultSize,
    required this.birth,
  });

  final int difficulty;
  final int popularity;
  final String larvaTime;
  final String larvaTemp;
  final String adultTime;
  final String adultSize;
  final String birth;

  String getPropertyByIndex(int index) {
    switch (this) {
      case Beetle.cmf:
        switch (index) {
          case 0:
            return difficulty.toString();
          case 1:
            return popularity.toString();
          case 2:
            return larvaTime;
          case 3:
            return larvaTemp;
          case 4:
            return adultTime;
          case 5:
            return adultSize;
          case 6:
            return birth;
          default:
            throw ArgumentError("Invalid property index for cmf");
        }
      case Beetle.pgk:
        switch (index) {
          case 0:
            return difficulty.toString();
          case 1:
            return popularity.toString();
          case 2:
            return larvaTime;
          case 3:
            return larvaTemp;
          case 4:
            return adultTime;
          case 5:
            return adultSize;
          case 6:
            return birth;
          default:
            throw ArgumentError("Invalid property index for pgk");
        }
      default:
        throw ArgumentError("Invalid enum value");
    }
  }
  String getPropertyNameByIndex(int index) {
    switch (index) {
      case 0:
        return 'Difficulty';
      case 1:
        return 'Popularity';
      case 2:
        return 'LarvaTime';
      case 3:
        return 'LarvaTemp';
      case 4:
        return 'AdultTime';
      case 5:
        return 'AdultSize';
      case 6:
        return 'Birth';
      default:
        throw ArgumentError("Invalid property index");
    }
  }
}

