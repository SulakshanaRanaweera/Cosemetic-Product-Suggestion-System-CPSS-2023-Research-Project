//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                              //
//                                                                                                              //
//                                  Cosmetic Product Suggestions System                                         //
//                                       2023-381 Research Project                                              //
//                                                                                                              //
//                                                                                                              //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// main.dart
import 'package:tflite/tflite.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:math';


void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'CPSS',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
              .copyWith(secondary: Colors.tealAccent)),

      home: const HomePage(),
    );
  }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                              //
//                                                                                                              //
//                                               Home Page                                                      //
//                                                                                                              //
//                                                                                                              //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CPSS'),
      ),
      body: const Center(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
         // Positioned(
           // bottom: 600,
         //   left: 105,
           // child: Image.asset('assets/images/cosmetic.jpeg'),
          //  ),


          Positioned(
            bottom: 500,
            left: 100,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                    MaterialPageRoute(builder: (context)=> FacialPage())
                );
              },
              //shape: RoundedRectangleBorder(
                //borderRadius: BorderRadius.circular(10),
             // ),
              child: const Text('Facial Based Suggestion'),
            ),
          ),
          Positioned(
            bottom: 450,
            left: 105,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(builder: (context)=> HairPage())
                );
              },
              //shape: RoundedRectangleBorder(
              //borderRadius: BorderRadius.circular(10),
              // ),
              child: const Text('Hair Based Suggestion'),
            ),
          ),
          Positioned(
            bottom: 400,
            left: 115,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                    MaterialPageRoute(builder: (context)=> SkinTypePage())
                );
              },
              //shape: RoundedRectangleBorder(
              //borderRadius: BorderRadius.circular(10),
              // ),
              child: const Text('Skin Type Detection'),
            ),
          ),
          Positioned(
            bottom: 350,
            left: 105,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                    MaterialPageRoute(builder: (context)=> SkinPage())
                );
              },
              //shape: RoundedRectangleBorder(
              //borderRadius: BorderRadius.circular(10),
              // ),
              child: const Text('Skin Disease Detection'),
            ),
          ),
          // Add more floating buttons if you want
          // There is no limit
        ],
      ),
    );
  }



}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                              //
//                                                                                                              //
//                                        Hair Condition Detection                                              //
//                                                                                                              //
//                                                                                                              //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class HairPage extends StatefulWidget{
  @override
  _HairPageState createState() => _HairPageState();
}
class _HairPageState extends State<HairPage>{

  final String assetPath = 'assets/csv/cosmetics.csv'; // Path to CSV File
  String filterValue = 'Hair';

  String? brandValue;
  String? nameValue;

  List? _outputs;

  late bool _loading = false;



  XFile? imageFile;
  File? _image;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadDiseaseModel().then((value) {
      setState(() {
        _loading = false;
      });
    });


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hair Condition Detection')),
      body:  _loading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Container()
                : Container(
              child: Image.file(_image!),
              height: 500,
              width: MediaQuery.of(context).size.width - 200,
            ),
            const SizedBox(
              height: 20,
            ),
            _outputs != null
                ? Text( "Identified Condition - ${"${_outputs![0]["label"]}"
                .replaceAll(RegExp(r'[0-9]'), '')}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
                : const Text("Please select an image to classify"),


            //Hair Products Suggestion
            const SizedBox(
              height: 20,
            ),
            //Product Suggestion Line
            if (brandValue != null)
              Text('Suggested Product: $brandValue $nameValue'),
            if (brandValue == null)
              Text(''),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>pickImage(),
        tooltip: 'Increment',
        child: const Icon(Icons.image),
      ),
    );
  }



  pickImage() async {

    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile == null) return null;
    setState(() {
      _loading = true;
      _image = File(imageFile!.path);
    });

    classifyImage(_image!);
    suggestHairProduct();
  }

  loadDiseaseModel() async {
    await Tflite.loadModel(
        model: "assets/models/hair_disease_model/hair_disease_detection-Final.tflite", labels: "assets/models/hair_disease_model/labels.txt");
  }



  //classify the image selected
  classifyImage(File image) async {

    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );



    setState(() {
      _loading = false;
      //Declare List _outputs in the class which will be used to show the classified classs name and confidence
      _outputs = output!;

      print(output);
    });
  }

  void disposeModels() {
    Tflite.close();
  }


  //Function to filter data from csv file
  Future<void> suggestHairProduct() async {
    String csvString = await rootBundle.loadString(assetPath);
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);

    List<List<dynamic>> matchingRows = [];

    for (var row in csvTable) {
      if (row.contains(filterValue)) {
        matchingRows.add(row);
      }
    }

    if (matchingRows.isNotEmpty) {
      final random = Random();
      final randomIndex = random.nextInt(matchingRows.length);
      final selectedRow = matchingRows[randomIndex];

      setState(() {
        if (selectedRow.length > 1) {
          brandValue = selectedRow[1].toString(); // Get the Brand Name
          nameValue = selectedRow[2].toString(); // Get the Name of the product
        } else {
          brandValue = null;
        }
      });
    } else {
      setState(() {
        brandValue = null;
        nameValue = null;
      });
    }
  }

}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                              //
//                                                                                                              //
//                                      Facial Condition Detection                                              //
//                                                                                                              //
//                                                                                                              //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class FacialPage extends StatefulWidget{
  @override
  _FacialPageState createState() => _FacialPageState();
}
class _FacialPageState extends State<FacialPage>{


