import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final String message;
  const ProgressDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const SizedBox(width: 10),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
