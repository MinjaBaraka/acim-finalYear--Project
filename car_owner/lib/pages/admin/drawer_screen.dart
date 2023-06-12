import 'package:flutter/material.dart';

import '../../auth/login_screen.dart';
import '../../global/global.dart';
import 'profile_screen.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      color: Colors.white,
      width: 255.0,
      child: Drawer(
        child: ListView(
          children: [
            SizedBox(
              height: 165.0,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/image/2.jpg",
                      height: 65.0,
                      width: 65.0,
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          // userModalCurrentInfo!.name!,
                          userModalCurrentInfo?.name ?? '',
                          style: const TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ));
                          },
                          child: const Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            const ListTile(
              leading: Icon(Icons.history),
              title: Text(
                "Service History",
                style: TextStyle(fontSize: 15.0),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
            const ListTile(
              leading: Icon(Icons.notifications_active_outlined),
              title: Text(
                "Notification",
                style: TextStyle(fontSize: 15.0),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
            const ListTile(
              leading: Icon(Icons.credit_card),
              title: Text(
                "Payment",
                style: TextStyle(fontSize: 15.0),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
            // const ListTile(
            //   leading: Icon(Icons.notifications_active_outlined),
            //   title: Text(
            //     "Promos",
            //     style: TextStyle(fontSize: 15.0),
            //   ),
            //   trailing: Icon(Icons.chevron_right),
            // ),
            const ListTile(
              leading: Icon(Icons.help_outline),
              title: Text(
                "Help",
                style: TextStyle(fontSize: 15.0),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
            const ListTile(
              leading: Icon(Icons.info_outlined),
              title: Text(
                "About",
                style: TextStyle(fontSize: 15.0),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              onTap: () {
                firebaseAuth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              leading: const Icon(Icons.logout),
              title: const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    ));
  }
}