  final String assetPath = 'assets/csv/cosmetics.csv'; // Path to CSV File
  String filterValue = "Face";

  String? brandValue;
  String? nameValue;



  List? _outputsGender;
  List? _outputsCondition;
  List? _outputsSkinType;

  late bool _loading = false;

  String conditionModelPath = "assets/models/face_condition_model/facial_condition.tflite";


  XFile? imageFile;
  File? _image;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadGenderModel().then((value) {
      setState(() {
        _loading = true;
      });
    });

    loadConditionModel().then((value) {
      setState(() {
        _loading = true;
      });
    });

    loadSkinTypeModel().then((value) {
      setState(() {
        _loading = false;
      });
    });


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Facial Condition Detection')),
      body:  _loading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Container()
                : Container(
              child: Image.file(_image!),
              height: 500,
              width: MediaQuery.of(context).size.width - 200,
            ),
            const SizedBox(
              height: 20,
            ),



            //Product Suggestion Line
            if (brandValue != null)
              Text('Suggested Product: $brandValue $nameValue'),
            if (brandValue == null)
              Text(''),

            const SizedBox(
              height: 20,
            ),

            _outputsGender != null
                ? Text( "Identified Gender - ${"${_outputsGender![0]["label"]}"
                .replaceAll(RegExp(r'[0-9]'), '')}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
                : const Text("Please select an image to classify"),


            //Second Line
            const SizedBox(
              height: 20,
            ),
            _outputsCondition != null
                ? Text( "Identified Condition - ${"${_outputsCondition![0]["label"]}"
                .replaceAll(RegExp(r'[0-9]'), '')}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
                : Text(""),

            //Third Line
            const SizedBox(
              height: 20,
            ),
            _outputsCondition != null
                ? Text( "Identified Skin Type - ${"${_outputsSkinType![0]["label"]}"
                .replaceAll(RegExp(r'[0-9]'), '')}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
                : Text(""),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>pickImage(),
        tooltip: 'Increment',
        child: const Icon(Icons.image),
      ),
    );
  }



  pickImage() async {

    loadGenderModel().then((value) {
      setState(() {
        _loading = true;
      });
    });

    loadConditionModel().then((value) {
      setState(() {
        _loading = true;
      });
    });

    loadSkinTypeModel().then((value) {
      setState(() {
        _loading = false;
      });
    });

    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile == null) return null;
    setState(() {
      _loading = true;
      _image = File(imageFile!.path);
    });

    classifyImage(_image!);

    suggestFacialProduct();


  }

  loadGenderModel() async {
    await Tflite.loadModel(
        model: "assets/models/gender_identification_model/gender_identification.tflite", labels: "assets/models/gender_identification_model/labels.txt");
  }

  loadConditionModel() async {
    await Tflite.loadModel(
        model: "assets/models/face_condition_model/facial_condition.tflite", labels: "assets/models/face_condition_model/labels.txt");
  }

  loadSkinTypeModel() async {
    await Tflite.loadModel(
        model: "assets/models/skin_type_model/skin_type_identification.tflite", labels: "assets/models/skin_type_model/labels.txt");
  }


  //classify the image selected
  classifyImage(File image) async {

    disposeModels();

    setState(() {
      _loading = true;
    });

    loadGenderModel().then((value) {
      setState(() {
        _loading = true;
      });
    });

    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 128,
      imageStd: 128,
    );

    disposeModels();

    setState(() {
      _loading = true;
    });

    loadConditionModel().then((value) {
      setState(() {
        _loading = true;
      });
    });

    var output2 = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 128,
      imageStd: 128,
    );


    loadSkinTypeModel().then((value) {
      setState(() {
        _loading = true;
      });
    });

    var output3 = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 128,
      imageStd: 128,
    );


    disposeModels();

    setState(() {
      _loading = false;
      //Declare List _outputs in the class which will be used to show the classified classs name and confidence
      _outputsGender = output!;
      _outputsCondition = output2!;
      _outputsSkinType = output3!;

      print(_outputsGender);
      print(output3);
    });
  }

  void disposeModels() {
    Tflite.close();
  }




  //Function to filter data from csv file
  Future<void> suggestFacialProduct() async {
    String csvString = await rootBundle.loadString(assetPath);
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);

    List<List<dynamic>> matchingRows = [];

    for (var row in csvTable) {
      if (row.contains(filterValue)) {
        matchingRows.add(row);
      }
    }

    if (matchingRows.isNotEmpty) {
      final random = Random();
      final randomIndex = random.nextInt(matchingRows.length);
      final selectedRow = matchingRows[randomIndex];

      setState(() {
        if (selectedRow.length > 1) {
          brandValue = selectedRow[1].toString(); // Get the Brand Name
          nameValue = selectedRow[2].toString(); // Get the Name of the product
        } else {
          brandValue = null;
        }
      });
    } else {
      setState(() {
        brandValue = null;
        nameValue = null;
      });
    }
  }



}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                              //
//                                                                                                              //
//                                            Skin Type Detection                                               //
//                                                                                                              //
//                                                                                                              //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


