// ignore_for_file: must_be_immutable

import 'package:car_onwer/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';

class PayFareAmountDialog extends StatefulWidget {
  double? fareAmount;
  PayFareAmountDialog({
    super.key,
    this.fareAmount,
  });

  @override
  State<PayFareAmountDialog> createState() => _PayFareAmountDialogState();
}

class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "FareAmount".toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                thickness: 2,
                color: Colors.black,
                height: 2,
              ),
              const SizedBox(height: 10),
              Text(
                "Tz${widget.fareAmount}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 50,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "This is the total mechanics fareamount. Please pay it to the Car Mechanics",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    Future.delayed(const Duration(milliseconds: 10000), () {
                      Navigator.pop(context, "Cash Paid");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SplashScreen(),
                          ));
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "Pay Cash",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 100),
                      Text(
                        "Tz${widget.fareAmount}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
