import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/check_in_screen.dart';
import 'screens/check_out_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: AppColors.primaryCheckOut,
        scaffoldBackgroundColor: AppColors.bgGrey,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryCheckOut,
        ),
      ),
      home: const WorkReportApp(),
    ),
  );
}

class WorkReportApp extends StatelessWidget {
  const WorkReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2,
            toolbarHeight: 0,
            
            bottom: const TabBar(
              labelColor: AppColors.primaryCheckIn,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryCheckIn,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
              ),

              tabs: [
                Tab(
                  icon: Icon(Icons.login),
                  text: "CHECK-IN",
                  iconMargin: EdgeInsets.only(bottom: 4),
                ),
                Tab(
                  icon: Icon(Icons.logout),
                  text: "CHECK-OUT",
                  iconMargin: EdgeInsets.only(bottom: 4),
                ),
              ],
            ),
          ),
          
          body: const TabBarView(
            physics: BouncingScrollPhysics(),
            children: [
              CheckInScreen(), 
              CheckOutScreen()
            ],
          ),

          // --- PHẦN FOOTER VERSION ---
          bottomNavigationBar: Container(
            height: 24, // Chiều cao nhỏ gọn
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade100, // Màu nền nhẹ nhàng
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
            ),
            child: const Text(
              "Version 1.0.0", // Nội dung version
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontStyle: FontStyle.italic, // Chữ nghiêng cho nghệ
              ),
            ),
          ),
          // ---------------------------
          
        ),
      ),
    );
  }
}