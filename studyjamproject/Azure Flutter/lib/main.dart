import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  var _response;
  var _buttonTitle = "Send Photo for Analyze";
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      _buttonTitle =  "Send Photo for Analyze";
    });
  }

  Future postData() async {
    setState(() {
          _buttonTitle = "Sending Photo...";
        });
    if(_image!=null){
    var httpClient = new Client();
    const subscriptionKey = "<AZURE_COGNITIVE_SERVICES_SUBSCRIPTION_KEY>";
    const uriBaseAnalyzeImage =
        "https://westeurope.api.cognitive.microsoft.com/vision/v1.0/analyze";
    const requestParameters = "visualFeatures=Categories,Description,Color";
    var imageData = _image.readAsBytesSync();
    print(imageData);
    var url = uriBaseAnalyzeImage + "?" + requestParameters;
    var response = await httpClient.post(url, body: imageData, headers: {
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'Content-Type': 'application/octet-stream'
    });
    print(response.body);

    if (response.statusCode == 200) {
      print('Response status: ${response.statusCode}');
      setState(() {
        _response = response;
        _buttonTitle = "Send Photo for Analyze";
      });
    } else {
      print("Servise bağlanılamadı.");
      setState(() {
        _buttonTitle = "An error occurred";
      });
    }
    }else{
setState(() {
          _buttonTitle = "Please select a photo";
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map data = _response == null ? null : json.decode(_response.body);
    return new Scaffold(
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(
                bottom: 10.0, left: 10.0, right: 10.0, top: 10.0),
            child: _image == null
                ? new Center(
                    child: Image.network(
                    'https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Art/defaultphoto_2x.png',
                    height: 250.0,
                  ))
                : new Image.file(_image),
          ),
          new Center(
            child: new RaisedButton(
              child: Text(_buttonTitle),
              onPressed: postData,
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(
                bottom: 0.0, left: 15.0, right: 15.0, top: 10.0),
            child: new SizedBox(
              height: 200.0,
              child: new ListView(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                children: <Widget>[
                  new Text('Captions',
                      style: TextStyle(fontSize: 15.0, color: Colors.red)),
                  new Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: data == null
                          ? Text("boş")
                          : Text(data['description']['captions'][0]['text'] +
                              " - " +
                              data['description']['captions'][0]['confidence']
                                  .toString())),
                  new Text('Category Name',
                      style: TextStyle(fontSize: 15.0, color: Colors.red)),
                  new Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: data == null
                          ? Text("boş")
                          : Text(data['categories'][0]['name'] +
                              " - " +
                              data['categories'][0]['score'].toString())),
                  new Text('Tags',
                      style: TextStyle(fontSize: 15.0, color: Colors.red)),
                  new Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: data == null
                          ? Text("boş")
                          : Text(data['description']['tags'].toString())),
                  new Text('Foreground Color',
                      style: TextStyle(fontSize: 15.0, color: Colors.red)),
                  new Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: data == null
                          ? Text("boş")
                          : Text(data['color']['dominantColorBackground'])),
                  new Text('Background Color',
                      style: TextStyle(fontSize: 15.0, color: Colors.red)),
                  new Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: data == null
                          ? Text("boş")
                          : Text(data['color']['dominantColorForeground'])),
                  new Text('Info',
                      style: TextStyle(fontSize: 15.0, color: Colors.red)),
                  new Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: data == null
                          ? Text("boş")
                          : Text(data['metadata']['height'].toString() +
                              " - " +
                              data['metadata']['width'].toString() +
                              " - " +
                              data['metadata']['format'])),
                ],
                scrollDirection: Axis.vertical,
              ),
            ),
          )
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.red,
              title: Center(
                child: Text("Image Analyzer"),
              )),
          body: MyHomePage())));
}
