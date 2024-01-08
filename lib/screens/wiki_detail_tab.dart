import 'package:flutter/material.dart';

class DebtsPage extends StatelessWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 8.0,
            ),
            child: Material(
              borderRadius: BorderRadius.circular(32),
              color: Theme.of(context).indicatorColor,
              child: TabBar(
                dividerColor: Colors.transparent,
                splashBorderRadius: BorderRadius.circular(32),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Theme.of(context).primaryColor,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
                labelStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                unselectedLabelStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'tab 1'),
                  Tab(text: 'tab 2'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        children: [
          Builder(
            builder: (context) {
              return _buildListView();
            },
          ),
          Builder(
            builder: (context) {
              return _buildListView();
            },
          )
        ],
      )
    );
  }
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
