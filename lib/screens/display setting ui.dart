// lib/screens/display_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/screens/profile%20page.dart';
import 'display setting screen.dart';

class DisplaySettingsScreen extends StatelessWidget {
  const DisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<DisplaySettingsProvider>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return MyProfileScreen();
          }));
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Text('Display Settings',style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.green.shade900,),
      body:
      Container(
        width: size.width,
        height: size.height,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Font Size'),
            Slider(
              min: 12,
              max: 30,
              value: settings.fontSize,
              onChanged: (value) => settings.updateFontSize(value),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('High Contrast Mode'),
              value: settings.highContrast,
              onChanged: (val) => settings.toggleHighContrast(val),
            ),
            const SizedBox(height: 20),
            Consumer<DisplaySettingsProvider>(
              builder: (context, settings, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Font Style'),
                    DropdownButton<String>(
                      value: settings.fontFamily,
                      onChanged: (font) {
                        if (font != null) settings.updateFontFamily(font);
                      },
                      items: ['Roboto', 'CourierPrime', 'Lobster'].map((font) {
                        return DropdownMenuItem(
                          value: font,
                          child: Text(
                            font,
                            style: TextStyle(
                              fontFamily: font,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            )

          ],
        ),
      ),
    );
  }
}
