import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:removebg/auth/secrets.dart';
import 'package:removebg/no_background_response.dart';


class RemoveBg extends ChangeNotifier{

  Dio? dio;
  Uint8List? noBgImage;

  RemoveBg(){
    dio = Dio(
        BaseOptions(
            contentType: "multipart/form-data",
          headers:{
              "X-API-Key":"$API_KEY",
            "Accept":"application/json"
          }
        )
    );
  }

  Future<void> getPosts(File file) async {
   // var response = await dio?.get("https://api.remove.bg/v1.0/removebg");
    var r = await dio?.post("https://api.remove.bg/v1.0/removebg",
        data: FormData.fromMap({
          "image_file": await MultipartFile.fromFile(file.path)
        }) );
    NoBackgroundResponse res = NoBackgroundResponse.fromJson(r?.data) ;
    noBgImage = base64Decode(res.data?.resultB64 ?? "");
    // try{
    //
    //
    // }catch( error){
    //   print("error: ${error.toString()}");
    // }
    notifyListeners();
  }

  void updateImage(Uint8List uintImage){
    noBgImage = uintImage;
    notifyListeners();
  }

}