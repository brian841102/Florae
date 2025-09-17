import 'dart:io';
import 'dart:math';

import 'package:florae/data/default.dart';
import 'package:florae/data/plant.dart';
import 'package:florae/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ManagePlantScreen extends StatefulWidget {
  const ManagePlantScreen({super.key, required this.title, required this.update, this.plant});

  final String title;
  final bool update;
  final Plant? plant;

  @override
  State<ManagePlantScreen> createState() => _ManagePlantScreen();
}

class _ManagePlantScreen extends State<ManagePlantScreen> {
  Map<String, Care> cares = {};

  DateTime _planted = DateTime.now();

  List<Plant> _plants = [];

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  int _prefNumber = 1;

  Future getImageFromCam() async {
    var image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 25);
    setState(() {
      _image = image;
    });
  }

  Future getImageFromGallery() async {
    var image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 25);
    setState(() {
      _image = image;
    });
  }

  void getPrefabImage() {
    if (_prefNumber < 8) {
      setState(() {
        _image = null;
        _prefNumber++;
      });
    } else {
      setState(() {
        _image = null;
        _prefNumber = 1;
      });
    }
  }

  void _showIntegerDialog(String care) async {
    FocusManager.instance.primaryFocus?.unfocus();
    String tempDaysValue = "";

    await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.selectDays),
            content: ListTile(
                leading: const Icon(Icons.loop),
                title: TextFormField(
                  onChanged: (String txt) => tempDaysValue = txt,
                  autofocus: true,
                  initialValue: cares[care]!.cycles.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                ),
                trailing: Text(AppLocalizations.of(context)!.days)),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () {
                  setState(() {
                    var parsedDays = int.tryParse(tempDaysValue);
                    if (parsedDays == null) {
                      cares[care]!.cycles = 0;
                    } else {
                      cares[care]!.cycles = parsedDays;
                    }
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _loadPlants();

    // If is an update, restore old cares
    if (widget.update && widget.plant != null) {
      for (var care in widget.plant!.cares) {
        cares[care.name] = Care(name: care.name, cycles: care.cycles, effected: care.effected);
      }
      nameController.text = widget.plant!.name;
      descriptionController.text = widget.plant!.description;
      locationController.text = widget.plant!.location ?? "";

      if (widget.plant!.picture!.contains("florae_avatar")) {
        String? asset = widget.plant!.picture!.replaceAll(RegExp(r'\D'), ''); // '23'
        _prefNumber = int.tryParse(asset) ?? 1;
      } else {
        _image = XFile(widget.plant!.picture!);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Filling in the empty cares
    DefaultValues.getCares(context).forEach((key, value) {
      if (cares[key] == null) {
        cares[key] = Care(cycles: value.defaultCycles, effected: DateTime.now(), name: key);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<ListTile> _buildCares(BuildContext context) {
    List<ListTile> list = [];

    DefaultValues.getCares(context).forEach((key, value) {
      list.add(ListTile(
          trailing: const Icon(Icons.arrow_right),
          leading: Icon(value.icon, color: value.color),
          title: Text('${value.translatedName} ${AppLocalizations.of(context)!.every}'),
          subtitle: cares[key]!.cycles != 0
              ? Text(cares[key]!.cycles.toString() + " ${AppLocalizations.of(context)!.days}")
              : Text(AppLocalizations.of(context)!.never),
          onTap: () {
            _showIntegerDialog(key);
          }));
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: FittedBox(
            fit: BoxFit.fitWidth,
            child: widget.update
                ? Text(AppLocalizations.of(context)!.titleEditPlant)
                : Text(AppLocalizations.of(context)!.titleNewPlant)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            fontFamily: "NotoSans"),
      ),
      //passing in the ListView.builder
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 2,
                child: SizedBox(
                    child: Column(
                  children: <Widget>[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0), //or 15.0
                      child: SizedBox(
                        height: 200,
                        child: _image == null
                            ? Image.asset(
                                "assets/images/florae_avatar_$_prefNumber.png",
                                // TODO: Adjust the box size (102)
                                fit: BoxFit.fitWidth,
                              )
                            : Image.file(File(_image!.path)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          onPressed: getImageFromCam,
                          icon: const Icon(Icons.add_a_photo),
                          tooltip: AppLocalizations.of(context)!.tooltipCameraImage,
                        ),
                        IconButton(
                            onPressed: getPrefabImage,
                            icon: const Icon(Icons.refresh),
                            tooltip: AppLocalizations.of(context)!.tooltipNextAvatar),
                        IconButton(
                          onPressed: getImageFromGallery,
                          icon: const Icon(Icons.wallpaper),
                          tooltip: AppLocalizations.of(context)!.tooltipGalleryImage,
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                )),
              ),
              Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        enabled: !widget.update,
                        validator: (value) {
                          if (widget.update) {
                            return null;
                          }
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.emptyError;
                          }
                          if (findPlant(value) != null) {
                            return AppLocalizations.of(context)!.conflictError;
                          }
                          return null;
                        },
                        maxLength: 20,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.local_florist),
                          labelText: AppLocalizations.of(context)!.labelName,
                          helperText: AppLocalizations.of(context)!.exampleName,
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        //Normal textInputField will be displayed
                        maxLines: 3,
                        // when user presses enter it will adapt to it
                        controller: descriptionController,
                        maxLength: 100,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.topic),
                          labelText: AppLocalizations.of(context)!.labelDescription,
                        ),
                      ),
                      TextFormField(
                        controller: locationController,
                        maxLength: 20,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.location_on),
                          labelText: AppLocalizations.of(context)!.labelLocation,
                          helperText: AppLocalizations.of(context)!.exampleLocation,
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(children: _buildCares(context)),
              ),
              Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  trailing: const Icon(Icons.arrow_right),
                  leading: const Icon(Icons.cake),
                  enabled: !widget.update,
                  title: Text(AppLocalizations.of(context)!.labelDayPlanted),
                  subtitle: Text(DateFormat.yMMMMEEEEd(Localizations.localeOf(context).languageCode)
                      .format(_planted)),
                  onTap: () async {
                    DateTime? result = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 1000)),
                        lastDate: DateTime.now());
                    setState(() {
                      _planted = result ?? DateTime.now();
                    });
                  },
                ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          String fileName = "";
          if (_formKey.currentState!.validate()) {
            if (_image != null) {
              final Directory? directory = Platform.isAndroid
                  ? await getExternalStorageDirectory()
                  : await getApplicationDocumentsDirectory();
              fileName =
                  directory!.path + "/" + generateRandomString(10) + p.extension(_image!.path);
              _image!.saveTo(fileName);
            }

            // Creates new plant object with previous id if we are editing
            // or generates a Id if we are creating a new plant
            final newPlant = Plant(
                id: widget.plant != null ? widget.plant!.id : 0,
                name: nameController.text,
                createdAt: _planted,
                description: descriptionController.text,
                picture: _image != null ? fileName : "assets/images/florae_avatar_$_prefNumber.png",
                location: locationController.text);

            // Assign cares to plant
            newPlant.cares.clear();

            cares.forEach((key, value) {
              if (value.cycles != 0) {
                newPlant.cares.add(Care(cycles: value.cycles, effected: value.effected, name: key));
              }
            });

            // ObjectBox does not track ToMany changes
            // https://github.com/objectbox/objectbox-dart/issues/326
            if (widget.update && widget.plant != null) {
              widget.plant!.cares.clear();
              objectbox.plantBox.put(widget.plant!);
            }

            objectbox.plantBox.put(newPlant);

            Navigator.popUntil(context, ModalRoute.withName('/'));
          }
        },
        label: Text(AppLocalizations.of(context)!.saveButton),
        icon: const Icon(Icons.save),
      ),
    );
  }

  String generateRandomString(int length) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();

    return String.fromCharCodes(
        Iterable.generate(length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  _loadPlants() async {
    List<Plant> allPlants = objectbox.plantBox.getAll();
    setState(() => _plants = allPlants);
  }

  Plant? findPlant(String name) =>
      _plants.cast().firstWhere((plant) => plant.name == name, orElse: () => null);
}
