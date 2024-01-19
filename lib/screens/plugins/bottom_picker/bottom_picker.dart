import 'resources/arrays.dart';
import 'resources/context_extension.dart';
import 'resources/time.dart';
import 'widgets/bottom_picker_button.dart';
import 'widgets/close_icon.dart';
import 'widgets/date_picker.dart';
import 'widgets/range_picker.dart';
import 'widgets/simple_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'resources/extensions.dart';
export 'resources/time.dart';

// ignore: must_be_immutable
class BottomPicker extends StatefulWidget {
  ///The dateTime picker mode
  ///[CupertinoDatePickerMode.date] or [CupertinoDatePickerMode.dateAndTime] or [CupertinoDatePickerMode.time]
  ///
  late CupertinoDatePickerMode datePickerMode;

  ///the bottom picker type
  ///```dart
  ///{
  ///simple,
  ///dateTime
  ///}
  ///```
  late BottomPickerType bottomPickerType;

  BottomPicker({
    Key? key,
    required this.title,
    required this.items,
    this.description = '',
    this.titleStyle = const TextStyle(),
    this.titleAlignment = CrossAxisAlignment.start,
    this.titlePadding = const EdgeInsets.all(0),
    this.descriptionStyle = const TextStyle(),
    this.dismissable = false,
    this.onChange,
    this.onSubmit,
    this.onClose,
    this.bottomPickerTheme = BottomPickerTheme.blue,
    this.gradientColors,
    this.iconColor = Colors.white,
    this.selectedItemIndex = 0,
    this.buttonText,
    this.buttonPadding,
    this.buttonWidth,
    this.buttonTextStyle,
    this.displayButtonIcon = true,
    this.buttonSingleColor,
    this.backgroundColor = Colors.transparent,
    this.pickerTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    this.itemExtent = 32.0,
    this.displayCloseIcon = true,
    this.closeIconColor = Colors.black,
    this.closeIconSize = 20,
    this.layoutOrientation = LayoutOrientation.ltr,
    this.buttonAlignment = MainAxisAlignment.center,
    this.buttonTextAlignment = MainAxisAlignment.center,
    this.height,
    this.displaySubmitButton = true,
    this.selectionOverlay,
  }) : super(key: key) {
    dateOrder = null;
    onRangeDateSubmitPressed = null;
    bottomPickerType = BottomPickerType.simple;
    assert(items != null && items!.isNotEmpty);
    assert(selectedItemIndex >= 0);
    if (selectedItemIndex > 0) {
      assert(selectedItemIndex < items!.length);
    }
  }

  BottomPicker.date({
    Key? key,
    required this.title,
    this.description = '',
    this.titleStyle = const TextStyle(),
    this.titlePadding = const EdgeInsets.all(0),
    this.titleAlignment = CrossAxisAlignment.start,
    this.descriptionStyle = const TextStyle(),
    this.dismissable = false,
    this.onChange,
    this.onSubmit,
    this.onClose,
    this.bottomPickerTheme = BottomPickerTheme.blue,
    this.gradientColors,
    this.iconColor = Colors.white,
    this.initialDateTime,
    this.minDateTime,
    this.maxDateTime,
    this.buttonText,
    this.buttonPadding,
    this.buttonWidth,
    this.buttonTextStyle,
    this.displayButtonIcon = true,
    this.buttonSingleColor,
    this.backgroundColor = Colors.transparent,
    this.dateOrder = DatePickerDateOrder.ymd,
    this.pickerTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    this.displayCloseIcon = true,
    this.closeIconColor = Colors.black,
    this.closeIconSize = 20,
    this.layoutOrientation = LayoutOrientation.ltr,
    this.buttonAlignment = MainAxisAlignment.center,
    this.buttonTextAlignment = MainAxisAlignment.center,
    this.height,
    this.displaySubmitButton = true,
  }) : super(key: key) {
    datePickerMode = CupertinoDatePickerMode.date;
    bottomPickerType = BottomPickerType.dateTime;
    use24hFormat = false;
    itemExtent = 0;
    onRangeDateSubmitPressed = null;
    assertInitialValues();
  }

