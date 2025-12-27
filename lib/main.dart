import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/check_in_screen.dart';
import 'screens/check_out_screen.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: WorkReportApp()),
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