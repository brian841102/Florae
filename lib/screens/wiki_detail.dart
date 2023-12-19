import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'plugins/tap_to_expand.dart';
import 'package:hive/hive.dart';
import '../main.dart';
import '../data/beetle_wiki.dart';

const Color darkTeal = Color.fromARGB(255, 0, 90, 48);
const Color lightTeal = Color.fromARGB(255, 244, 255, 252);

class WikiDetail extends StatefulWidget {
  const WikiDetail({Key? key, required this.title, required this.index}) : super(key: key);
  final String title;
  final int index;

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
    beetleWikiBox = Hive.box(beetleWikiBoxName);
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

  // ## No TabBar Version ##
  // @override
  // Widget build(BuildContext context) {
  //   String imagePath = Beetle.getImagePathByName(widget.title);
  //   return Scaffold(
  //     body: Container(
  //       color: lightTeal, // Set the background color here
  //       child: CustomScrollView(
  //         shrinkWrap: true,
  //         //cacheExtent: 500,
  //         controller: _scrollController,
  //         physics: const ClampingScrollPhysics(), //const BouncingScrollPhysics(),
  //         slivers: [
  //           _buildAppBar(imagePath),
  //           SliverToBoxAdapter(child: Container(height: 12)),
  //           _buildCardRow(),
  //           SliverToBoxAdapter(child: Container(height: 24)),
  //           _buildListView(),
  //           SliverToBoxAdapter(child: Container(height: 20)),
  //           _buildCardView(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Container(
          color: lightTeal, // Set the background color here
          child: CustomScrollView(
            shrinkWrap: true,
            //cacheExtent: 500,
            controller: _scrollController,
            physics: const ClampingScrollPhysics(), //const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: Container(height: 12)),
              _buildTabBar(),
              SliverToBoxAdapter(child: Container(height: 20)),
              _buildCardRow(),
              SliverToBoxAdapter(child: Container(height: 16)),
              _buildListView(),
              SliverToBoxAdapter(child: Container(height: 20)),
              _buildCardView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabL() {
    return ListView(
      shrinkWrap: true,
      children: [
        _buildCardRow(),
        //_buildCardView1(),
        //_buildCardView(),
      ],
    );
  }

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: darkTeal.withOpacity(0.2),
            border: Border.fromBorderSide(BorderSide(color: Colors.black12)),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 1, spreadRadius: 0),
              BoxShadow(color: lightTeal, blurRadius: 12, spreadRadius: 5),
            ],
          ),
          child: TabBar(
            padding: const EdgeInsets.all(2),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 0,
            indicatorColor: Colors.transparent,
            dividerColor: Colors.transparent,
            labelColor: lightTeal, //darkTeal,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            //unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: darkTeal.withOpacity(0.9), //Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 5)
              ],
            ),
            tabs: const [
              Tab(child: Text('基本資料', style: TextStyle(fontFamily: 'MPLUS'))),
              Tab(child: Text('飼育計畫(建構中)', style: TextStyle(fontFamily: 'MPLUS'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardRow() {
    BeetleWiki bt = beetleWikiBox.getAt(widget.index);
    String? difficulty = diffuculties[bt.difficulty];
    String? popularity = popularities[bt.popularity];
    String? span = spans[bt.span];
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Card(
              child: SizedBox(
                width: (MediaQuery.of(context).size.width - 55) / 3,
                height: 140,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Use Expanded to make the icon fill the remaining space
                      Expanded(
                        child: Image.asset(((){
                          switch (bt.difficulty) {
                            case Difficulty.Easy:
                              return 'assets/images/level1.png';
                            case Difficulty.Medium:
                              return 'assets/images/level2.png';
                            case Difficulty.Hard:
                              return 'assets/images/level3.png';
                            case Difficulty.Expert:
                              return 'assets/images/level4.png';
                            default:
                              return 'assets/images/level0.png';
                          }})(),
                        ),
                        // child: Icon(
                        //   Icons.bar_chart_outlined,
                        //   color: darkTeal,
                        //   size: 64,
                        // ),
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
                          difficulty!,
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
                width: (MediaQuery.of(context).size.width - 55) / 3,
                height: 140,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Use Expanded to make the icon fill the remaining space
                      Expanded(
                        child: Image.asset(((){
                          switch (bt.popularity) {
                            case Popularity.One:
                              return 'assets/images/pop1.png';
                            case Popularity.Two:
                              return 'assets/images/pop1.png';
                            case Popularity.Three:
                              return 'assets/images/pop1.png';
                            case Popularity.Four:
                              return 'assets/images/pop1.png';
                            case Popularity.Five:
                              return 'assets/images/pop1.png';
                            default:
                              return 'assets/images/pop1.png';
                          }})(),
                        ),
                        // child: Icon(
                        //   Icons.local_fire_department_outlined,
                        //   color: darkTeal,
                        //   size: 62,
                        // ),
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
                          popularity!,
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
                width: (MediaQuery.of(context).size.width - 55) / 3,
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
                          span!,
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
    BeetleWiki bt = beetleWikiBox.getAt(widget.index);
    String? _getFieldByIndex(int index) {
      List<String?> fields = [bt.boxSize, bt.larvaTemp, bt.larvaTime, bt.hiberTime, bt.adultTime,
                              bt.adultSize, bt.birth];
      return fields[index];
    }
    String? _getFieldNamebyIndex(int index) {
      List<String?> names = ['建議容器', '適合溫度', '幼蟲期', '蟄伏期', '成蟲壽命',
                             '成蟲大小', '產地'];
      return names[index];
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          bool isOdd = index % 2 == 1;
          return Container(
            decoration: BoxDecoration(
              color: isOdd
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
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
                          _getFieldNamebyIndex(index)!+ ' :',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontFamily: 'MPLUS',
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _getFieldByIndex(index)!,
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

  Widget _buildCardView1() {
    const loremIpsum =
        "我自己的CMF在不溫控的環境下，最大紀錄差不多就是7公分左右了，要8公分以上的話大概還是要靠溫控跟更好的食材吧。然後記得，飼育幼蟲的容器大小跟他羽化後的大小絕對有正相關，想養大蟲絕對不要混養跟用直徑小於10公分的盒子。比起產卵環境，幼蟲乾濕度就不是這麼挑，一般程度就好，以免太濕造成雜蟲孳生或木屑朽化。幼蟲食量不大，假設從分出公母的L3換木屑分裝飼養的話，不論公母蟲都可以一盒500cc就可以一瓶到底 (但是公蟲會較小隻)如果公蟲丟1000cc的方盒，甚至2200cc的大桶一罐到底，通常都可以有不錯的成績";

    return ListView(
      shrinkWrap: true,
      children: [
        TapToExpand(
          content: const Column(
            children: <Widget>[
              Text(
                loremIpsum,
                style: TextStyle(
                  color: darkTeal,
                  fontSize: 16,
                  height: 1.7,
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
          logo: SvgPicture.asset(
            "assets/images/pediatrics_FILL0_wght400_GRAD0_opsz48.svg",
            height: 36,
            color: darkTeal,
          ),
        ),
        TapToExpand(
          content: const Column(
            children: <Widget>[
              Text(
                loremIpsum,
                style: TextStyle(
                  color: darkTeal,
                  fontSize: 16,
                  height: 1.7,
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
          logo: SvgPicture.asset(
            "assets/images/pediatrics_FILL0_wght400_GRAD0_opsz48.svg",
            height: 36,
            color: darkTeal,
          ),
        ),
      ],
    );
  }

  Widget _buildCardView() {
    const loremIpsum =
        "我自己的CMF在不溫控的環境下，最大紀錄差不多就是7公分左右了，要8公分以上的話大概還是要靠溫控跟更好的食材吧。然後記得，飼育幼蟲的容器大小跟他羽化後的大小絕對有正相關，想養大蟲絕對不要混養跟用直徑小於10公分的盒子。比起產卵環境，幼蟲乾濕度就不是這麼挑，一般程度就好，以免太濕造成雜蟲孳生或木屑朽化。幼蟲食量不大，假設從分出公母的L3換木屑分裝飼養的話，不論公母蟲都可以一盒500cc就可以一瓶到底 (但是公蟲會較小隻)如果公蟲丟1000cc的方盒，甚至2200cc的大桶一罐到底，通常都可以有不錯的成績";

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return TapToExpand(
            content: const Column(
              children: <Widget>[
                Text(
                  loremIpsum,
                  style: TextStyle(
                    color: darkTeal,
                    fontSize: 16,
                    height: 1.7,
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
            logo: SvgPicture.asset(
              "assets/images/pediatrics_FILL0_wght400_GRAD0_opsz48.svg",
              height: 36,
              color: darkTeal,
            ),
          );
        },
        childCount: 10,
      ),
    );
  }

  Widget _buildAppBar() {
    titleOpacity = _calculateOpacity(100, 270);
    ColorTween colorTween = ColorTween(begin: Colors.white, end: darkTeal);
    Color? backButtonColor = colorTween.lerp(titleOpacity);
    BeetleWiki bt = beetleWikiBox.getAt(widget.index);
    return SliverAppBar(
      automaticallyImplyLeading: false,
      elevation: 0.0,
      pinned: true,
      snap: false,
      foregroundColor: backButtonColor, // back button color
      backgroundColor: Colors.transparent,
      floating: false,
      expandedHeight: MediaQuery.of(context).size.width * 1.2, //450
      stretch: true,
      flexibleSpace: Stack(
        fit: StackFit.passthrough,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width * 1.1,
            child: ClipPath(
              clipper: HalfCircleClipper(),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.darken),
                child: Image.asset(
                  bt.imagePath,
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
          const FlexibleSpaceBar(
            expandedTitleScale: 1,
            stretchModes: [],
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
                child: Text(bt.name),
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

  Widget beetleCard() {
    BeetleWiki bt = beetleWikiBox.getAt(widget.index);
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
                height: MediaQuery.of(context).size.width / 3.2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              alignment: AlignmentDirectional.topCenter,
                              children: [
                                Text(
                                  bt.name,
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
                                Text(
                                  bt.name,//widget.title,
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 23,
                                    letterSpacing: 4,
                                    fontFamily: 'XinYi',
                                  )
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 28,
                              child: Text(
                                bt.nameSci,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: const TextStyle(
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
                              child: Text(
                                bt.nameJP,
                                style: const TextStyle(
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
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height: 28,
                            width: 222,
                            child:OutlinedButton(
                              onPressed: (){},
                              onLongPress: () {
                                Clipboard.setData(ClipboardData(text: bt.nameJP)).then((_) {
                                   var snackBar = SnackBar(
                                      content: Text(
                                        '文字已複製至剪貼簿',
                                        style: TextStyle(
                                          color: Colors.greenAccent.withOpacity(0.6),
                                          //fontFamily: 'MPLUS',
                                        ),
                                      ),
                                      duration: const Duration(seconds: 2),
                                      margin: const EdgeInsets.all(20),
                                      behavior: SnackBarBehavior.floating,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                });
                              },
                              child: const Text(''),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.transparent),
                                splashFactory: NoSplash.splashFactory,
                              ),
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
    path.lineTo(0, h * 0.8); // bottom-left corner 2.point

    // Define the control points for the quadratic Bezier curve
    final controlPoint = Offset(w / 2, h * 0.98); // bottom-mid 3.point
    final endPoint = Offset(w, h * 0.8); //bottom-right corner 4.point

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