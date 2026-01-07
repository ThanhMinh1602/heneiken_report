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
        useMaterial3: false, // nếu bạn dùng M2 (ổn định hơn cho border)
        primaryColor: AppColors.primaryCheckOut, // hoặc AppColors.primary
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryCheckOut, // màu chủ đạo
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
          title: const Text(
            'Báo Cáo Field Work',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          bottom: const TabBar(
            labelColor: AppColors.primaryCheckIn,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryCheckIn,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.login), text: "CHECK-IN"),
              Tab(icon: Icon(Icons.logout), text: "CHECK-OUT"),
            ],
          ),
        ),
        body: const TabBarView(children: [CheckInScreen(), CheckOutScreen()]),
      ),
    );
  }
}