  BottomPicker.dateTime({
    Key? key,
    required this.title,
    this.description = '',
    this.titleStyle = const TextStyle(),
    this.titlePadding = const EdgeInsets.all(0),
    this.titleAlignment = CrossAxisAlignment.start,
    this.descriptionStyle = const TextStyle(),
    this.dismissable = false,
    this.onChange,
    this.onSubmit,
    this.onClose,
    this.bottomPickerTheme = BottomPickerTheme.blue,
    this.gradientColors,
    this.iconColor = Colors.white,
    this.initialDateTime,
    this.minuteInterval,
    this.minDateTime,
    this.maxDateTime,
    this.use24hFormat = false,
    this.buttonText,
    this.buttonPadding,
    this.buttonWidth,
    this.buttonTextStyle,
    this.displayButtonIcon = true,
    this.buttonSingleColor,
    this.backgroundColor = Colors.transparent,
    this.dateOrder = DatePickerDateOrder.ymd,
    this.pickerTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    this.displayCloseIcon = true,
    this.closeIconColor = Colors.black,
    this.closeIconSize = 20,
    this.layoutOrientation = LayoutOrientation.ltr,
    this.buttonAlignment = MainAxisAlignment.center,
    this.buttonTextAlignment = MainAxisAlignment.center,
    this.height,
    this.displaySubmitButton = true,
  }) : super(key: key) {
    datePickerMode = CupertinoDatePickerMode.dateAndTime;
    bottomPickerType = BottomPickerType.dateTime;
    itemExtent = 0;
    onRangeDateSubmitPressed = null;
    assertInitialValues();
  }

  BottomPicker.time({
    Key? key,
    required this.title,
    required this.initialTime,
    this.maxTime,
    this.minTime,
    this.description = '',
    this.titleStyle = const TextStyle(),
    this.titlePadding = const EdgeInsets.all(0),
    this.titleAlignment = CrossAxisAlignment.start,
    this.descriptionStyle = const TextStyle(),
    this.dismissable = false,
    this.onChange,
    this.onSubmit,
    this.onClose,
    this.bottomPickerTheme = BottomPickerTheme.blue,
    this.gradientColors,
    this.iconColor = Colors.white,
    this.minuteInterval = 1,
    this.use24hFormat = false,
    this.buttonText,
    this.buttonPadding,
    this.buttonWidth,
    this.buttonTextStyle,
    this.displayButtonIcon = true,
    this.buttonSingleColor,
    this.backgroundColor = Colors.transparent,
    this.pickerTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    this.displayCloseIcon = true,
    this.closeIconColor = Colors.black,
    this.closeIconSize = 20,
    this.layoutOrientation = LayoutOrientation.ltr,
    this.buttonAlignment = MainAxisAlignment.center,
    this.buttonTextAlignment = MainAxisAlignment.center,
    this.height,
    this.displaySubmitButton = true,
  }) : super(key: key) {
    datePickerMode = CupertinoDatePickerMode.time;
    bottomPickerType = BottomPickerType.time;
    dateOrder = null;
    itemExtent = 0;
    onRangeDateSubmitPressed = null;
    initialDateTime = null;
    assertInitialValues();
  }

  BottomPicker.range({
    Key? key,
    required this.title,
    required this.onRangeDateSubmitPressed,
    this.description = '',
    this.titleStyle = const TextStyle(),
    this.titlePadding = const EdgeInsets.all(0),
    this.titleAlignment = CrossAxisAlignment.start,
    this.descriptionStyle = const TextStyle(),
    this.dismissable = false,
    this.onClose,
    this.bottomPickerTheme = BottomPickerTheme.blue,
    this.gradientColors,
    this.iconColor = Colors.white,
    this.buttonText,
    this.buttonPadding,
    this.buttonWidth,
    this.buttonTextStyle,
    this.displayButtonIcon = true,
    this.buttonSingleColor,
    this.backgroundColor = Colors.transparent,
    this.pickerTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    this.displayCloseIcon = true,
    this.closeIconColor = Colors.black,
    this.closeIconSize = 20,
    this.layoutOrientation = LayoutOrientation.ltr,
    this.buttonAlignment = MainAxisAlignment.center,
    this.buttonTextAlignment = MainAxisAlignment.center,
    this.height,
    this.initialSecondDate,
    this.initialFirstDate,
    this.minFirstDate,
    this.minSecondDate,
    this.maxFirstDate,
    this.maxSecondDate,
    this.dateOrder = DatePickerDateOrder.ymd,
  }) : super(key: key) {
    datePickerMode = CupertinoDatePickerMode.date;
    bottomPickerType = BottomPickerType.rangeDateTime;
    dateOrder = null;
    itemExtent = 0;
    onChange = null;
    onSubmit = null;
    displaySubmitButton = true;
    assert(onRangeDateSubmitPressed != null);
    assertInitialValues();
    if (minSecondDate != null && initialSecondDate != null) {
      assert(initialSecondDate!.isAfter(minSecondDate!));
    }
    if (minFirstDate != null && initialFirstDate != null) {
      assert(initialFirstDate!.isAfter(minFirstDate!));
    }
  }

