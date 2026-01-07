import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/check_in_screen.dart';
import 'screens/check_out_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // Đặt theme chung ở đây để đồng bộ
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: AppColors.primaryCheckOut,
        scaffoldBackgroundColor: AppColors.bgGrey, // Màu nền chung
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
            elevation: 2, // Tăng bóng đổ nhẹ để tách biệt hẳn với body
            toolbarHeight: 0, // Ẩn toolbar chuẩn
            
            bottom: const TabBar(
              // MÀU SẮC & INDICATOR
              labelColor: AppColors.primaryCheckIn,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryCheckIn,
              indicatorWeight: 3, // Dày hơn chút để rõ ràng
              indicatorSize: TabBarIndicatorSize.tab, // Gạch chân full chiều rộng tab
              
              // TYPOGRAPHY (FONT CHỮ)
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold, // Tab được chọn sẽ in đậm
                fontSize: 13,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal, // Tab chưa chọn in thường
                fontSize: 13,
              ),

              // SPACING (KHOẢNG CÁCH)
              // Xóa labelPadding cứng để tránh overflow trên máy nhỏ
              // labelPadding: EdgeInsets.zero, 
              
              tabs: [
                Tab(
                  icon: Icon(Icons.login), // Để size mặc định (24) hoặc chỉnh 22 tuỳ ý
                  text: "CHECK-IN",
                  iconMargin: EdgeInsets.only(bottom: 4), // Khoảng cách chuẩn
                ),
                Tab(
                  icon: Icon(Icons.logout),
                  text: "CHECK-OUT",
                  iconMargin: EdgeInsets.only(bottom: 4),
                ),
              ],
            ),
          ),
          
          // BODY
          body: const TabBarView(
            physics: BouncingScrollPhysics(), // Hiệu ứng lướt mượt mà
            children: [
              CheckInScreen(), 
              CheckOutScreen()
            ],
          ),
        ),
      ),
    );
  }
}