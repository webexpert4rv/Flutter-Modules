import 'package:appcode/app/network/api_constants.dart';
import 'package:appcode/app/notification/bloc/notification_provider.dart';
import 'package:appcode/app/notification/bloc/unread_notification_provider.dart';
import 'package:appcode/app/notification/models/notification_data_wrapper.dart';
import 'package:appcode/app/utility/string_utils.dart';
import 'package:appcode/app/widgets/widget_utils.dart';
import 'package:appcode/utils/app_color.dart';
import 'package:appcode/utils/app_constants.dart';
import 'package:appcode/utils/app_images.dart';
import 'package:appcode/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:easy_localization/easy_localization.dart';


class NotificationScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotificationScreenState();
  }
}

class NotificationScreenState extends State<NotificationScreen> {
  bool isNotificationRead = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      context.read<NotificationProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Consumer<NotificationProvider>(
          builder: (_, provider, child) {
            return getContent(size, context, provider);
          },
        ),
      ),
    );
  }

  Widget notificationWidget(int index, NotificationData? data) => Card(
        margin: EdgeInsets.only(bottom: 20.0, right: 5.0, left: 5.0, top: 10.0),
        elevation: AppConstants.CARD_ELEVATION,
        color: AppColor.color_white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.CARD_RADIUS),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 4.0,
              ),
              Row(
                children: [
                  Transform.scale(
                      scale: 0.8,
                      child: StringUtils.isValid(data?.senderProfileImage)
                          ? WidgetUtils.userImageWidgetNotification(
                              ApiConstants.BASE +
                                  (data?.senderProfileImage ?? ''))
                          : WidgetUtils.userWidgetNotification()),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                      child: Text(
                    data?.message ?? '',
                    style: Theme.of(context).textTheme.subtitle1,
                  ))
                ],
              ),
              SizedBox(
                height: 4.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (data?.isRead == 0)
                    Text(
                      'New',
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          ?.copyWith(fontSize: 12.0),
                    ),
                  if (data?.isRead == 0)
                    Text(
                      " / ",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(fontSize: 12.0),
                    ),
                  Text(
                    getTimeAgo(data?.createdAt),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(fontSize: 12.0),
                  )
                ],
              )
            ],
          ),
        ),
      );

  Widget getContent(
      Size size, BuildContext context, NotificationProvider provider) {
    List<NotificationData?>? data = [];
    bool isLoading = provider.state?.isLoading ?? false;

    if (provider.state?.notificationDataWrapper != null) {
      data = provider.state?.notificationDataWrapper?.data ?? [];

      if(data.isNotEmpty){
        if(!isNotificationRead){
          markNotificationAsRead(data, provider, context);
        }
      }
    }

    return Stack(
      alignment: Alignment.topCenter,
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
        Align(
          alignment: Alignment.topRight,
          child: Image.asset(
            AppImages.ic_payment_background,
            fit: BoxFit.fill,
            height: size.height * 0.12,
            width: size.width / 2.8,
            color: AppColor.light_grey_F1,
          ),
        ),
        data.length > 0
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 35,
                    ),
                    Text(
                      AppString.notification.tr().toUpperCase(),
                      style: Theme.of(context).textTheme.headline2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 5.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: AbsorbPointer(
                          absorbing: isLoading,
                          child: InkWell(
                            onTap: () {
                              provider.clearAll();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.CARD_RADIUS),
                                  color: AppColor.dark_colored_text),
                              padding: EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 12.0),
                              child: Text(
                                AppString.clear_all.tr(),
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
                    ),
                    SizedBox(
                      height: 7.0,
                    ),
                    Expanded(
                        child: ListView.builder(
                      itemBuilder: (context, index) {
                        return notificationWidget(index, data![index]);
                      },
                      itemCount: data.length,
                    ))
                  ],
                ),
              )
            : isLoading ? Container() : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.ic_no_notification_found,
                    height: size.height / 5,
                    width: size.width / 3,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    AppString.no_notification_yet.tr().toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .headline2
                        ?.copyWith(fontSize: 24.0),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
        if (isLoading) WidgetUtils.getLoader(),
      ],
    );
  }

  String getTimeAgo(DateTime? createdAt) {
    var time = '';
    if (createdAt != null) time = timeago.format(createdAt, locale: 'en_short');
    if(StringUtils.isValid(time)){
      return time + " " + AppString.ago;
    }
    return time;
  }

  void markNotificationAsRead(List<NotificationData?>? data, NotificationProvider provider, BuildContext context) {
    List<int> ids = [];
    isNotificationRead = true;
    var nonReadList = data?.where((element) => element?.isRead == 0);
    if(nonReadList != null && nonReadList.isNotEmpty){
      nonReadList.toList().forEach((element) {
        ids.add(element!.id!);
      });
    }
    if(ids.isNotEmpty){
      provider.markRead(ids).then((value) {
        resetCount(context);
      });
    }
  }

  void resetCount(BuildContext context) {
    Provider.of<UnreadNotificationProvider>(context, listen: false).getUnReadNotificationCount();
  }
}