  ///The title of the bottom picker
  ///it's required for all bottom picker types
  final String title;

  ///The description of the bottom picker (displayed below the text)
  ///by default it's an empty text
  final String description;

  ///The text style applied on the title
  ///by default it applies simple text style
  final TextStyle titleStyle;

  ///The padding applied on the title
  ///by default it is set with zero values
  final EdgeInsetsGeometry titlePadding;

  ///Title and description alignment
  ///The default value is `MainAxisAlignment.center`
  final CrossAxisAlignment titleAlignment;

  ///The text style applied on the description
  ///by default it applies simple text style
  final TextStyle descriptionStyle;

  ///defines whether the bottom picker is dismissable or not
  ///by default it's set to false
  ///
  final bool dismissable;

  ///list of items (List of text) used to create simple item picker (required)
  ///and should not be empty or null
  ///
  ///for date/dateTime/time items parameter is not available
  ///
  late List<Text>? items;

  ///Nullable function, invoked when navigating between picker items
  ///whether it's date picker or simple item picker it will return a value DateTime or int(index)
  ///
  late Function(dynamic)? onChange;

  ///Nullable function invoked  when clicking on submit button
  ///if the picker  type is date/time/dateTime it will return DateTime value
  ///else it will return the index of the selected item
  ///
  late Function(dynamic)? onSubmit;

  ///Invoked when clicking on the close button
  ///
  final Function? onClose;

  ///set the theme of the bottom picker (the button theme)
  ///possible values
  ///```
  ///{
  ///blue,
  ///orange,
  ///temptingAzure,
  ///heavyRain,
  ///plumPlate,
  ///morningSalad
  ///}
  ///```
  final BottomPickerTheme bottomPickerTheme;

  ///to set a custom button theme color use this list
  ///when it's not null it will be applied
  ///
  final List<Color>? gradientColors;

  ///define the icon color on the button
  ///by default it's White
  ///
  final Color iconColor;

  ///used for simple bottom picker
  ///by default it's 0, needs to be in the range [0, this.items.length-1]
  ///otherwise an exception will be thrown
  ///for date and time picker type this parameter is not available
  ///
  late int selectedItemIndex;

  ///The initial date time applied on the date and time picker
  ///by default it's null
  ///
  DateTime? initialDateTime;

  ///The initial time set in the time picker widget
  ///required only when using the `time` constructor
  Time? initialTime;

  ///The max time can be set in the time picker widget
  Time? maxTime;

  ///The min time can be set in the time picker widget
  Time? minTime;

  ///The gap between two minutes
  ///by default it's 1 minute
  int? minuteInterval;

  ///the max date time on the date picker
  ///by default it's null
  DateTime? maxDateTime;

  ///the minimum date & time applied on the date picker
  ///by default it's null
  ///
  DateTime? minDateTime;

  ///define whether the time uses 24h or 12h format
  ///by default it's false (12h format)
  ///
  late bool use24hFormat;

  ///the text that will be applied to the button
  ///if the text is null the button will be rendered with an icon
  final String? buttonText;

  ///the padding that will be applied to the button
  ///if the padding is null the button will be rendered null
  final double? buttonPadding;

  ///the width that will be applied to the button
  ///if the buttonWidth is null the button will be rendered with null
  final double? buttonWidth;

  ///the button text style, will be applied on the button's text
  final TextStyle? buttonTextStyle;

  ///display button icon
  ///by default it's true
  ///if you want to display a text you can set [displayButtonIcon] to false
  final bool displayButtonIcon;

  ///a single color will be applied to the button instead of the gradient
  ///themes
  ///
  final Color? buttonSingleColor;

  ///the bottom picker background color,
  ///by default it's white
  ///
  final Color backgroundColor;

  ///date order applied on date picker or date time picker
  ///by default it's YYYY/MM/DD
  late DatePickerDateOrder? dateOrder;

  ///the picker text style applied on all types of bottom picker
  ///by default `TextStyle(fontSize: 14)`
  final TextStyle pickerTextStyle;

