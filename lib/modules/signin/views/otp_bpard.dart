import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/core/values/app_colors.dart';
import 'package:mhdcooperation/core/values/app_strings.dart';
import 'package:mhdcooperation/routes/app_routes.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OtpBoard extends StatefulWidget {
  const OtpBoard({super.key});

  @override
  State<OtpBoard> createState() => _OtpBoardState();
}

class _OtpBoardState extends State<OtpBoard>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  String? phoneNumber;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/ll.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.65,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 77),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    // Icône téléphone
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (_animationController.value * 0.2),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Icon(
                              Icons.phone_in_talk_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24),
                    // Titre principal avec dégradé
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        AppStrings.otpTitle,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Sous-titre
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        AppStrings.otpSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 32),
                    OtpTextField(
                      numberOfFields: 5,
                      borderColor: AppColors.primary,
                      //set to true to show as box or false to show as dash

                      //runs when a code is typed in
                      onCodeChanged: (String code) {
                        phoneNumber = code;
                        //handle validation or checks here
                      },
                      //runs when every textfield is filled
                      onSubmit: (String verificationCode) {
                        // showDialog(
                        //   context: context,
                        //   builder: (context) {
                        //     return AlertDialog(
                        //       title: Text("Verification Code"),
                        //       content: Text(
                        //         'Code entered is $verificationCode',
                        //       ),
                        //     );
                        //   },
                        // );
                      }, // end onSubmit
                    ),
                    // Champ téléphone
                    SizedBox(height: 28),
                    // Bouton d'authentification
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: phoneNumber != null
                              ? () {
                                  Get.offAllNamed(AppRoutes.home);
                                  // TODO: Ajouter la logique de connexion
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            AppStrings.otpVerify,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Bouton renvoyer le code
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement resend OTP logic
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppStrings.otpResend,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Texte d'aide
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Besoin d'aide ? ",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Navigate to help/contact page
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Contactez-nous",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
