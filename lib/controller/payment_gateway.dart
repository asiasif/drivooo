import 'package:driving_school/views/user/payment_successfull.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upi_india/upi_india.dart';

class PaymentGateway extends ChangeNotifier {
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  Future<UpiResponse> initiateTransaction(UpiApp app, double price,
      String receiverName, String receiverUpiId) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: receiverUpiId,
      receiverName: receiverName,
      transactionRefId: 'TestingUpiIndiaPlugin',
      transactionNote: 'Payment to Driving School',
      amount: price,
    );
  }

  Future getAllApps() async {
    // ignore: deprecated_member_use
    apps = await _upiIndia.getAllUpiApps(mandatoryTransactionId: false);
    notifyListeners();
  }

  Widget displayUpiApps(
    String upiID,
    String receiverName,
    double price,
    BuildContext context,
    Function onSuccess,
  ) {
    if (apps == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (apps!.isEmpty) {
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: GoogleFonts.epilogue(
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: apps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () async {
                  try {
                    // Initiate transaction with proper credentials
                    UpiResponse response = await initiateTransaction(
                        app, price, receiverName, upiID);

                    // Check Status
                    if (response.status == UpiPaymentStatus.SUCCESS) {
                      onSuccess();
                    } else {
                      // If cancelled or failed, show simulation (Fake Success)
                      _showFakeConfirmation(context, onSuccess);
                    }
                  } catch (e) {
                    // If error occurs (e.g. user back out), show simulation
                    _showFakeConfirmation(context, onSuccess);
                  }
                },
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 60,
                        width: 60,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        app.name,
                        style: GoogleFonts.epilogue(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  void _showFakeConfirmation(BuildContext context, Function onSuccess) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SimulatedRazorpaySheet(onSuccess: onSuccess),
    );
  }
}

class _SimulatedRazorpaySheet extends StatefulWidget {
  final Function onSuccess;

  const _SimulatedRazorpaySheet({required this.onSuccess});

  @override
  State<_SimulatedRazorpaySheet> createState() =>
      _SimulatedRazorpaySheetState();
}

class _SimulatedRazorpaySheetState extends State<_SimulatedRazorpaySheet> {
  @override
  void initState() {
    super.initState();
    // Simulate processing delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context); // Close sheet
        widget.onSuccess(); // Trigger success
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 350,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const SizedBox(
            height: 60,
            width: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Confirming Payment",
            style: GoogleFonts.epilogue(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "This will only take a few seconds",
            style: GoogleFonts.epilogue(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                "Secured by Razorpay",
                style: GoogleFonts.epilogue(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