class SkinTypePage extends StatefulWidget{
  @override
  _SkinTypePageState createState() => _SkinTypePageState();
}
class _SkinTypePageState extends State<SkinTypePage>{

  List? _outputs;
  late bool _loading = false;


  XFile? imageFile;
  File? _image;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Skin Type Detection')),
      body:  _loading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Container()
                : Container(
              child: Image.file(_image!),
              height: 500,
              width: MediaQuery.of(context).size.width - 200,
            ),
            const SizedBox(
              height: 20,
            ),
            _outputs != null
                ? Text( "Identified Skin Type - ${"${_outputs![0]["label"]}"
                .replaceAll(RegExp(r'[0-9]'), '')}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
                : const Text("Please select an image to classify"),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>pickImage(),
        tooltip: 'Increment',
        child: const Icon(Icons.image),
      ),
    );
  }



  pickImage() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile == null) return null;
    setState(() {
      _loading = true;
      _image = File(imageFile!.path);
    });

    classifyImage(_image!);
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/models/skin_type_model/skin_type_identification.tflite", labels: "assets/models/skin_type_model/labels.txt");
  }


  //classify the image selected
  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      //Declare List _outputs in the class which will be used to show the classified classs name and confidence
      _outputs = output!;

      print(_outputs);
    });
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                              //
//                                                                                                              //
//                                          Skin Disease Detection                                              //
//                                                                                                              //
//                                                                                                              //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


class SkinPage extends StatefulWidget{
  @override
  _SkinPageState createState() => _SkinPageState();
}
class _SkinPageState extends State<SkinPage>{

  List? _outputs;
  List? _outputsSeverity;
  late bool _loading = false;


  XFile? imageFile;
  File? _image;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = true;
      });
    });

    loadSeverityModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Skin Disease Detection')),
      body:  _loading
          ? Container(
             alignment: Alignment.center,
          child: CircularProgressIndicator(),
      )
          : Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Container()
                : Container(
              child: Image.file(_image!),
              height: 500,
              width: MediaQuery.of(context).size.width - 200,
            ),
            const SizedBox(
              height: 20,
            ),
            _outputs != null
                ? Text( "Identified Disease - ${"${_outputs![0]["label"]}"
                  .replaceAll(RegExp(r'[0-9]'), '')}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
                : const Text("Please select an image to classify"),


            //Second Line
            const SizedBox(
              height: 20,
            ),
            _outputs != null
                ? Text( "Identified Severity - ${"${_outputsSeverity![0]["label"]}"
                    .replaceAll(RegExp(r'[0-9]'), '')}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
                : Text("")
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>pickImage(),
        tooltip: 'Increment',
        child: const Icon(Icons.image),
      ),
    );
  }



  pickImage() async {

    loadModel().then((value) {
      setState(() {
        _loading = true;
      });
    });

    loadSeverityModel().then((value) {
      setState(() {
        _loading = false;
      });
    });

    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile == null) return null;
    setState(() {
      _loading = true;
      _image = File(imageFile!.path);
    });

    classifyImage(_image!);
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/models/skin_disease_model/skin_disease_identification_new.tflite", labels: "assets/models/skin_disease_model/labels.txt");
  }

  loadSeverityModel() async {
    await Tflite.loadModel(
        model: "assets/models/skin_disease_severity/skin_disease_severity.tflite", labels: "assets/models/skin_disease_severity/labels.txt");
  }


  //classify the image selected
  classifyImage(File image) async {

    disposeModels();

    setState(() {
      _loading = true;
    });

    loadModel().then((value) {
      setState(() {
        _loading = true;
      });
    });

    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    disposeModels();

    setState(() {
      _loading = true;
    });

    loadSeverityModel().then((value) {
      setState(() {
        _loading = true;
      });
    });

    var output2 = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.3,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _loading = false;
      //Declare List _outputs in the class which will be used to show the classified classs name and confidence
      _outputs = output!;
      _outputsSeverity = output2!;
      print(_outputs);
      print(_outputsSeverity);

      disposeModels();
    });
  }

  void disposeModels() {
    Tflite.close();
  }
}


