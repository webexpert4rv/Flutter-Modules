import 'package:appcode/app/chat/bloc/chat_provider.dart';
import 'package:appcode/app/chat/bloc/user_provider.dart';
import 'package:appcode/app/membership/bloc/membership_provider.dart';
import 'package:appcode/app/membership/model/purchased_plan_data_wrapper.dart';
import 'package:appcode/app/network/api_constants.dart';
import 'package:appcode/app/shared_prefrence/shared_pref.dart';
import 'package:appcode/app/sign_in/bloc/sign_in_provider.dart';
import 'package:appcode/app/sign_up/model/sign_up_model.dart';
import 'package:appcode/app/utility/current_session.dart';
import 'package:appcode/app/utility/string_utils.dart';
import 'package:appcode/app/widgets/widget_utils.dart';
import 'package:appcode/utils/app_color.dart';
import 'package:appcode/utils/app_constants.dart';
import 'package:appcode/utils/app_images.dart';
import 'package:appcode/utils/app_strings.dart';
import 'package:appcode/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'bottom_sheet_auth/bottom_sheet_forgot_password.dart';
import 'package:easy_localization/easy_localization.dart';


class SignInScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var _formKey;
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  bool isPasswordVisible = false;
  bool rememberMe = false;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  String? fcmToken;

  int loginType = 1;  // 1 : manual, 2: for social

  @override
  void initState() {
    super.initState();
    getToken();
    _formKey = GlobalKey<FormState>();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      resettingStatesChatProvider();
    });
  }

  @override
  Widget build(BuildContext context) {
    ApiConstants.context = context;

    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.color_white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
                left: 0,
                top: 0,
                right: 0,
                child: Image.asset(AppImages.icon_shape_auth)),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                AppImages.ic_shape_bottom_right,
                fit: BoxFit.fill,
                height: size.height * 0.1,
                width: size.width / 2.5,
              ),
            ),
            Consumer<SignInProvider>(
              builder: (_, provider, child) {
                if (provider.state?.signUpModel != null) {
                  WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                    if (provider.state?.signUpModel?.status ?? false) {
                      // check if user is verified and registration process is completed.
                      if (provider.state?.signUpModel?.data != null &&
                          provider.state?.signUpModel?.data?.isVideoScheduled ==
                              0) {
                        WidgetUtils.showToastMessage(
                            AppString.please_complete_registration);
                        saveUserDataAndProceedRegistrationProcess(
                            provider.state?.signUpModel, provider);
                      }else if(provider.state?.signUpModel?.data != null &&
                          provider.state?.signUpModel?.data?.isVideoScheduleCompleted ==
                              0&&provider.state?.signUpModel?.data != null &&
                          provider.state?.signUpModel?.data?.isVideoScheduleExpired ==
                              1){
                        WidgetUtils.showToastMessage(
                            AppString.please_reshdule_call);
                        saveUserDataAndProceedRegistrationProcess(
                            provider.state?.signUpModel, provider);
                      } else if (provider.state?.signUpModel?.data != null &&
                          ( provider.state?.signUpModel?.data?.approvedStatus ==
                              0 || provider.state?.signUpModel?.data?.approvedStatus == 2)) {
                        WidgetUtils.showToastMessage(
                            AppString.account_not_verified);
                        provider.state = SignInProviderState.empty();
                      } else if (provider.state?.signUpModel?.data != null) {
                        // proceed with login
                        WidgetUtils.showToastMessage(
                            provider.state?.signUpModel?.message);
                        saveUserDataAndProceedLogin(
                            provider.state?.signUpModel, provider);
                      }
                    }
                    else {
                      WidgetUtils.showToastMessage(
                          provider.state?.signUpModel?.message);
                      provider.state = SignInProviderState.empty();
                    }
                  });
                } else if (provider.state?.error != null &&
                    StringUtils.isValid(provider.state?.error?.error)) {
                  if(!(provider.state!.error!.error)!.contains("409"))
                  WidgetUtils.showToastMessage(provider.state?.error?.error);
                  provider.state = SignInProviderState.empty();
                }

                return getContent(provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  _showForgotPasswordBottomSheet({
    required BuildContext context,
  }) {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        backgroundColor: AppColor.color_white,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (context) {
          return Padding(padding: MediaQuery.of(context).viewInsets,
          child:BottomSheetForgotPassword());

        });
  }

  Widget getContent(SignInProvider provider) {
    return Positioned.fill(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: AbsorbPointer(
              absorbing: provider.state?.isLoading ?? false,
              child: Form(
                key: _formKey,
                autovalidateMode: autoValidateMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 200,
                    ),
                    Image.asset(
                      AppImages.icon_logo,
                      height: 130,
                      width: 130,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppString.sign_in.tr().toUpperCase(),
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      AppString.sign_in_to_get_started.tr(),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        autofocus: false,
                        controller: _emailController,
                        validator: (value) {
                          if (value!.trim().isEmpty)
                            return AppString.email_required.tr();
                          if (!Utils.isEmailValid(value.trim()))
                            return AppString.enter_valid_email.tr();
                          return null;
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 15),
                          labelText: AppString.email_id.tr(),
                          alignLabelWithHint: true,
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          labelStyle: Theme.of(context).textTheme.bodyText1,
                          hintStyle: Theme.of(context).textTheme.bodyText1,
                          border: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColor.divider_color_2, width: 1),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColor.divider_color_2, width: 1),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColor.divider_color_2, width: 1),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        autofocus: false,
                        controller: _passwordController,
                        validator: (value) {
                          if (value!.trim().isEmpty)
                            return AppString.password_required.tr();
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppString.password.tr(),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 15),
                          suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                            child: Image.asset(
                              AppImages.icon_eye_open,
                              height: 12,
                              width: 12,
                              color: isPasswordVisible
                                  ? AppColor.dark_colored_text
                                  : null,
                            ),
                          ),
                          alignLabelWithHint: true,
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          labelStyle: Theme.of(context).textTheme.bodyText1,
                          hintStyle: Theme.of(context).textTheme.bodyText1,
                          border: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColor.divider_color_2, width: 1),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColor.divider_color_2, width: 1),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColor.divider_color_2, width: 1),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        obscureText: !isPasswordVisible,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 20),
                      child: Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              if (value != null)
                                setState(() {
                                  rememberMe = value;
                                });
                            },
                          ),
                          Text(
                            AppString.remember_me.tr(),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          const Expanded(
                            child: const SizedBox(),
                          ),
                          TextButton(
                            onPressed: () {
                              _showForgotPasswordBottomSheet(context: context);
                            },
                            child: Text(
                              AppString.forgot_password.tr(),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            loginType = 1;
                            provider.signInManual(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                            fcmToken: fcmToken);
                            // Navigator.pushNamed(
                            //     context, AppString.CHOOSE_MEMBERSHIP_ROUTE);
                          } else {
                            autoValidateMode = AutovalidateMode.always;
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
                            AppString.sign_in.tr(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 17,
                    ),
                    Text(
                      AppString.or_you_can_join_with.tr().toUpperCase(),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18, right: 30),
                      child: Row(
                        children: [
                          Expanded(
                            child:/* Container(
                              height: 60,
                              width: MediaQuery.of(context).size.width,
                              child: Stack(children: [
                                Positioned.fill(
                                  child: Center(
                                    child: InkWell(
                                      onTap: () => Navigator.pushNamed(context, AppString.INSERT_PHONE_NUMBER_SCREEN_ROUTE),
                                      child: Container(
                                        height: 40,
                                        margin: EdgeInsets.only(left: 12),
                                        width: MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.only(left: 10),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: AppColor.divider_color,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(50),
                                          ),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 30.0),
                                            child: Text(
                                              AppString.phone_number
                                                  .toUpperCase(),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  child: Image.asset(
                                    AppImages.icon_phone,
                                    height: 65,
                                    width: 65,
                                  ),
                                ),
                              ]),
                            )*/  Container(
                              height: 60,
                              width: MediaQuery.of(context).size.width / 2.3,
                              child: InkWell(
                                onTap: () => initiateFacebookLogin(provider),
                                child: Stack(children: [
                                  Positioned.fill(
                                    child: Center(
                                      child: Container(
                                        height: 40,
                                        margin: EdgeInsets.only(left: 12),
                                        width: MediaQuery.of(context).size.width,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: AppColor.divider_color,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(50),
                                          ),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 20.0),
                                            child: Text(
                                              AppString.facebook.tr().toUpperCase(),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                              Theme.of(context).textTheme.subtitle1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    child: Image.asset(
                                      AppImages.icon_facebook,
                                      height: 65,
                                      width: 65,
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Container(
                              height: 60,
                              width: MediaQuery.of(context).size.width,
                              child: InkWell(
                                onTap: () {
                                  _handleSignIn(provider);
                                },
                                child: Stack(children: [
                                  Positioned.fill(
                                    child: Center(
                                      child: Container(
                                        height: 40,
                                        margin: EdgeInsets.only(left: 12),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: AppColor.divider_color,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(50),
                                          ),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0),
                                            child: Text(
                                              AppString.google.tr().toUpperCase(),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    child: Image.asset(
                                      AppImages.icon_google,
                                      height: 65,
                                      width: 65,
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: AppString.new_to_app,
                            style:
                            Theme.of(context).textTheme.headline4?.copyWith(
                              fontSize: 12.0,
                              decoration: TextDecoration.none,
                            ),
                            children: [
                              TextSpan(
                                  text: AppString.create_account.tr(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4
                                      ?.copyWith(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.dark_colored_text,
                                    decoration: TextDecoration.none,),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                    //  Navigator.pop(context, true);
                                      Navigator.pushNamed(
                                          context, AppString.SIGN_UP_SCREEN_ROUTE);
                                    }),
                            ])),
                    SizedBox(
                      height: 30.0,
                    )
                  ],
                ),
              ),
            ),
          ),
          if (provider.state?.isLoading ?? false) WidgetUtils.getLoader()
        ],
      ),
    );
  }

  Future<void> saveUserDataAndProceedRegistrationProcess(
      SignUpModel? signUpModel, SignInProvider provider) async {
    SharedPref sharedPref = SharedPref();

    try {
      await sharedPref.saveString(
          SharedPref.USER_DATA, signUpModelToJson(signUpModel!));
      await sharedPref.saveString(
          SharedPref.USER_TOKEN, signUpModel.data?.accessToken);
      await sharedPref.saveString(
          SharedPref.USER_PROCESS_TYPE, AppConstants.processTypeSignUp);

      await sharedPref.saveString(
          SharedPref.MATCHMAKER_NAME, signUpModel.data?.matchmakerName);

      CurrentSession().token = signUpModel.data?.accessToken;
      saveLastScreenOpened();
      provider.state = SignInProviderState.empty();

      Navigator.pushReplacementNamed(
          context, AppString.QUESTIONNAIRE_SCREEN_ROUTE,
          arguments: <String, dynamic>{
            "fromScreen": "SignIn"
          });

    } catch (error) {
      print(error);
    }
  }

  Future<void> saveUserDataAndProceedLogin(
      SignUpModel? signUpModel, SignInProvider provider) async {
    try {
      SharedPref sharedPref = SharedPref();
      // if (rememberMe || loginType == 2) {
        await sharedPref.saveString(
            SharedPref.USER_DATA, signUpModelToJson(signUpModel!));
        await sharedPref.saveString(
            SharedPref.USER_TOKEN, signUpModel.data?.accessToken);
        await sharedPref.saveString(
            SharedPref.USER_PROCESS_TYPE, AppConstants.processTypeLogin);

      await sharedPref.saveString(
          SharedPref.MATCHMAKER_NAME, signUpModel.data?.matchmakerName);
      // }
      CurrentSession().token = signUpModel.data?.accessToken;
      CurrentSession().userData = signUpModel;
      provider.state = SignInProviderState.empty();

      // check if plan is purchased
      PurchasedPlanData? membership = signUpModel.data?.membershipPlan;
      if(membership != null  && membership.isExpired == 0){
        await sharedPref.saveInt(SharedPref.processTypeLoginCompleted, 1);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppString.HOME_SCREEN_ROUTE,
              (route) => false,
        );
      }else{
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppString.CHOOSE_MEMBERSHIP_ROUTE,
              (route) => false,
          arguments: true,
        );
      }
    } catch (error) {
      print(error);
    }
  }

  void saveLastScreenOpened() {
    SharedPref()
        .saveInt(SharedPref.LAST_SCREEN, AppConstants.screenTypeQuestionnaire);
  }

  Future<void> _handleSignIn(SignInProvider provider) async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount?.authentication;
      var token = googleSignInAuthentication?.accessToken;
      if (StringUtils.isValid(token)){
        loginType = 2;
        provider.signInWithToken(
            provider: AppConstants.socialLoginTypeGoogle, accessToken: token!, fcmToken: fcmToken);
      }
    } catch (error) {
      print(error);
    }
  }

  void initiateFacebookLogin(SignInProvider provider) async {
    try{
      final LoginResult result = await FacebookAuth.instance.login(); // by default we request the email and the public profile
      // or FacebookAuth.i.login()
      if (result.status == LoginStatus.success) {
        // you are logged
        final AccessToken accessToken = result.accessToken!;
        if (StringUtils.isValid(accessToken.token)){
          loginType = 2;
          provider.signInWithToken(
              provider: AppConstants.socialLoginTypeFacebook, accessToken: accessToken.token, fcmToken: fcmToken);
        }
      }
      else{
        // debugPrint("FACEBOOK:-> ${result.status}, ${result.message}, ${result.accessToken}");
        WidgetUtils.showToastMessage(result.message);
      }
      // await FacebookAuth.instance.logOut();
    }catch(error){
      print(error);
    }
  }

  void getToken() {

    var messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){
     fcmToken = value;
    });

  }

  void resettingStatesChatProvider() {
    Provider.of<UserProvider>(context, listen: false).resetState();
    Provider.of<ChatProvider>(context, listen: false).resetState();
    Provider.of<MembershipProvider>(context, listen: false).resetState();
  }
}
