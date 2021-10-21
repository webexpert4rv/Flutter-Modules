import 'dart:io';
import 'package:appcode/app/network/api_constants.dart';
import 'package:appcode/app/picture_upload/bloc/picture_provider.dart';
import 'package:appcode/app/picture_upload/model/picture_upload_response.dart';
import 'package:appcode/app/shared_prefrence/shared_pref.dart';
import 'package:appcode/app/widgets/photo_picker_dialog.dart';
import 'package:appcode/app/widgets/widget_utils.dart';
import 'package:appcode/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../utils/app_color.dart';
import '../../utils/app_images.dart';
import '../../utils/app_strings.dart';

class PictureUploadScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return PictureUploadScreenState();
  }
}

class PictureUploadScreenState extends State<PictureUploadScreen> {


  File? _imageFileOne;
  File? _imageFileTwo;
  File? _imageFileThree;

  SharedPref sharedPref = SharedPref();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Consumer<PictureProvider>(builder: (_, provider, child) {
          if(provider.state?.pictureUploadResponse != null){
            WidgetUtils.showToastMessage(provider.state?.pictureUploadResponse?.message);
            if(provider.state?.pictureUploadResponse?.status == true){
              WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                provider.state =  provider.state?.copyWith(pictureUploadResponse: null);
                setState(() {
                  _imageFileOne = null;
                  _imageFileTwo = null;
                  _imageFileThree = null;
                });
                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                  moveToNextScreen();
                });
              });
            }
          }
          if(provider.state?.error != null){
            WidgetUtils.showToastMessage(provider.state?.error?.error);
            provider.state = provider.state?.copyWith(error: null);
          }
          return getContent(size, context, provider);
        },),
      ),
    );
  }

  void captureImage(int imageNumber) {
    showDialog(context: context, builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.CARD_RADIUS)), //
      child: PhotoPickerDialog(cameraCallback: (){
        Navigator.pop(context);
        getImageFromCamera(imageNumber);
      },
      galleyCallback: (){
        Navigator.pop(context);
        getImageFromGallery(imageNumber);
      },),
    ));
  }

  Future getImageFromCamera(int imageNumber) async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);
    if(image != null){
      _cropImage(image.path, imageNumber);
    }
  }

  Future getImageFromGallery(int imageNumber) async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    if(image != null){
      _cropImage(image.path, imageNumber);
    }
  }

  _cropImage(filePath, int imageNumber) async {
    File? croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
      maxWidth: 1080,
      maxHeight: 1080,
      compressFormat: ImageCompressFormat.png,
    );
    if (croppedImage != null) {
      setState(() {
        switch(imageNumber){
          case 1:
            _imageFileOne = croppedImage;
            break;
            case 2:
              _imageFileTwo = croppedImage;
              break;
            case 3:
              _imageFileThree = croppedImage;
              break;
        }
       setState(() {

       });
      });
    }
  }

  Widget getContent(Size size, BuildContext context, PictureProvider provider) {

    var isLoading = provider.state?.isLoading ?? false;
    String? imageUrlOne = "";
    String? imageUrlTwo = "";
    String? imageUrlThree = "";

    PictureData? data1;
    PictureData? data2;
    PictureData? data3;
    
    if(provider.state?.pictureFetchResponse != null && provider.state?.pictureFetchResponse?.data != null){
      var dataLength = provider.state?.pictureFetchResponse?.data!.length ?? 0;

      if(dataLength > 2){
        data1 = provider.state?.pictureFetchResponse?.data![0] ?? null;
        imageUrlOne = ApiConstants.BASE + (data1?.imagePath ?? '') + "/" + (data1?.image ?? '');

        data2 = provider.state?.pictureFetchResponse?.data![1] ?? null;
        imageUrlTwo = ApiConstants.BASE + (data2?.imagePath ?? '') + "/" + (data2?.image ?? '');

        data3 = provider.state?.pictureFetchResponse?.data![2] ?? null;
        imageUrlThree = ApiConstants.BASE + (data3?.imagePath ?? '') + "/" + (data3?.image ?? '');
      }

    }


    return Stack(
      children: [
        Image.asset(
          AppImages.background_pictures_upload,
          fit: BoxFit.fill,
          height: size.height,
          width: size.width,
        ),
        AbsorbPointer(
          absorbing: isLoading,
          child: Padding(
            padding: EdgeInsets.only(bottom: 60.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          color: AppColor.color_white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.BACK_ARROW_RADIUS),
                          ),
                          elevation: AppConstants.BACK_ARROW_ELEVATION,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
                            child: Icon(Icons.arrow_back_ios_sharp, size: 20.0,),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        children: [
                          Text(
                            AppString.pictures_uploading.tr().toUpperCase(),
                            style: Theme.of(context).textTheme.headline2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            AppString.please_upload_your_three_pictures.tr(),
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                color: AppColor.dark_text,
                                fontSize: 12.0
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: size.height * 0.45,
                            child:  Card(
                              color: AppColor.color_white,
                              elevation: AppConstants.CARD_ELEVATION,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.CARD_RADIUS)
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: _imageFileOne != null ? Image.file(_imageFileOne!) : imageUrlOne.isValid() ? Image.network(imageUrlOne) : Image.asset(AppImages.image_placeholder, height: 80.0, width: 80.0,),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => captureImage(1),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        margin: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColor.colored_back_button
                                        ),
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.camera_alt, color: AppColor.color_white, size: 20.0,),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            AppString.profile_picture.tr(),
                            style: Theme.of(context).textTheme.headline2?.copyWith(
                                color: AppColor.dark_text,
                                fontSize: 16.0,

                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: size.height * 0.2,
                                width: (size.width - 60) * 0.45,
                                child:  Card(
                                  color: AppColor.color_white,
                                  elevation: AppConstants.CARD_ELEVATION,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.CARD_RADIUS)
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: _imageFileTwo != null ? Image.file(_imageFileTwo!) : imageUrlTwo.isValid() ? Image.network(imageUrlTwo) : Image.asset(AppImages.image_placeholder, height: 30.0, width: 30.0,),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => captureImage(2),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            margin: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColor.colored_back_button
                                            ),
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(Icons.camera_alt, color: AppColor.color_white, size: 14.0,),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                height: size.height * 0.2,
                                width: (size.width - 60) * 0.45,
                                child:  Card(
                                  color: AppColor.color_white,
                                  elevation: AppConstants.CARD_ELEVATION,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.CARD_RADIUS)
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child:  _imageFileThree != null ? Image.file(_imageFileThree!) : imageUrlThree.isValid() ? Image.network(imageUrlThree) : Image.asset(AppImages.image_placeholder, height: 30.0, width: 30.0,),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => captureImage(3),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            margin: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColor.colored_back_button
                                            ),
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(Icons.camera_alt, color: AppColor.color_white, size: 14.0,),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),

                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AbsorbPointer(
            absorbing: isLoading,
            child: Container(
              margin: const EdgeInsets.only(bottom: 30, right: 30.0, left: 30.0),
              child: ElevatedButton(
                onPressed: () {
                  if(_imageFileOne == null && _imageFileTwo == null && _imageFileThree == null){
                    if(imageUrlOne.isValid() && imageUrlTwo.isValid() && imageUrlThree.isValid()){
                      moveToNextScreen();
                    }else{
                      WidgetUtils.showToastMessage(AppString.allPicturesAreRequired);
                    }
                  }else{
                    if(data1 == null || data2 == null || data3 == null){
                      if(_imageFileOne == null || _imageFileTwo == null || _imageFileThree == null){
                        WidgetUtils.showToastMessage(AppString.allPicturesAreRequired);
                      }else{
                        provider.uploadPictures(_imageFileOne, _imageFileTwo, _imageFileThree, data1: data1, data2: data2, data3: data3,);
                      }
                    }else{
                      provider.uploadPictures(_imageFileOne, _imageFileTwo, _imageFileThree, data1: data1, data2: data2, data3: data3,);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10),
                  primary: AppColor.colored_back_button,
                  shape: const RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(50),
                    ),
                  ),
                  elevation: 3,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    AppString.upload.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ),
            ),
          ),
        ),
        if(isLoading) WidgetUtils.getLoader(),
      ],
    );
  }

  void fetchData() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      Provider.of<PictureProvider>(context, listen: false)
          .getPictures();
      var type = await sharedPref.readInt(SharedPref.LAST_SCREEN);
      if(type != null && type > AppConstants.screenTypeUpload){
        Navigator.pushNamed(
            context, AppString.CHOOSE_MATCHMAKER_SCREEN_ROUTE).then((value) {
          saveLastScreenOpened(AppConstants.screenTypeUpload);
        });
      }
    });
  }

  void saveLastScreenOpened(int screenTypeQuestionnaire) {
    sharedPref.saveInt(
        SharedPref.LAST_SCREEN, screenTypeQuestionnaire);
  }

  void moveToNextScreen() {
    saveLastScreenOpened(AppConstants.screenTypeChooseMatchMaker);
    Navigator.pushNamed(
        context, AppString.CHOOSE_MATCHMAKER_SCREEN_ROUTE).then((value) {
      saveLastScreenOpened(AppConstants.screenTypeUpload);
    });
  }

}