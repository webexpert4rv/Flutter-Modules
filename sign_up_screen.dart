import 'package:appcode/app/questionnaire/bloc/questionnaire_provider.dart';
import 'package:appcode/app/shared_prefrence/shared_pref.dart';
import 'package:appcode/app/sign_up/bloc/sign_up_provider.dart';
import 'package:appcode/app/sign_up/model/sign_up_model.dart';
import 'package:appcode/app/utility/current_session.dart';
import 'package:appcode/app/widgets/widget_utils.dart';
import 'package:appcode/utils/app_color.dart';
import 'package:appcode/utils/app_constants.dart';
import 'package:appcode/utils/app_images.dart';
import 'package:appcode/utils/app_strings.dart';
import 'package:appcode/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isConfirmPasswordVisible = false;
  bool isPasswordVisible = false;

  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  var phoneNumber = PhoneNumber(isoCode: 'US');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Provider.of<QuestionnaireProvider>(context, listen: false).resetProviderState();
    });
    }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.color_white,
      body: SafeArea(
        child: Consumer<SignUpProvider>(
          builder: (_, provider, child) {
            if (provider.state?.signUpModel != null) {
              WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                if (provider.state?.signUpModel!.status != null) {
                  var status = provider.state?.signUpModel!.status ?? false;
                  showToastMessage(provider.state?.signUpModel!.message);
                  if (status) {
                    saveUserSignUpData(provider.state?.signUpModel, provider);
                  }else{
                    provider.state = SignUpProviderState.empty();
                  }
                }
              });
            }
            return getContent(
                context, size, provider.state?.isLoading, provider);
          },
        ),
      ),
    );
  }

  Widget getContent(BuildContext context, Size size, bool? isLoading,
      SignUpProvider? provider) {
    final node = FocusScope.of(context);
    return Stack(
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
            height: size.height * 0.2,
            width: size.width / 2,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 100, top: 40.0),
          child: AbsorbPointer(
            absorbing: isLoading != null && isLoading,
            child: ListView(
              shrinkWrap: true,
              children: [
                Form(
                  key: _formKey,
                  autovalidateMode: autoValidateMode,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 150,
                        ),
                        Image.asset(
                          AppImages.icon_logo,
                          height: 150,
                          width: 150,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          AppString.create_account.tr().toUpperCase(),
                          style: Theme.of(context).textTheme.headline1,
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          AppString.sign_up_to_get_started.tr(),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                autofocus: false,
                                controller: _firstNameController,
                                validator: (value) {
                                  if (value!.trim().isEmpty)
                                    return AppString.first_name_required.tr();
                                  return null;
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 15),
                                  labelText: AppString.first_name.tr(),
                                  alignLabelWithHint: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  labelStyle:
                                      Theme.of(context).textTheme.bodyText1,
                                  hintStyle:
                                      Theme.of(context).textTheme.bodyText1,
                                  border: const OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColor.divider_color_2,
                                        width: 1),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColor.divider_color_2,
                                        width: 1),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColor.divider_color_2,
                                        width: 1),
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextFormField(
                                autofocus: false,
                                controller: _lastNameController,
                                validator: (value) {
                                  if (value!.trim().isEmpty)
                                    return AppString.last_name_required.tr();
                                  return null;
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 15),
                                  labelText: AppString.last_name.tr(),
                                  alignLabelWithHint: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  labelStyle:
                                      Theme.of(context).textTheme.bodyText1,
                                  hintStyle:
                                      Theme.of(context).textTheme.bodyText1,
                                  border: const OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColor.divider_color_2,
                                        width: 1),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColor.divider_color_2,
                                        width: 1),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColor.divider_color_2,
                                        width: 1),
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
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
                            labelText: AppString.email.tr(),
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
                          onEditingComplete: () => node.nextFocus(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            phoneNumber = number;
                          },
                          onInputValidated: (bool value) {
                            print(value);
                          },
                          inputDecoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 15),
                            labelText: AppString.enter_mobile_number,
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
                          errorMessage: AppString.mobile_number_valid,
                          ignoreBlank: true,
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          initialValue: phoneNumber,
                          textFieldController: _phoneNumberController,
                          inputBorder: OutlineInputBorder(),
                          searchBoxDecoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 15),
                            alignLabelWithHint: true,
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            hintStyle: Theme.of(context).textTheme.bodyText1,
                            hintText: AppString.phone_code_search_hint_text,
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
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.DIALOG,
                            //trailingSpace: false,
                            leadingPadding: 10.0,
                            setSelectorButtonAsPrefixIcon: true,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          autofocus: false,
                          controller: _passwordController,
                          validator: (value) {
                            if (value!.trim().isEmpty)
                              return AppString.password_required.tr();
                            if (!Utils.validateStructure(value.trim()))
                              return AppString.valid_password_required.tr();
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: AppString.password.tr(),
                            errorMaxLines: 3,
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
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => node.nextFocus(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          autofocus: false,
                          controller: _confirmPasswordController,
                          validator: (value) {
                            if (value!.trim().isEmpty)
                              return AppString.confirm_password_required.tr();
                            if (!Utils.validateStructure(value.trim()))
                              return AppString.valid_confirm_password_required.tr();
                            if (value.trim() != _passwordController.text.trim())
                              return AppString.password_match_error.tr();
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: AppString.confirm_password.tr(),
                            errorMaxLines: 3,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 15),
                            suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  isConfirmPasswordVisible =
                                      !isConfirmPasswordVisible;
                                });
                              },
                              child: Image.asset(
                                AppImages.icon_eye_open,
                                height: 12,
                                width: 12,
                                color: isConfirmPasswordVisible
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
                          obscureText: !isConfirmPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => node.unfocus(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 40, left: 30, right: 30.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  var number = await getPhoneNumber() ?? '';
                  if (number.isNotEmpty) {
                    provider?.signUp(
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                        phoneNumber: phoneNumber.phoneNumber!,
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                        passwordConfirmation:
                            _confirmPasswordController.text.trim());
                  }else{
                    WidgetUtils.showToastMessage(AppString.mobile_number_required);
                  }
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
                  AppString.sign_up.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ),
          ),
        ),
        if (isLoading != null && isLoading) WidgetUtils.getLoader()
      ],
    );
  }

  Future<String?> getPhoneNumber() async {
    try{
      String parsableNumber = await PhoneNumber.getParsableNumber(phoneNumber);
      // return await PhoneNumber.getParsableNumber(phoneNumber);
      return parsableNumber;
    }catch(e){
      return '';
    }
  }



  Future<void> saveUserSignUpData(SignUpModel? signUpModel, SignUpProvider provider) async {
    SharedPref sharedPref = new SharedPref();
    try {
      await sharedPref.saveString(
          SharedPref.USER_DATA, signUpModelToJson(signUpModel!));
      await sharedPref.saveString(
          SharedPref.USER_TOKEN, signUpModel.data?.accessToken);
      await sharedPref.saveString(
          SharedPref.USER_PROCESS_TYPE, AppConstants.processTypeSignUp);
      CurrentSession().token = signUpModel.data?.accessToken;
      saveLastScreenOpened();
      provider.state = SignUpProviderState.empty();

      resetQuestionnaireProviderState();
      Navigator.pushReplacementNamed(
          context, AppString.QUESTIONNAIRE_SCREEN_ROUTE,
          arguments: <String, dynamic>{
            "fromScreen": "SignUp"
          });
    } catch (error) {
      print(error);
      print("userdata Not Saved");
    }
  }

  void saveLastScreenOpened() {
    SharedPref()
        .saveInt(SharedPref.LAST_SCREEN, AppConstants.screenTypeQuestionnaire);
  }

  void showToastMessage(String? message) {
    WidgetUtils.showToastMessage(message);
  }

  void resetQuestionnaireProviderState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Provider.of<QuestionnaireProvider>(context,  listen: false).resetProviderState();
    });
  }
}


