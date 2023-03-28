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
  // Loading state to show progress bar
  bool isLoading = false;
  // Error state to show snackbar
  bool isError = false;

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

  Future<void> removeBg(File file) async {
    try {
      noBgImage = null;
      isLoading = true;
      isError = false;
      notifyListeners();
      var r = await dio?.post("https://api.remove.bg/v1.0/removebg",
          data: FormData.fromMap({
            "image_file": await MultipartFile.fromFile(file.path)
          }) );
      NoBackgroundResponse res = NoBackgroundResponse.fromJson(r?.data) ;
      noBgImage = base64Decode(res.data?.resultB64 ?? "");
      isLoading = false;
    }catch(error){
      isError = true;
      isLoading = false;
    }
    notifyListeners();
  }

  void updateImage(Uint8List uintImage){
    noBgImage = uintImage;
    notifyListeners();
  }

}