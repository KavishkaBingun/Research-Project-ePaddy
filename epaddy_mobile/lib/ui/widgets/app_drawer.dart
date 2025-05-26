import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'Navigation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            title: const Text('Diagnose Crop'),
            onTap: () {
              // Navigate to the Diagnose page
            },
          ),
          ListTile(
            title: const Text('Soil Status'),
            onTap: () {
              // Navigate to the Soil Status page
            },
          ),
          // Add other navigation options as needed
        ],
      ),
    );
  }
}
