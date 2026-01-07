import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/check_in_screen.dart';
import 'screens/check_out_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WorkReportApp(),
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: AppColors.primaryCheckOut,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryCheckOut,
        ),
        // ... (giữ nguyên theme cũ của bạn) ...
      ),
    ),
  );
}

class WorkReportApp extends StatelessWidget {
  const WorkReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea( // 1. Thêm SafeArea để tránh bị tai thỏ che mất TabBar
        child: Scaffold(
          backgroundColor: AppColors.bgGrey,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 1,
            toolbarHeight:  0, // Giữ nguyên để ẩn toolbar
            bottom: const TabBar(
              labelColor: AppColors.primaryCheckIn,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryCheckIn,
              indicatorWeight: 1,
              
              // 2. Chỉnh padding về 0 hoặc rất nhỏ để Tab gọn nhất có thể
              labelPadding: EdgeInsets.symmetric(vertical: 6),
              
              tabs: [
                Tab(
                  icon: Icon(Icons.login, size: 22),
                  text: "CHECK-IN",
                  // 3. XÓA thuộc tính height: 50 (nguyên nhân gây overflow)
                  iconMargin: EdgeInsets.only(bottom: 2), 
                ),
                Tab(
                  icon: Icon(Icons.logout, size: 22),
                  text: "CHECK-OUT",
                  // 3. XÓA thuộc tính height: 50
                  iconMargin: EdgeInsets.only(bottom: 2),
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              CheckInScreen(), 
              CheckOutScreen()
            ]
          ),
        ),
      ),
    );
  }
}