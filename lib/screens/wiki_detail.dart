import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
        orElse: () => Location(name: '', place: '', imagePath: '', realName: '', birth: ''));
    String imagePath = Beetle.getImagePathByName(widget.title);
    return Scaffold(
      body: Container(
        color: lightTeal, // Set the background color here
        child: CustomScrollView(
          shrinkWrap: true,
          //cacheExtent: 500,
          controller: _scrollController,
          physics: const ClampingScrollPhysics(), //const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(imagePath),
            SliverToBoxAdapter(child: Container(height: 12)),
            _buildCardRow(),
            SliverToBoxAdapter(child: Container(height: 24)),
            _buildListView(),
            SliverToBoxAdapter(child: Container(height: 20)),
            _buildCardView(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardRow() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Card(
              child: SizedBox(
                width: (MediaQuery.of(context).size.width-55) / 3,
                height: 140,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Use Expanded to make the icon fill the remaining space
                      const Expanded(
                        child: Icon(
                          Icons.bar_chart_outlined,
                          color: darkTeal,
                          size: 64,
                        ),
                      ),
                      SizedBox(
                        height: 28,
                        child: Text(
                          '飼育難度',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontFamily: 'MPLUS',
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '容易',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
                            fontSize: 14,
                            fontFamily: 'MPLUS',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            Card(
              child: SizedBox(
                width:(MediaQuery.of(context).size.width-55) / 3,
                height: 140,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Use Expanded to make the icon fill the remaining space
                      const Expanded(
                        child: Icon(
                          Icons.local_fire_department_outlined,
                          color: darkTeal,
                          size: 62,
                        ),
                      ),
                      SizedBox(
                        height: 28,
                        child: Text(
                          '熱門程度',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontFamily: 'MPLUS',
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '高',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
                            fontSize: 14,
                            fontFamily: 'MPLUS',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            Card(
              child: SizedBox(
                width: (MediaQuery.of(context).size.width-55) / 3,
                height: 140,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Icon(
                          Icons.timelapse_outlined,
                          color: darkTeal,
                          size: 60,
                        ),
                      ),
                      SizedBox(
                        height: 28,
                        child: Text(
                          '飼育週期',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontFamily: 'MPLUS',
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '短',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
                            fontSize: 14,
                            fontFamily: 'MPLUS',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
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
            margin: const EdgeInsets.symmetric(horizontal: 18.0),
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
                      fontSize: 16,
                      height:1.7,
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
            onTapPadding: 14,
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

  Widget _buildAppBar(String imagePath) {
    titleOpacity = _calculateOpacity(100, 270);
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
      expandedHeight: MediaQuery.of(context).size.width*1.2,//450
      stretch: true,
      flexibleSpace: Stack(
        fit: StackFit.passthrough,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width*1.1,
            child: ClipPath(
              clipper: HalfCircleClipper(),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Stack(
                children: [
                  beetleCard(),
                  Positioned(
                    height: 12,
                    bottom: 4,
                    left: 60,
                    child: Image.asset(
                      'assets/images/indicator.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FlexibleSpaceBar(
            expandedTitleScale: 1,
            stretchModes: [],
            titlePadding: EdgeInsets.symmetric(horizontal: 12),
            title: Container(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //beetleCard(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              leading: IconButton(
                icon: Icon(Icons.close, color: backButtonColor), // Use the "close" icon here
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

  Widget beetleCard (){
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                width: 24,
                top: 10,
                child: Image.asset(
                  'assets/images/barcode.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              Positioned(
                right: 0,
                width: 24,
                top: 10,
                child: Image.asset(
                  'assets/images/barcode.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              Positioned.fill(
                right: 24,
                left: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black, // background color
                    border: Border.all(width: 6),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Image.asset(
                    'assets/images/starry4.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width/3.2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12,bottom: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          alignment: AlignmentDirectional.topCenter,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 23,
                                letterSpacing: 4,
                                fontFamily: 'XinYi',
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 3
                                  ..color = Colors.black,
                              ),
                            ),
                            Text(widget.title,
                                style: const TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 23,
                                  letterSpacing: 4,
                                  fontFamily: 'XinYi',
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 28,
                          child: Text(
                            'Cyclommatus metallifer finae',
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                              //color: Theme.of(context).colorScheme.secondary,
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 220, //double.infinity,
                          decoration: BoxDecoration(
                            //color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                            color: darkTeal,
                            border: Border.all(width: 2),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                            ),
                          ),
                          padding: const EdgeInsets.all(4.0),
                          child: const Text(
                            'メタリヘルホソアカクワガタ',
                            style: TextStyle(
                              //color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'MPLUS',
                              //fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5, // soften the shadow
            //spreadRadius: 1.0, //extend the shadow
            offset: const Offset(0, 5),
          )
        ],
      ),
    );
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    final path = Path();
    // (0, 0) top-left corner 1.point
    path.lineTo(0, h*0.8); // bottom-left corner 2.point

    // Define the control points for the quadratic Bezier curve
    final controlPoint = Offset(w / 2, h*0.98); // bottom-mid 3.point
    final endPoint = Offset(w, h*0.8); //bottom-right corner 4.point

    // Add the quadratic Bezier curve
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    path.lineTo(w, 0); // top-right corner 5.point
    path.close(); // Close the path to create a full shape

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}


enum Beetle {
  cmf(
    boxSize: '1200 cc',
    hiberTime: '2~3個月',
    larvaTime: '6~10個月',
    larvaTemp: '22°C',
    adultTime: '6~10個月',
    adultSize: '36~100mm',
    birth: '印尼‧珀倫島',
    name:'美他利佛細身赤鍬形蟲',
    imagePath: 'assets/images/cmf.png',
  ),
  pgk(
    boxSize: '1200 cc',
    hiberTime: '2~3個月',
    larvaTime: '6~10個月',
    larvaTemp: '22°C',
    adultTime: '6~10個月',
    adultSize: '36~100mm',
    birth: '印尼‧龍目島',
    name:'長頸鹿鋸鍬形蟲',
    imagePath: 'assets/images/prosopocoilus.png',
  );

  const Beetle({
    required this.boxSize,
    required this.hiberTime,
    required this.larvaTime,
    required this.larvaTemp,
    required this.adultTime,
    required this.adultSize,
    required this.birth,
    required this.name,
    required this.imagePath,
  });

  final String boxSize;
  final String hiberTime;
  final String larvaTime;
  final String larvaTemp;
  final String adultTime;
  final String adultSize;
  final String birth;
  final String name;
  final String imagePath;

  String getPropertyByIndex(int index) {
    switch (this) {
      case Beetle.cmf:
        switch (index) {
          case 0:
            return boxSize;
          case 1:
            return hiberTime;
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
            return boxSize;
          case 1:
            return hiberTime;
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
        return '建議容器';
      case 1:
        return '蟄伏期';
      case 2:
        return '幼蟲期';
      case 3:
        return '適合溫度';
      case 4:
        return '成蟲壽命';
      case 5:
        return '成蟲大小';
      case 6:
        return '產地';
      default:
        throw ArgumentError("Invalid property index");
    }
  }

  static String getImagePathByName(String name) {
    for (var beetle in Beetle.values) {
      if (beetle.name == name) {
        return beetle.imagePath;
      }
    }
    throw ArgumentError("No Beetle found with the provided name");
  }

}

