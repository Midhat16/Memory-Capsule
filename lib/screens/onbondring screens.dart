import 'package:flutter/material.dart';
import 'package:untitled3/screens/profile%20page.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/images/memory.png',
      'title': 'Preserve Your Memories',
      'subtitle': 'Create digital time capsules to save your moments for future reflection.',
    },
    {
      'image': 'assets/images/calender.png',
      'title': 'Set a Date to Unlock',
      'subtitle': 'Lock your memories and unlock them on a specific date in the future.',
    },
    {
      'image': 'assets/images/sharing.png',
      'title': 'Share with Loved Ones',
      'subtitle': 'Send your capsules to friends or family and relive special memories together.',
    },
  ];

  void _nextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Navigate to main/home screen
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body:  Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [Colors.green.shade900, Colors.black],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
    ),
    ),
    child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed:(){Navigator.push(context, MaterialPageRoute(builder: (context){
                          return MyProfileScreen();
                        }));},
                        child: Text("Skip", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: 30),
                    Image.asset(onboardingData[index]['image']!, height: 300),
                    SizedBox(height: 23),
                    Text(
                      onboardingData[index]['title']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.green),
                    ),
                    SizedBox(height: 10),
                    Text(
                      onboardingData[index]['subtitle']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 10,),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(onboardingData.length, (index) {
                return AnimatedContainer(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  duration: Duration(milliseconds: 300),
                  height: 8,
                  width: _currentIndex == index ? 20 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? Colors.green.shade900 : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 10,),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed:_nextPage,
              style:ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade900,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),
              child: Text("Next →", style: TextStyle(fontSize: 16,color: Colors.white)),
            ),
          ),
        ],
      ),
      )
    );
  }
}
