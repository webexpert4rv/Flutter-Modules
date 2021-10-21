import 'package:appcode/app/call/outgoing_call/outgoing_call.dart';
import 'package:appcode/app/match/bloc/match_provider.dart';
import 'package:appcode/app/match/bottom_sheet_all_matches.dart';
import 'package:appcode/app/match/models/match_data_wrapper.dart';
import 'package:appcode/app/network/api_constants.dart';
import 'package:appcode/app/picture_upload/model/picture_upload_response.dart';
import 'package:appcode/app/profile/bloc/profile_provider.dart';
import 'package:appcode/app/shared_prefrence/shared_pref.dart';
import 'package:appcode/app/utility/string_utils.dart';
import 'package:appcode/app/widgets/widget_utils.dart';
import 'package:appcode/utils/app_color.dart';
import 'package:appcode/utils/app_constants.dart';
import 'package:appcode/utils/app_images.dart';
import 'package:appcode/utils/app_strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class MatchScreen extends StatefulWidget {
  final ValueChanged<int?> openChatScreenCallback;

  MatchScreen({Key? key, required this.openChatScreenCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MatchScreenState();
  }
}

class MatchScreenState extends State<MatchScreen> {
  SharedPref sharedPref = SharedPref();
  MatchData? selectedUser;
  String? slug;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      context.read<MatchProvider>().fetch();
    });
    fetchSlug();
  }

  void fetchSlug() async {
    slug = await sharedPref.readString(SharedPref.selectedPlanSlug);
    print("slug11::" + slug!);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Consumer<MatchProvider>(
          builder: (_, provider, child) {
            return getContent(size, provider);
          },
        ),
      ),
    );
  }

  void showAllMatchesBottomSheet(
      List<MatchData?>? userList, MatchProvider provider) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        elevation: 5,
        backgroundColor: AppColor.color_white,
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        builder: (context) {
          return BottomSheetOnAllMatches(userList ?? []);
        }).then((value) {
      if (value != null && value as bool) {
        provider.refresh();
      }
    });
  }

  Widget getContent(Size size, MatchProvider provider) {
    List<MatchData?>? userList = [];

    var userImage = getUserImage(context);

    bool isLoading = provider.state?.isLoading ?? false;

    if (provider.state?.matchDataWrapper != null &&
        provider.state?.matchDataWrapper?.data != null) {
      userList = provider.state?.matchDataWrapper?.data;
      var data =
          userList?.firstWhereOrNull((element) => element?.isSelected ?? false);
      if (data != null) {
        selectedUser = data;
      } else {
        if (userList?.isNotEmpty ?? false) {
          selectedUser = userList![0];
          selectedUser?.isSelected = true;
        }
      }
    }

    return Stack(
      children: [
        Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.color_white,
              AppColor.gray_back_button,
            ],
          )),
        ),
        Image.asset(
          AppImages.image_match_screen_top,
          fit: BoxFit.fill,
          height: size.height * 0.22,
          width: size.width,
        ),
        ListView(
          shrinkWrap: true,
          children: [
            Stack(
              children: [
                Container(
                  height: size.height * 0.5,
                  margin: EdgeInsets.only(
                      left: 30.0, right: 30.0, top: size.height * 0.16),
                  child: Stack(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: size.height * 0.35,
                            width: size.width * 0.45,
                            child: Card(
                              margin: EdgeInsets.only(
                                  bottom: 20.0,
                                  right: 5.0,
                                  left: 5.0,
                                  top: 10.0),
                              elevation: AppConstants.CARD_ELEVATION,
                              color: AppColor.color_white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.CARD_RADIUS),
                              ),
                              child: Center(
                                  child: (selectedUser != null &&
                                          StringUtils.isValid(
                                              selectedUser!.profileImage))
                                      ? CachedNetworkImage(
                                          imageUrl: ApiConstants.BASE +
                                              selectedUser!.profileImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          AppImages.image_placeholder,
                                          height: 50.0,
                                          width: 50.0,
                                        )),
                            ),
                          ),
                          Positioned(
                            right: 0.0,
                            top: 0.0,
                            child: Card(
                                margin: EdgeInsets.zero,
                                elevation: AppConstants.BACK_ARROW_ELEVATION,
                                shape: CircleBorder(),
                                child: Image.asset(
                                  AppImages.ic_single_heart,
                                  height: 40.0,
                                  width: 40.0,
                                )),
                          )
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Stack(
                          children: [
                            Container(
                              height: size.height * 0.35,
                              width: size.width * 0.45,
                              child: Card(
                                margin: EdgeInsets.only(
                                    bottom: 20.0,
                                    right: 5.0,
                                    left: 5.0,
                                    top: 10.0),
                                elevation: AppConstants.CARD_ELEVATION,
                                color: AppColor.color_white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.CARD_RADIUS),
                                ),
                                child: Center(
                                    child: selectedUser != null &&
                                            StringUtils.isValid(userImage)
                                        ? CachedNetworkImage(
                                            imageUrl: userImage,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            AppImages.image_placeholder,
                                            height: 50.0,
                                            width: 50.0,
                                          )),
                              ),
                            ),
                            Positioned(
                              right: 16.0,
                              bottom: 0.0,
                              child: Card(
                                  margin: EdgeInsets.zero,
                                  elevation: AppConstants.BACK_ARROW_ELEVATION,
                                  shape: CircleBorder(),
                                  child: Image.asset(
                                    AppImages.ic_single_heart,
                                    height: 50.0,
                                    width: 50.0,
                                  )),
                            )
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Card(
                            margin: EdgeInsets.zero,
                            elevation: AppConstants.BACK_ARROW_ELEVATION,
                            shape: CircleBorder(),
                            child: Image.asset(
                              AppImages.ic_double_heart,
                              height: 60.0,
                              width: 60.0,
                            )),
                      ),
                      Positioned(
                        left: size.width * 0.15,
                        bottom: size.height * 0.07,
                        child: Card(
                            margin: EdgeInsets.zero,
                            elevation: AppConstants.BACK_ARROW_ELEVATION,
                            shape: CircleBorder(),
                            child: Image.asset(
                              AppImages.ic_single_heart,
                              height: 50.0,
                              width: 50.0,
                            )),
                      ),
                      Positioned(
                          right: size.width * 0.12,
                          top: size.height * 0.12,
                          child: Image.asset(
                            AppImages.ic_transparent_single_heart,
                            height: 10.0,
                            width: 10.0,
                          )),
                    ],
                  ),
                ),
                Positioned(
                    left: size.width * 0.15,
                    top: size.height * 0.13,
                    child: Image.asset(
                      AppImages.ic_transparent_single_heart,
                      height: 10.0,
                      width: 10.0,
                    )),
              ],
            ),
            SizedBox(height: 4.0),
            Text(
              AppString.its_a_match.tr().toUpperCase(),
              style: Theme.of(context).textTheme.headline2,
              textAlign: TextAlign.center,
            ),
            if (selectedUser != null) SizedBox(height: 2.0),
            if (selectedUser != null)
              Text(
                "${AppString.you_and} ${selectedUser!.getName()} ${AppString.like_each_other}",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontSize: 12.0),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 8.0),
            Align(
              alignment: Alignment.center,
              child: AbsorbPointer(
                absorbing: isLoading,
                child: InkWell(
                  onTap: () {
                    showAllMatchesBottomSheet(userList, provider);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            AppConstants.BACK_ARROW_RADIUS),
                        color: AppColor.dark_colored_text),
                    padding:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Text(
                      AppString.see_all_matches.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          ?.copyWith(fontSize: 12.0),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.0),
            //TODO add chat and call Button here
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getIconWidget(AppImages.ic_chat_rounded, () {
                  if (selectedUser != null) {
                    widget.openChatScreenCallback(selectedUser!.id);
                  }
                }),
                SizedBox(
                  width: 12.0,
                ),
                getIconWidget(AppImages.ic_call_rounded, () {
                  if (selectedUser != null) {
                    if (slug == "relationship") {
                      var route = new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new OutgoingCallScreen(
                          id: selectedUser!.id,
                          name: selectedUser!.getName(),
                          userImage: selectedUser!.profileImage,
                        ),
                      );
                      Navigator.of(context).push(route);
                    } else {
                      WidgetUtils.showToastMessage("Upgrade your plan!");
                    }
                  }
                }),
              ],
            ),
            SizedBox(
              height: 30.0,
            ),
          ],
        ),
        if (isLoading) WidgetUtils.getLoader()
      ],
    );
  }

  String getUserImage(BuildContext context) {
    var imageUrl = '';
    PictureData? data1;
    var provider = Provider.of<ProfileProvider>(context);
    if (provider.state?.pictureFetchResponse != null &&
        (provider.state?.pictureFetchResponse?.data?.isNotEmpty ?? false)) {
      data1 = provider.state!.pictureFetchResponse!.data![0]!.userImages
          ?.firstWhereOrNull(
              (element) => element?.imageType == AppConstants.imageTypeProfile);

      if (provider.state?.pictureUploadResponse != null) {
        if ((provider.state?.pictureUploadResponse?.status ?? false) &&
            provider.state?.pictureUploadResponse?.data != null) {
          if (provider.state?.pictureUploadResponse?.data?.isNotEmpty ??
              false) {
            data1 = provider.state?.pictureUploadResponse?.data![0];
          }
        }
      }
      if (StringUtils.isValid(data1?.image)) {
        imageUrl = ApiConstants.BASE +
            (data1?.imagePath ?? '') +
            "/" +
            (data1?.image ?? '');
      }
    }

    return imageUrl;
  }

  getIconWidget(String imagePath, VoidCallback callback) => Container(
        height: 50.0,
        width: 50.0,
        child: Card(
            shape: CircleBorder(),
            elevation: AppConstants.CARD_ELEVATION,
            margin: EdgeInsets.zero,
            child: IconButton(
                padding: EdgeInsets.zero,
                icon: Image.asset(
                  imagePath,
                  height: 50.0,
                  width: 50.0,
                ),
                onPressed: callback)),
      );
}
