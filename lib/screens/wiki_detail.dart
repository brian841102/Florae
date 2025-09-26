import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:flutter/cupertino.dart';
import 'plugins/tap_to_expand.dart';
import 'plugins/reorder_list.dart';
import '../main.dart';
import '../data/beetle_wiki.dart';
import 'size_compare.dart';
import 'care_plan_search.dart';
import 'package:flutter/scheduler.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/weather_details_card.dart';
import 'widgets/weather_details_item.dart';
import 'widgets/sun_rise_set_item.dart';
import 'widgets/weather_row_data.dart';
import 'widgets/forecast_hour_item.dart';
import 'widgets/weather_card.dart';
import '../data/models/weather_details_model.dart';
import '../data/models/weather_model.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import '../config/translations/strings_enum.dart';


const Color darkTeal = Color.fromARGB(255, 0, 90, 48);
const Color lightTeal = Color.fromARGB(255, 244, 255, 252);

class WikiDetail extends StatefulWidget {
  const WikiDetail({super.key, required this.title, required this.index});
  final String title;
  final int index;

  @override
  State<WikiDetail> createState() => _WikiDetailState();
}

class _WikiDetailState extends State<WikiDetail> {
  late ScrollController _scrollController;
  late double titleOpacity;
  late double subTitleOpacity;
  double _offset = 0.0;
  bool _isCustomSortEnabled = false;

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
    if (!mounted) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {if (mounted) {
      setState(() {
        _offset = _scrollController.offset;
      });
    }});
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: lightTeal,
        body: NestedScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              _buildAppBar(),
              SliverToBoxAdapter(child: Container(height: 12)),
              _buildTabBar(),
            ];
          },
          body: TabBarView(
            children: [
              Container(
                color: lightTeal,
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    _buildCardRow(),
                    _buildBekuwaCard(),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    _buildSnapshotCard(),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    _buildListView(),
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    SliverToBoxAdapter(child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Text('棲息地天氣',
                          style: TextStyle(fontSize: 24, color: darkTeal.withOpacity(0.9),
                          fontWeight:FontWeight.w500, fontFamily: 'MPLUS'),
                        ),
                        Expanded(child: Divider(thickness: 2, indent: 12, color: darkTeal.withOpacity(0.3))),
                        const SizedBox(width: 25)
                      ])),
                    _buildWeatherCardView(),
                    SliverToBoxAdapter(child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Text('飼育文章', 
                          style: TextStyle(fontSize: 24, color: darkTeal.withOpacity(0.9),
                          fontWeight:FontWeight.w500, fontFamily: 'MPLUS'),
                        ),
                        Expanded(child: Divider(thickness: 2, indent: 12, color: darkTeal.withOpacity(0.3))),
                        const SizedBox(width: 25)
                      ])),
                    const SliverToBoxAdapter(child: SizedBox(height: 5)),
                    _buildCardView(),
                  ],
                ),
              ),
              Container(
                color: lightTeal,
                child: _buildTabR(),
              ),
            ],
          ),
        ),
      ),
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
            border: const Border.fromBorderSide(BorderSide(color: Colors.black12)),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 1, spreadRadius: 0),
              const BoxShadow(color: lightTeal, blurRadius: 12, spreadRadius: 5),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 5)],
            ),
            tabs: const [
              Tab(child: Text('基本資料', style: TextStyle(fontFamily: 'MPLUS'))),
              Tab(child: Text('飼育計畫', style: TextStyle(fontFamily: 'MPLUS'))),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTabR() {
    return Column(
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    readOnly: true,
                    onTap: () {
                      // 收回鍵盤
                      FocusScope.of(context).unfocus();
                      // 跳轉到全新頁面
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: true, // 背景被新頁覆蓋
                          pageBuilder: (_, __, ___) => const CarePlanSearch(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: '搜尋飼育計畫...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),

                ),
              ),
              const SizedBox(width: 12),

              // 排序按鈕
              Container(
                decoration: BoxDecoration(
                  color: darkTeal.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.sort,
                    color: Colors.white,
                  ),
                  tooltip: '切換排序',
                  onPressed: () => _showGuide(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // 下方卡片列表
        Expanded(child: _buildCardView2()),
      ],
    );
  }

  _showGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        final Color highlightColor = darkTeal.withOpacity(0.3); // 反白顏色
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4.5,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    color: Colors.grey[500],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '排序依據',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 字母排序
              Container(
                decoration: BoxDecoration(
                  color: !_isCustomSortEnabled ? highlightColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Material(
                  color: Colors.transparent, // 保留 Container 顏色
                  borderRadius: BorderRadius.circular(50),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50), // 水波紋圓角
                    splashColor: darkTeal.withOpacity(0.2),  // 水波紋顏色
                    highlightColor: Colors.transparent,      // 點擊高亮取消
                    onTap: () {
                      setState(() {
                        _isCustomSortEnabled = false;
                      });
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading: Icon(
                        Icons.sort_by_alpha,
                        color: !_isCustomSortEnabled ? darkTeal : Colors.grey,
                      ),
                      title: Text(
                        '字母排序',
                        style: TextStyle(
                          color: !_isCustomSortEnabled ? darkTeal : Colors.black87,
                          fontWeight: !_isCustomSortEnabled ? FontWeight.bold : FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 自定排序
              Container(
                decoration: BoxDecoration(
                  color: _isCustomSortEnabled ? highlightColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Material(
                  color: Colors.transparent, // 保留 Container 顏色
                  borderRadius: BorderRadius.circular(50),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50), // 水波紋圓角
                    splashColor: darkTeal.withOpacity(0.2), // 水波紋顏色
                    highlightColor: Colors.transparent,      // 點擊高亮顏色
                    onTap: () {
                      setState(() {
                        _isCustomSortEnabled = true;
                      });
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading: Icon(
                        Icons.list_alt,
                        color: _isCustomSortEnabled ? darkTeal : Colors.black45,
                      ),
                      title: Text(
                        '自定排序',
                        style: TextStyle(
                          color: _isCustomSortEnabled ? darkTeal : Colors.black87,
                          fontWeight: _isCustomSortEnabled ? FontWeight.bold : FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherCardView() {
    final weatherDetails = WeatherDetailsModel.fromJson({
      "location": {
        "name": "Taipei",
        "region": "Taipei",
        "country": "Taiwan",
        "lat": 25.03,
        "lon": 121.56,
        "tz_id": "Asia/Taipei",
        "localtime_epoch": 1695552052,
        "localtime": "2025-09-23 13:40"
      },
      "current": {
        "last_updated_epoch": 1695551400,
        "last_updated": "2025-09-23 13:30",
        "temp_c": 30.0,
        "temp_f": 86.0,
        "is_day": 1,
        "condition": {
          "text": "Sunny",
          "icon": "//cdn.weatherapi.com/weather/64x64/day/113.png",
          "code": 1000
        },
        "wind_mph": 10.5,
        "wind_kph": 16.9,
        "wind_degree": 310,
        "wind_dir": "NW",
        "pressure_mb": 1010.0,
        "pressure_in": 29.82,
        "precip_mm": 0.0,
        "precip_in": 0.0,
        "humidity": 60,
        "cloud": 0,
        "feelslike_c": 30.6,
        "feelslike_f": 87.1,
        "vis_km": 10.0,
        "vis_miles": 6.0,
        "uv": 7.0,
        "gust_mph": 12.3,
        "gust_kph": 19.8
      },
      "forecast": {
        "forecastday": [
          {
            "date": "2025-09-23",
            "date_epoch": 1695513600,
            "day": {
              "maxtemp_c": 30.9,
              "maxtemp_f": 84.1,
              "mintemp_c": 25.0,
              "mintemp_f": 77.0,
              "avgtemp_c": 27.0,
              "avgtemp_f": 80.5,
              "maxwind_mph": 10.7,
              "maxwind_kph": 17.3,
              "totalprecip_mm": 0.0,
              "totalprecip_in": 0.0,
              "totalsnow_cm": 0.0,
              "avgvis_km": 10.0,
              "avgvis_miles": 6.0,
              "avghumidity": 65.0,
              "daily_will_it_rain": 0,
              "daily_chance_of_rain": 0,
              "daily_will_it_snow": 0,
              "daily_chance_of_snow": 0,
              "condition": {
                "text": "Sunny",
                "icon": "//cdn.weatherapi.com/weather/64x64/day/113.png",
                "code": 1000
              },
              "uv": 7.0
            },
            "astro": {
                "sunrise": "06:31 AM",
                "sunset": "06:36 PM",
                "moonrise": "03:27 PM",
                "moonset": "12:20 AM",
                "moon_phase": "Waxing Gibbous",
                "moon_illumination": "63",
                "is_moon_up": 0,
                "is_sun_up": 0
            },
            "hour": [
              {
                "time_epoch": 1695502800,
                "time": "2023-09-24 00:00",
                "temp_c": 26.2,
                "temp_f": 79.1,
                "is_day": 0,
                "condition": {
                    "text": "Clear",
                    "icon": "//cdn.weatherapi.com/weather/64x64/night/113.png",
                    "code": 1000
                },
                "wind_mph": 3.4,
                "wind_kph": 5.4,
                "wind_degree": 314,
                "wind_dir": "NW",
                "pressure_mb": 1011.0,
                "pressure_in": 29.85,
                "precip_mm": 0.0,
                "precip_in": 0.0,
                "humidity": 73,
                "cloud": 0,
                "feelslike_c": 28.2,
                "feelslike_f": 82.8,
                "windchill_c": 26.2,
                "windchill_f": 79.1,
                "heatindex_c": 28.2,
                "heatindex_f": 82.8,
                "dewpoint_c": 20.9,
                "dewpoint_f": 69.6,
                "will_it_rain": 0,
                "chance_of_rain": 0,
                "will_it_snow": 0,
                "chance_of_snow": 0,
                "vis_km": 10.0,
                "vis_miles": 6.0,
                "gust_mph": 4.9,
                "gust_kph": 7.9,
                "uv": 1.0
              },
            ]
          }
        ]
      }
    });

    final Weather = WeatherModel.fromJson({
      "location": {
        "name": "登波火山",
        "region": "Taipei",
        "country": "印尼",
        "lat": 25.03,
        "lon": 121.56,
        "tz_id": "Asia/Taipei",
        "localtime_epoch": 1695552052,
        "localtime": "2025-09-23 13:40"
      },
      "current": {
        "last_updated_epoch": 1695551400,
        "last_updated": "2025-09-23 13:30",
        "temp_c": 19.0,
        "temp_f": 86.0,
        "is_day": 1,
        "condition": {
          "text": "旱季",
          "icon": "//cdn.weatherapi.com/weather/64x64/day/113.png",
          "code": 1000
        },
        "wind_mph": 10.5,
        "wind_kph": 16.9,
        "wind_degree": 310,
        "wind_dir": "NW",
        "pressure_mb": 1010.0,
        "pressure_in": 29.82,
        "precip_mm": 0.0,
        "precip_in": 0.0,
        "humidity": 60,
        "cloud": 0,
        "feelslike_c": 30.6,
        "feelslike_f": 87.1,
        "vis_km": 10.0,
        "vis_miles": 6.0,
        "uv": 7.0,
        "gust_mph": 12.3,
        "gust_kph": 19.8
      },
    });
    final forecastDay = weatherDetails.forecast.forecastday.first;
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: WeatherCard(weather: Weather),
        // child: WeatherDetailsCard(
        //   weatherDetails: weatherDetails,
        //   forecastDay: forecastDay,
        // ),
        // child: Container(
        //     padding: EdgeInsets.all(20.r),
        //     decoration: BoxDecoration(
        //       color: darkTeal.withOpacity(0.5),
        //       borderRadius: BorderRadius.only(
        //         topLeft: Radius.circular(15.r),
        //         topRight: Radius.circular(15.r),
        //         bottomRight: Radius.circular(15.r),
        //         bottomLeft: Radius.circular(15.r),
        //       ),
        //     ),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text(Strings.weatherNow, style: theme.textTheme.displaySmall),
        //         16.verticalSpace,
        //         SingleChildScrollView(
        //           scrollDirection: Axis.horizontal,
        //           child: Row(
        //             children: [
        //               WeatherDetailsItem(
        //                 title: Strings.wind,
        //                 icon: Constants.wind,
        //                 value: weatherDetails.current.windMph.toInt().toString(),
        //                 text: 'mph',
        //               ),
        //               16.horizontalSpace,
        //               WeatherDetailsItem(
        //                 title: Strings.pressure,
        //                 icon: Constants.pressure,
        //                 value: weatherDetails.current.pressureIn.toInt().toString(),
        //                 text: 'inHg',
        //                 isHalfCircle: true,
        //               ),
        //             ],
        //           ),
        //         ),
        //         20.verticalSpace,
        //         Text(Strings.hoursForecast, style: theme.textTheme.displaySmall),
        //         16.verticalSpace,
        //         SizedBox(
        //           height: 100.h,
        //           child: ListView.builder(
        //             scrollDirection: Axis.horizontal,
        //             itemCount: forecastDay.hour.length,
        //             itemBuilder: (context, index) => ForecastHourItem(
        //               hour: forecastDay.hour[index],
        //             ),
        //           ),
        //         ),
        //         16.verticalSpace,
        //         Row(
        //           mainAxisSize: MainAxisSize.min,
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Expanded(
        //               flex: 5,
        //               child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Container(
        //                     width: double.infinity,
        //                     padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
        //                     decoration: BoxDecoration(
        //                       color: theme.cardColor,
        //                       borderRadius: BorderRadius.circular(15.r),
        //                     ),
        //                     child: Row(
        //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                       children: [
        //                         Column(
        //                           crossAxisAlignment: CrossAxisAlignment.start,
        //                           children: [
        //                             Text(
        //                               weatherDetails.current.windDir.getWindDir(),
        //                               style: theme.textTheme.displayMedium?.copyWith(
        //                                 fontSize: 14.sp,
        //                               ),
        //                             ),
        //                             15.verticalSpace,
        //                             Text(
        //                               '${forecastDay.day.maxwindKph} ${Strings.kmh}',
        //                               style: theme.textTheme.displayMedium?.copyWith(
        //                                 fontSize: 14.sp,
        //                               ),
        //                             ),
        //                           ],
        //                         ),
        //                         // RotationTransition(
        //                         //   turns: AlwaysStoppedAnimation(weatherDetails.current.windDegree / 360),
        //                         //   child: Icon(Icons.north, size: 30, color: theme.iconTheme.color),
        //                         // ),
        //                       ],
        //                     ),
        //                   ),
        //                   10.verticalSpace,
        //                   Container(
        //                     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        //                     decoration: BoxDecoration(
        //                       color: theme.cardColor,
        //                       borderRadius: BorderRadius.circular(15.r),
        //                     ),
        //                     child: Column(
        //                       crossAxisAlignment: CrossAxisAlignment.start,
        //                       children: [
        //                         SunRiseSetItem(
        //                           text: Strings.sunrise,
        //                           value: forecastDay.astro.sunrise.formatTime(),
        //                         ),
        //                         5.verticalSpace,
        //                         SunRiseSetItem(
        //                           text: Strings.sunset,
        //                           value: forecastDay.astro.sunset.formatTime(),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //             10.horizontalSpace,
        //             Expanded(
        //               flex: 6,
        //               child: Container(
        //                 padding: EdgeInsets.fromLTRB(15.w, 23.h, 15.w, 23.h),
        //                 decoration: BoxDecoration(
        //                   color: theme.cardColor,
        //                   borderRadius: BorderRadius.circular(15.r),
        //                 ),
        //                 child: Column(
        //                   mainAxisSize: MainAxisSize.min,
        //                   mainAxisAlignment: MainAxisAlignment.start,
        //                   children: [
        //                     WeatherRowData(
        //                       text: Strings.humidity,
        //                       value: '${forecastDay.day.avghumidity.toInt()}%',
        //                     ),
        //                     5.verticalSpace,
        //                     WeatherRowData(
        //                       text: Strings.realFeel,
        //                       value: '${forecastDay.day.avgtempC.toInt()}°',
        //                     ),
        //                     5.verticalSpace,
        //                     WeatherRowData(
        //                       text: Strings.uv,
        //                       value: '${forecastDay.day.uv.toInt()}',
        //                     ),
        //                     5.verticalSpace,
        //                     WeatherRowData(
        //                       text: Strings.chanceOfRain,
        //                       value: '${forecastDay.day.dailyChanceOfRain}%',
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ],
        //     ),
        //   ),
      ),
    );
  }

  Widget _buildCardView2() {
    return const ReorderableExample();
  }
  Widget _buildCardView1() {
    const loremIpsum =
        "我自己的CMF在不溫控的環境下，最大紀錄差不多就是7公分左右了，要8公分以上的話大概還是要靠溫控跟更好的食材吧。然後記得，飼育幼蟲的容器大小跟他羽化後的大小絕對有正相關，想養大蟲絕對不要混養跟用直徑小於10公分的盒子。比起產卵環境，幼蟲乾濕度就不是這麼挑，一般程度就好，以免太濕造成雜蟲孳生或木屑朽化。幼蟲食量不大，假設從分出公母的L3換木屑分裝飼養的話，不論公母蟲都可以一盒500cc就可以一瓶到底 (但是公蟲會較小隻)如果公蟲丟1000cc的方盒，甚至2200cc的大桶一罐到底，通常都可以有不錯的成績";

    return ListView(
      shrinkWrap: false,
      children: [
        TapToExpand(
            color: lightTeal,
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
            title: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '飼育計劃一',
                style: TextStyle(
                  color: darkTeal,
                  fontSize: 18,
                  fontFamily: 'MPLUS',
                ),
              ),
            ),
            boxShadow: const [BoxShadow(
              color: Colors.black54,
              blurRadius: 3,
            )],
            onTapPadding: 6,
            closedPadding: 20,
            closedHeight: 60,
            scrollable: false,
            borderRadius: 15,
            openedHeight: 300,
            logo: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: darkTeal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.bug_report_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            )
        ),
        TapToExpand(
            color: lightTeal,
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
            title: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '飼育計劃二',
                style: TextStyle(
                  color: darkTeal,
                  fontSize: 18,
                  fontFamily: 'MPLUS',
                ),
              ),
            ),
            boxShadow: const [BoxShadow(
              color: Colors.black54,
              blurRadius: 3,
            )],
            onTapPadding: 6,
            closedPadding: 20,
            closedHeight: 60,
            scrollable: false,
            borderRadius: 15,
            openedHeight: 300,
            logo: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: darkTeal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.bug_report_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            )
        ),
      ],
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
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                              return 'assets/images/dif1.png';
                            case Difficulty.Medium:
                              return 'assets/images/dif2.png';
                            case Difficulty.Hard:
                              return 'assets/images/dif3.png';
                            case Difficulty.Expert:
                              return 'assets/images/dif4.png';
                            default:
                              return 'assets/images/dif5.png';
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
                          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          difficulty!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
                            fontSize: 14,
                            fontFamily: 'MPLUS',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: SizedBox(
                width: (MediaQuery.of(context).size.width - 55) / 3,
                height: 140,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Use Expanded to make the icon fill the remaining space
                      Expanded(
                        child: Image.asset(((){
                          switch (bt.popularity) {
                            case Popularity.One:
                              return 'assets/images/pop3.png';
                            case Popularity.Two:
                              return 'assets/images/pop2.png';
                            case Popularity.Three:
                              return 'assets/images/pop1.png';
                            case Popularity.Four:
                              return 'assets/images/pop4.png';
                            case Popularity.Five:
                              return 'assets/images/pop5.png';
                            default:
                              return 'assets/images/pop6.png';
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
                          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          popularity!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
                            fontSize: 14,
                            fontFamily: 'MPLUS',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: SizedBox(
                width: (MediaQuery.of(context).size.width - 55) / 3,
                height: 140,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Image.asset(((){
                          switch (bt.span) {
                            case Span.Short:
                              return 'assets/images/span1.png';
                            case Span.Medium:
                              return 'assets/images/span2.png';
                            case Span.Long:
                              return 'assets/images/span3.png';
                            default:
                              return 'assets/images/span4.png';
                          }})(),
                          width: 60,
                        ),
                        // child: Icon(
                        //   Icons.timelapse_outlined,
                        //   color: darkTeal,
                        //   size: 60,
                        // ),
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
                          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          span!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
                            fontSize: 14,
                            fontFamily: 'MPLUS',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 8,
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
                          _getFieldNamebyIndex(index)! + ' :',
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

  Widget _buildBekuwaCard() {
    BeetleWiki bt = beetleWikiBox.getAt(widget.index);
    String? popularity = popularities[bt.popularity];
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 122,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Image.asset(
                        'assets/images/bekuwa.png',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '紀錄尺寸',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 13,
                                    fontFamily: 'MPLUS',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  '紀錄者',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 13,
                                    fontFamily: 'MPLUS',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  '登錄年',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 13,
                                    fontFamily: 'MPLUS',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  '評級',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 13,
                                    fontFamily: 'MPLUS',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 72, color: darkTeal.withOpacity(0.4)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    '181 mm',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 13,
                                      fontFamily: 'MPLUS',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    '河野博士',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 13,
                                      fontFamily: 'MPLUS',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    '2023',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 13,
                                      fontFamily: 'MPLUS',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Row(
                                    children: [
                                      // const Icon(
                                      //   Icons.star,
                                      //   color: Colors.orangeAccent,
                                      //   size: 16,
                                      // ),
                                      // const SizedBox(width: 4),
                                      Text(
                                        '4.5 顆星',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontSize: 13,
                                          fontFamily: 'MPLUS',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSnapshotCard() {
    const double radius = 25;
    BeetleWiki bt = beetleWikiBox.getAt(widget.index);
    String? popularity = popularities[bt.popularity];
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
        child: SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SizeCompare(index: widget.index)),
              );
            },
            style: ElevatedButton.styleFrom(
              // splashFactory: NoSplash.splashFactory,
              backgroundColor: const Color.fromRGBO(255, 133, 161, 1.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            ),
            child: const Text(
              '使用尺規進行比較',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'MPLUS',
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
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
              "assets/images/babybottle.svg",
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
      backgroundColor: lightTeal,
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
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                                Text(bt.name, //widget.title,
                                    style: const TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 23,
                                      letterSpacing: 4,
                                      fontFamily: 'XinYi',
                                    )),
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
                            child: OutlinedButton(
                              onPressed: () {},
                              onLongPress: () {
                                Clipboard.setData(ClipboardData(text: bt.nameJP)).then((_) {
                                  var snackBar = const SnackBar(
                                    content: Text('文字已複製到剪貼簿'),
                                    duration: Duration(seconds: 3),
                                    margin: EdgeInsets.all(20),
                                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.transparent),
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: const Text(''),
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