  ///define the picker item extent available only for list items picker
  ///by default it's 35
  late double itemExtent;

  ///indicate whether the close icon will be rendred or not
  /// by default `displayCloseIcon = true`
  final bool displayCloseIcon;

  ///the close icon color
  ///by default `closeIconColor = Colors.black`
  final Color closeIconColor;

  ///the close icon size
  ///by default `closeIconSize = 20`
  final double closeIconSize;

  ///the layout orientation of the bottom picker
  ///by default the orientation is set to LTR
  ///```
  ///LAYOUT_ORIENTATION.ltr,
  ///LAYOUT_ORIENTATION.rtl
  ///```
  final LayoutOrientation layoutOrientation;

  ///THe alignment of the bottom picker button
  ///by default it's `MainAxisAlignment.center`
  final MainAxisAlignment buttonAlignment;

  ///The alignment of the bottom picker button text
  ///by default it's `MainAxisAlignment.center`
  final MainAxisAlignment buttonTextAlignment;

  ///bottom picker main widget height
  ///if it's null the bottom picker will get the height from
  ///[bottomPickerHeight] extension on context
  final double? height;

  ///indicates if the submit button will be displayed or not
  ///by default the submit button is shown
  late bool displaySubmitButton;

  ///invoked when pressing on the submit button when using range picker
  ///it return two dates (first date, end date)
  ///required when using [BottomPicker.range]
  late Function(DateTime, DateTime)? onRangeDateSubmitPressed;

  ///the minimum first date in the date range picker
  ///not required if null no minimum will be set in the date picker
  DateTime? minFirstDate;

  ///the minimum second date in the date range picker
  ///not required if null no minimum will be set in the date picker
  DateTime? minSecondDate;

  ///the maximum first date in the date range picker
  ///not required if null no minimum will be set in the date picker
  DateTime? maxFirstDate;

  ///the maximum second date in the date range picker
  ///not required if null no minimum will be set in the date picker
  DateTime? maxSecondDate;

  ///the initial first date in the date range picker
  ///not required if null no minimum will be set in the date picker
  DateTime? initialFirstDate;

  ///the initial last date in the date range picker
  ///not required if null no minimum will be set in the date picker
  DateTime? initialSecondDate;

  /// A widget overlaid on the picker to highlight the currently selected entry.
  /// The [selectionOverlay] widget drawn above the [CupertinoPicker]'s picker
  /// wheel.
  Widget? selectionOverlay;

  ///display the bottom picker popup
  ///[context] the app context to display the popup
  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: dismissable,
      enableDrag: true,
      constraints: BoxConstraints(
        maxWidth: context.bottomPickerWidth,
      ),
      builder: (context) {
        return BottomSheet(
          enableDrag: false,
          onClosing: () {},
          builder: (context) {
            return this;
          },
        );
      },
    );
  }

  @override
  _BottomPickerState createState() => _BottomPickerState();
}

class _BottomPickerState extends State<BottomPicker> {
  late int selectedItemIndex;
  late DateTime selectedDateTime;

