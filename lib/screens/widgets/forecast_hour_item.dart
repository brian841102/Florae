import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../utils/extensions.dart';
import '../../../../../config/translations/strings_enum.dart';
import '../plugins/custom_cached_image.dart';
import '../../../../data/models/weather_details_model.dart';

class ForecastHourItem extends StatelessWidget {
  final Hour hour;
  const ForecastHourItem({super.key, required this.hour});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      margin: EdgeInsetsDirectional.only(end: 10.w),
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hour.time.convertToTime(),
            style: theme.textTheme.bodyMedium,
          ),
          CustomCachedImage(
            imageUrl: hour.condition.icon.addHttpPrefix(),
            fit: BoxFit.cover,
            width: 50.w,
            height: 50.h,
          ),
          Text(
            '${hour.tempC.toInt().toString()}${Strings.celsius}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}