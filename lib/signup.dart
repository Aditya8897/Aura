import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Default selected country code is now +91
  String selectedCountryCode = '+91';

  // Controller for the phone number TextField
  final TextEditingController phoneController = TextEditingController();

  // Boolean to track if phone number is valid (10 digits)
  bool isPhoneValid = false;

  // Loader image list (make sure these images exist in your assets)
  final List<String> imagePaths = [
    'img1.png',
    'img2.png',
    'img3.png',
    'img4.png',
  ];
  String encryptData(String data) {
    // Convert string to bytes
    final bytes = utf8.encode(data);
    debugPrint("Bytes: $bytes");
    // Generate SHA-256 hash
    final digest = sha256.convert(bytes);
    debugPrint("digest: $digest");
    // Return the hashed value in hexadecimal format
    return digest.toString();
  }

  Future<void> sendData(BuildContext context) async {
    // Show the loader dialog while the request is being sent
    showLoaderDialog(context);

    // Encrypt the OTP before sending the request
    String otp = phoneController.text;
    String encryptedOtp = encryptData(otp);
    Map<String, String> data = {
      'otp': encryptedOtp, // Include OTP in the data
    };

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse('https://your-api-endpoint.com/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      // Check the response
      if (response.statusCode == 200) {
        print('Request successful: ${response.body}');
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } finally {
      // Dismiss the loader dialog after the request is completed
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen to phone number input for validation
    phoneController.addListener(() {
      setState(() {
        isPhoneValid = phoneController.text.length == 10;
      });
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  /// Loader function that returns a widget.
  /// It uses a StreamBuilder to update the current image index and an AnimatedSwitcher to animate:
  /// - Incoming image slides in from right and fades in.
  /// - Outgoing image slides out to left and fades out.
  /// Below the image, the text "Please Wait" is displayed (without an underline).
  Widget loaderFunction() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: StreamBuilder<int>(
            stream: Stream.periodic(
                const Duration(milliseconds: 1200), (count) => count),
            builder: (context, snapshot) {
              final index = snapshot.data ?? 0;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  imagePaths[index % imagePaths.length],
                  key: ValueKey<int>(index % imagePaths.length),
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Please Wait",
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 18,
            decoration: TextDecoration.none, // Remove underline
          ),
        ),
      ],
    );
  }

  /// Shows a dialog with the loader in the center.
  void showLoaderDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) {
        return Center(child: loaderFunction());
      },
    );
    // // Dismiss the dialog after 5 seconds
    // Future.delayed(const Duration(seconds: 5), () {
    //   if (Navigator.of(context).canPop()) {
    //     Navigator.of(context).pop();
    //     Navigator.pushNamed(context, '/SignIn');
    //   }
    // });
  }

  // Method to show Terms & Conditions in a dialog
  void showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 90, 7, 7),
          content: SingleChildScrollView(
            child: Text(
              "Terms & Conditions\n\n"
              "Welcome to LuxeJewels, your premier destination for exquisite jewelry. By using our app, you agree to the following terms:\n\n"
              "1. Product Authenticity: Every item is guaranteed authentic and crafted with precision. We take pride in offering only the best quality jewelry.\n\n"
              "2. Payment & Refunds: All payments are processed securely. All sales are final unless you meet our refund criteria outlined in our full refund policy.\n\n"
              "3. Shipping & Delivery: We ensure prompt processing of orders. Delivery times may vary depending on your location. Please refer to our shipping policy for more details.\n\n"
              "4. Privacy: Your personal data is important to us and is handled as per our Privacy Policy. We do not share your information with third parties without your consent.\n\n"
              "5. Modifications: LuxeJewels reserves the right to modify these terms at any time. Continued use of the app signifies your acceptance of the updated terms.\n\n"
              "Thank you for choosing LuxeJewels. Enjoy our exclusive collection and feel free to contact our support for any inquiries.",
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to show Privacy Policy in a dialog
  void privacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 90, 7, 7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Privacy Policy",
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              "Privacy Policy\n\n"
              "Welcome to LuxeJewels. This Privacy Policy explains how we collect, use, and safeguard your personal information when you use our app.\n\n"
              "1. Data Collection: We collect personal information that you provide to us, such as your name, email, phone number, and shipping address. Additionally, non-personal data such as device information and browsing activity may be collected to improve your experience.\n\n"
              "2. Data Usage: Your data is used to process orders, provide customer support, send notifications, and enhance our services. We ensure that your information is only used for legitimate business purposes.\n\n"
              "3. Data Sharing: We do not sell or rent your personal data. However, your information may be shared with trusted third parties who assist in operating our app and processing transactions, all under strict confidentiality agreements.\n\n"
              "4. Security: We implement industry-standard security measures to protect your data. Although no system is completely secure, we strive to maintain the highest level of protection for your personal information.\n\n"
              "5. Policy Updates: LuxeJewels may update this Privacy Policy periodically. Your continued use of our app signifies your acceptance of any changes made to this policy.\n\n"
              "If you have any questions regarding our Privacy Policy, please contact our support team.",
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double appBarHeight = screenHeight / 3;

    // Clipped image for the AppBar
    final Widget clippedImage = ClipPath(
      clipper: CustomClipperPath(),
      child: Image.asset(
        'clipperImage.jpg', // Ensure this asset is declared in pubspec.yaml
        fit: BoxFit.cover,
        height: appBarHeight,
        width: double.infinity,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: appBarHeight,
        flexibleSpace: Stack(
          children: [
            clippedImage,
            Positioned(
              bottom: appBarHeight * 0.3,
              left: 16,
              child: Text(
                'AURA',
                style: GoogleFonts.playfairDisplay(
                  fontSize: appBarHeight * 0.25,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // Remove SingleChildScrollView so the body adjusts dynamically.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.03),
              Text(
                'Login / Sign Up',
                style: GoogleFonts.playfairDisplay(
                  fontSize: screenHeight * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              const Text(
                'Enter mobile number for OTP',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment
                      .end, // Align both underlines at the bottom
                  children: [
                    // Country code with an underline
                    Container(
                      padding: const EdgeInsets.only(
                          bottom: 8), // Adjust as needed for vertical alignment
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      child: CountryCodePicker(
                        onChanged: (countryCode) {
                          setState(() {
                            selectedCountryCode = countryCode.dialCode!;
                          });
                        },
                        initialSelection: selectedCountryCode,
                        favorite: const ['+91', '+1', '+44'],
                        showFlag: false,
                        showFlagDialog: false,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Phone number TextField with an underline
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          contentPadding: EdgeInsets.only(
                              bottom: 8), // Adjust to align with country code
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Use a Spacer to push the remaining content to the bottom
              const Spacer(),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'By Continuing, I agree to ',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms of Use',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 90, 7, 7),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showTermsAndConditions(context);
                          },
                      ),
                      const TextSpan(text: ' & '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 90, 7, 7),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            privacyPolicy(context);
                          },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: ElevatedButton(
                  onPressed: isPhoneValid
                      ? () {
                          sendData(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 90, 7, 7),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.1,
                      vertical: screenHeight * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Request OTP',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: screenHeight * 0.028,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom clipper for the AppBar image curve.
class CustomClipperPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
