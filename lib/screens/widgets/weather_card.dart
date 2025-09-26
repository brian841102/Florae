import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/extensions.dart';
import '../../config/translations/strings_enum.dart';
import '../plugins/custom_cached_image.dart';
import '../../data/models/weather_model.dart';
// import '../../../../routes/app_pages.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 18.h),
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15.r),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primary,
          Colors.black54,
        ],
      ),
    ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    weather.location.country.toRightCountry(),
                    style: TextStyle(
                        fontWeight: FontWeight.normal, fontFamily: GoogleFonts.pottaOne().fontFamily,
                        color: Colors.white, fontSize: 20.w
                      ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(', ', style: TextStyle(
                      fontWeight: FontWeight.normal, fontFamily: GoogleFonts.pottaOne().fontFamily,
                      color: Colors.white, fontSize: 20.w
                  )),
                  Text(
                      weather.location.name.toRightCity(),
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontFamily: GoogleFonts.pottaOne().fontFamily,
                          color: Colors.white, fontSize: 20.w
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              // 10.verticalSpace,
              // Text(
              //   weather.location.name.toRightCity(),
              //   style: TextStyle(
              //       fontWeight: FontWeight.normal, fontFamily: GoogleFonts.gamjaFlower().fontFamily,
              //       color: Colors.white, fontSize: 20.sp
              //   ),
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              // ),
              5.verticalSpace,
              Text(
                weather.current.condition.text,
                style: TextStyle(
                    fontWeight: FontWeight.normal, fontFamily: GoogleFonts.kiwiMaru().fontFamily,
                    color: Colors.white, fontSize: 15.w
                ),
              ),
              Text(
                '月均雨量 : 80mm',
                style: TextStyle(
                    fontWeight: FontWeight.normal, fontFamily: GoogleFonts.kiwiMaru().fontFamily,
                    color: Colors.white, fontSize: 15.w
                ),
              ),
              Text(
                '溫度範圍 : 攝氏10~30度',
                style: TextStyle(
                    fontWeight: FontWeight.normal, fontFamily: GoogleFonts.kiwiMaru().fontFamily,
                    color: Colors.white, fontSize: 15.w
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // CustomCachedImage(
              //   imageUrl: weather.current.condition.icon.toHighRes().addHttpPrefix(),
              //   fit: BoxFit.cover,
              //   width: 80.w,
              //   height: 80.h,
              //   color: Colors.black54,
              // ),
              Lottie.asset(
                'assets/jsons/Weather-sunny.json',
                width: 60.w,
                height: 60.h,
                fit: BoxFit.cover,
              ),
              Text(
                ' ${weather.current.tempC.round()}${Strings.celsius}',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold, fontFamily: GoogleFonts.darumadropOne().fontFamily,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}