  late DateTime selectedFirstDateTime =
      widget.initialFirstDate ?? DateTime.now();
  late DateTime selectedSecondDateTime =
      widget.initialSecondDate ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.bottomPickerType == BottomPickerType.simple) {
      selectedItemIndex = widget.selectedItemIndex;
    } else if (widget.bottomPickerType == BottomPickerType.time) {
      selectedDateTime = (widget.initialTime ?? Time.now()).toDateTime;
    } else {
      selectedDateTime = widget.initialDateTime ?? DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? context.bottomPickerHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28),
          topLeft: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
                  height: 5,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    color: Colors.grey[500],
                  ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: widget.layoutOrientation == LayoutOrientation.rtl
                    ? _displayRTLOrientationLayout()
                    : _displayLTROrientationLayout(),
              ),
            ),
            Expanded(
              child: widget.bottomPickerType == BottomPickerType.simple
                  ? SimplePicker(
                      items: widget.items!,
                      onChange: (int index) {
                        selectedItemIndex = index;
                        widget.onChange?.call(index);
                      },
                      selectedItemIndex: widget.selectedItemIndex,
                      textStyle: widget.pickerTextStyle,
                      itemExtent: widget.itemExtent,
                      selectionOverlay: widget.selectionOverlay,
                      cupertinoEnabled: false, //block cupeertino style picker
                    )
                  : widget.bottomPickerType == BottomPickerType.time
                      ? DatePicker(
                          initialDateTime: widget.initialTime.toDateTime,
                          minuteInterval: widget.minuteInterval ?? 1,
                          maxDateTime: widget.maxTime.toDateTime,
                          minDateTime: widget.minTime.toDateTime,
                          mode: widget.datePickerMode,
                          onDateChanged: (DateTime date) {
                            selectedDateTime = date;
                            widget.onChange?.call(date);
                          },
                          use24hFormat: widget.use24hFormat,
                          dateOrder: widget.dateOrder,
                          textStyle: widget.pickerTextStyle,
                        )
                      : widget.bottomPickerType == BottomPickerType.dateTime
                          ? DatePicker(
                              initialDateTime: widget.initialDateTime,
                              minuteInterval: widget.minuteInterval ?? 1,
                              maxDateTime: widget.maxDateTime,
                              minDateTime: widget.minDateTime,
                              mode: widget.datePickerMode,
                              onDateChanged: (DateTime date) {
                                selectedDateTime = date;
                                widget.onChange?.call(date);
                              },
                              use24hFormat: widget.use24hFormat,
                              dateOrder: widget.dateOrder,
                              textStyle: widget.pickerTextStyle,
                            )
                          : RangePicker(
                              initialFirstDateTime: widget.initialFirstDate,
                              initialSecondDateTime: widget.initialSecondDate,
                              maxFirstDate: widget.maxFirstDate,
                              minFirstDate: widget.minFirstDate,
                              maxSecondDate: widget.maxSecondDate,
                              minSecondDate: widget.minSecondDate,
                              onFirstDateChanged: (DateTime date) {
                                selectedFirstDateTime = date;
                              },
                              onSecondDateChanged: (DateTime date) {
                                selectedSecondDateTime = date;
                              },
                              dateOrder: widget.dateOrder,
                              textStyle: widget.pickerTextStyle,
                            ),
            ),
            if (widget.displaySubmitButton)
              Row(
                mainAxisAlignment: widget.buttonAlignment,
                children: [
                  BottomPickerButton(
                    onClick: () {
                      if (widget.bottomPickerType ==
                          BottomPickerType.rangeDateTime) {
                        widget.onRangeDateSubmitPressed?.call(
                          selectedFirstDateTime,
                          selectedSecondDateTime,
                        );
                      } else if (widget.bottomPickerType ==
                              BottomPickerType.dateTime ||
                          widget.bottomPickerType == BottomPickerType.time) {
                        widget.onSubmit?.call(selectedDateTime);
                      } else {
                        widget.onSubmit?.call(selectedItemIndex);
                      }
              
                      Navigator.pop(context);
                    },
                    buttonTextAlignment: widget.buttonTextAlignment,
                    iconColor: widget.iconColor,
                    gradientColors: widget.gradientColor,
                    text: widget.buttonText,
                    buttonPadding: widget.buttonPadding,
                    buttonWidth: widget.buttonWidth,
                    textStyle: widget.buttonTextStyle,
                    displayIcon: widget.displayButtonIcon,
                    solidColor: widget.buttonSingleColor,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  ///render list widgets for RTL orientation
  List<Widget> _displayRTLOrientationLayout() {
    return [
      if (widget.displayCloseIcon)
        CloseIcon(
          onPress: _closeBottomPicker,
          iconColor: widget.closeIconColor,
          closeIconSize: widget.closeIconSize,
        ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: widget.titlePadding,
              child: Text(
                widget.title,
                style: widget.titleStyle,
                textAlign: TextAlign.end,
              ),
            ),
            Text(
              widget.description,
              style: widget.descriptionStyle,
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    ];
  }

  ///render list widgets for LTR orientation
  List<Widget> _displayLTROrientationLayout() {
    return [
      Expanded(
        child: Column(
          crossAxisAlignment: widget.titleAlignment,
          children: [
            Padding(
              padding: widget.titlePadding,
              child: Text(
                widget.title,
                style: widget.titleStyle,
              ),
            ),
            if (widget.description.isNotEmpty)
              Text(
                widget.description,
                style: widget.descriptionStyle,
              ),
          ],
        ),
      ),
      if (widget.displayCloseIcon)
        CloseIcon(
          onPress: _closeBottomPicker,
          iconColor: widget.closeIconColor,
          closeIconSize: widget.closeIconSize,
        ),
    ];
  }

  void _closeBottomPicker() {
    Navigator.pop(context);
    widget.onClose?.call();
  }
}
