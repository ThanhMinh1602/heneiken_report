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
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primaryCheckOut,
          selectionHandleColor: AppColors.primaryCheckOut,
        ),
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: const TextStyle(color: AppColors.primaryCheckOut),
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIconColor: Colors.grey,
          suffixIconColor: Colors.grey,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.primaryCheckOut,
              width: 2,
            ),
          ),
        ),
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
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          
          // 1. QUAN TRỌNG: Đặt chiều cao toolbar về 0 để xóa khoảng trắng phía trên
          toolbarHeight: 0, 
          
          bottom: const TabBar(
            labelColor: AppColors.primaryCheckIn,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryCheckIn,
            indicatorWeight: 3,
            
            // 2. Giảm padding dọc của Tab để thanh tab mỏng hơn
            labelPadding: EdgeInsets.symmetric(vertical: 8), 
            
            tabs: [
              // 3. Tùy chỉnh Tab con: Giảm size icon và margin
              Tab(
                icon: Icon(Icons.login, size: 20), // Icon nhỏ lại (mặc định 24)
                text: "CHECK-IN",
                iconMargin: EdgeInsets.only(bottom: 4), // Khoảng cách giữa icon và text
                height: 50, // Chiều cao cố định cho Tab (nếu muốn ép nhỏ hơn nữa)
              ),
              Tab(
                icon: Icon(Icons.logout, size: 20),
                text: "CHECK-OUT",
                iconMargin: EdgeInsets.only(bottom: 4),
                height: 50,
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [CheckInScreen(), CheckOutScreen()]),
      ),
    );
  }
}