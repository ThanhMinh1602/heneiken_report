import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../data/app_data.dart';
import '../data/outlet_model.dart';
import '../widgets/common_widgets.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});
  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _dateController = TextEditingController();
  final _supController = TextEditingController();
  final _outletIdController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedSP;
  String? _selectedOutletName;
  List<String> _uniqueSPs = [];
  List<OutletModel> _filteredOutlets = [];

  final _trafficTotalController = TextEditingController();
  final _trafficConvertController = TextEditingController();
  final _trafficBuyHVNController = TextEditingController();
  final _trafficBuyBeerController = TextEditingController();
  
  final _advantageController = TextEditingController();
  final _difficultyController = TextEditingController();
  final _noteController = TextEditingController();

  // Controller cho Thùng (Cases)
  final Map<String, TextEditingController> _salesControllers = {};
  // Controller cho Lon (Cans)
  final Map<String, TextEditingController> _salesCanControllers = {};
  
  final Map<String, TextEditingController> _giftUsedControllers = {};

  @override
  void initState() {
    super.initState();
    _uniqueSPs = masterData.map((e) => e.spName).toSet().toList();
    
    // Khởi tạo controller cho cả Thùng và Lon
    for (var p in productListCheckOut) {
      _salesControllers[p] = TextEditingController();
      _salesCanControllers[p] = TextEditingController();
    }
    
    for (var g in giftList) {
      _giftUsedControllers[g] = TextEditingController();
    }
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String today = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _dateController.text = prefs.getString('in_date') ?? today;
      _supController.text = prefs.getString('in_sup') ?? "Nguyễn Thanh Minh";
      _outletIdController.text = prefs.getString('in_outlet_id') ?? "";
      _addressController.text = prefs.getString('in_address') ?? "";

      String? savedSP = prefs.getString('in_sp_name');
      String? savedOutlet = prefs.getString('in_store_name');
      if (savedSP != null && _uniqueSPs.contains(savedSP)) {
        _selectedSP = savedSP;
        _filteredOutlets = masterData
            .where((e) => e.spName == _selectedSP)
            .toList();
        if (savedOutlet != null &&
            _filteredOutlets.any((e) => e.name == savedOutlet)) {
          _selectedOutletName = savedOutlet;
        }
      }

      _trafficTotalController.text = prefs.getString('out_traffic_total') ?? "";
      _trafficConvertController.text =
          prefs.getString('out_traffic_convert') ?? "";
      _trafficBuyHVNController.text = prefs.getString('out_traffic_hvn') ?? "";
      _trafficBuyBeerController.text =
          prefs.getString('out_traffic_beer') ?? "";
      
      _advantageController.text = prefs.getString('out_advantage') ?? "";
      _difficultyController.text = prefs.getString('out_difficulty') ?? "";
      _noteController.text = prefs.getString('out_note') ?? "";

      for (var p in productListCheckOut) {
        _salesControllers[p]?.text = prefs.getString('out_sales_$p') ?? "";
        // Load dữ liệu Lon
        _salesCanControllers[p]?.text = prefs.getString('out_sales_can_$p') ?? "";
      }
      for (var g in giftList) {
        _giftUsedControllers[g]?.text = prefs.getString('out_gift_$g') ?? "";
      }
    });
  }

  void _onSPChanged(String? newValue) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSP = newValue;
      _selectedOutletName = null;
      _outletIdController.clear();
      _addressController.clear();
      _filteredOutlets = masterData.where((e) => e.spName == newValue).toList();
    });
    prefs.setString('in_sp_name', newValue ?? "");
  }

  void _onOutletChanged(String? newValue) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedOutletName = newValue;
      final outletObj = masterData.firstWhere((e) => e.name == newValue);
      _outletIdController.text = outletObj.id;
      _addressController.text = outletObj.address;
    });
    prefs.setString('in_store_name', newValue ?? "");
    prefs.setString('in_outlet_id', _outletIdController.text);
    prefs.setString('in_address', _addressController.text);
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận làm mới"),
          content: const Text(
              "Bạn có chắc chắn muốn xoá hết số liệu Bán hàng (Check-out) không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetDailySales();
              },
              child: const Text("Đồng ý",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetDailySales() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String today = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _dateController.text = today;
      prefs.setString('in_date', today);

      _trafficTotalController.clear();
      prefs.setString('out_traffic_total', '');
      _trafficConvertController.clear();
      prefs.setString('out_traffic_convert', '');
      _trafficBuyHVNController.clear();
      prefs.setString('out_traffic_hvn', '');
      _trafficBuyBeerController.clear();
      prefs.setString('out_traffic_beer', '');

      _advantageController.clear();
      prefs.setString('out_advantage', '');
      _difficultyController.clear();
      prefs.setString('out_difficulty', '');
      _noteController.clear();
      prefs.setString('out_note', '');

      for (var c in _salesControllers.values) c.clear();
      for (var c in _salesCanControllers.values) c.clear(); // Clear Lon
      for (var c in _giftUsedControllers.values) c.clear();
      
      for (var p in productListCheckOut) {
        prefs.remove('out_sales_$p');
        prefs.remove('out_sales_can_$p'); // Remove Lon
      }
      for (var g in giftList) prefs.remove('out_gift_$g');
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Đã xoá số liệu bán hàng!")));
  }

  void _copyReport() {
    StringBuffer sb = StringBuffer();
    sb.writeln("CHECK OUT CUỐI CA"); 
    sb.writeln("Ngày thực hiện: ${_dateController.text}");
    sb.writeln("SUP: ${_supController.text}");
    sb.writeln("SP: ${_selectedSP ?? ""}");
    sb.writeln("Cửa Hàng: ${_selectedOutletName ?? ""}");
    sb.writeln("Mã Outlet: ${_outletIdController.text}");
    sb.writeln("Địa Chỉ: ${_addressController.text}");
    
    sb.writeln("1/ Thông tin Traffic");
    sb.writeln("- Số khách hàng đến cửa hàng: ${_trafficTotalController.text}");
    sb.writeln("- Số khách hàng chuyển đổi từ bia đối thủ: ${_trafficConvertController.text}");
    sb.writeln("- Số khách hàng mua bia HVN: ${_trafficBuyHVNController.text}");
    sb.writeln("- Số khách mua bia: ${_trafficBuyBeerController.text}");
    sb.writeln(""); 

    // --- TÍNH TỔNG (THÙNG VÀ LON) ---
    int totalCases = 0;
    int totalCans = 0;

    for (var p in productListCheckOut) {
      // Cộng Thùng
      String caseText = _salesControllers[p]?.text ?? "";
      if (caseText.isNotEmpty) {
        totalCases += int.tryParse(caseText.replaceAll('.', '')) ?? 0;
      }
      // Cộng Lon
      String canText = _salesCanControllers[p]?.text ?? "";
      if (canText.isNotEmpty) {
        totalCans += int.tryParse(canText.replaceAll('.', '')) ?? 0;
      }
    }
    
    // Hiển thị dòng tổng
    String totalStr = "";
    if (totalCases > 0 && totalCans > 0) {
      totalStr = "$totalCases thùng + $totalCans lon";
    } else if (totalCases > 0) {
      totalStr = "$totalCases thùng";
    } else if (totalCans > 0) {
      totalStr = "$totalCans lon";
    } else {
      totalStr = "0";
    }

    // SỬA: Thêm chữ (thùng) vào tiêu đề giống mẫu 1
    sb.writeln("2/ Tổng doanh số bán hàng (thùng) : $totalStr");

    // --- HIỂN THỊ TỪNG MÃ SẢN PHẨM ---
    for (var p in productListCheckOut) {
      String rawCase = _salesControllers[p]?.text ?? "";
      String rawCan = _salesCanControllers[p]?.text ?? "";
      
      int valCase = int.tryParse(rawCase.replaceAll('.', '')) ?? 0;
      int valCan = int.tryParse(rawCan.replaceAll('.', '')) ?? 0;

      // Logic hiển thị chi tiết
      String detail = "";
      if (valCase > 0 && valCan > 0) {
        detail = "$rawCase thùng + $rawCan lon";
      } else if (valCase > 0) {
        detail = "$rawCase thùng";
      } else if (valCan > 0) {
        detail = "$rawCan lon";
      } else {
        detail = "0";
      }

      // SỬA: Thêm (thùng) sau tên SP & xử lý HVN khác
      if (p.toLowerCase().contains("số bán hvn khác")) {
          if (valCase == 0 && valCan == 0) {
             sb.writeln("- $p: (thùng)"); // Mẫu 1 là (thùng)
          } else {
             sb.writeln("- $p: $detail");
          }
      } else {
          sb.writeln("- $p (thùng) : $detail"); // Mẫu 1 có chữ (thùng) ở đây
      }
    }
    
    sb.writeln("3/ Quà tặng sử dụng:");
    
    // SỬA: Sắp xếp lại thứ tự và thêm đơn vị tính giống mẫu 1
    // Mẫu 1: Bao Lì xì -> Tiger -> Heineken -> Mainstream
    List<String> sortedGifts = [
      "Bao Lì xì",
      "Tiger Giftbox",
      "Heineken Giftbox",
      "Mainstream Giftbox"
    ];
    
    // Map đơn vị
    Map<String, String> giftUnits = {
      "Bao Lì xì": "(bao)",
      "Tiger Giftbox": "(hộp)",
      "Heineken Giftbox": "(hộp)",
      "Mainstream Giftbox": "(hộp)",
    };

    for (var gName in sortedGifts) {
       // Chỉ in nếu tên tồn tại trong danh sách gốc
       if (_giftUsedControllers.containsKey(gName)) {
         String rawVal = _giftUsedControllers[gName]?.text ?? "";
         if (rawVal.isEmpty) rawVal = "0";
         String unit = giftUnits[gName] ?? "";
         
         sb.writeln("- $gName $unit: $rawVal");
       }
    }

    sb.writeln(""); 
    sb.writeln("Thuận lợi/ khó khăn :");
    
    if (_advantageController.text.isNotEmpty) {
       sb.writeln("Thuận lợi: ${_advantageController.text}");
    }
    if (_difficultyController.text.isNotEmpty) {
       sb.writeln("Khó khăn: ${_difficultyController.text}");
    }
    
    sb.writeln("note: ${_noteController.text}");

    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đã sao chép Check-out!'),
        backgroundColor: AppColors.primaryCheckOut));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _copyReport,
        label: const Text("SAO CHÉP CHECK-OUT"),
        icon: const Icon(Icons.copy),
        backgroundColor: AppColors.primaryCheckOut,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Padding(
                     padding: EdgeInsets.only(top: 2),
                     child: Icon(Icons.camera_alt, color: Colors.teal, size: 26),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: const [
                         Text("YÊU CẦU HÌNH ẢNH:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 14)),
                         SizedBox(height: 6),
                         Text("• Selfie", style: TextStyle(color: Colors.black87, height: 1.4)),
                         Text("• Toàn quán", style: TextStyle(color: Colors.black87, height: 1.4)),
                         Text("• Doanh số theo đơn hàng", style: TextStyle(color: Colors.black87, height: 1.4)),
                         Text("• Báo cáo bổ sung", style: TextStyle(color: Colors.black87, height: 1.4)),
                         Text("• Hình check-in phần Nhân sự", style: TextStyle(color: Colors.black87, height: 1.4)),
                       ],
                     ),
                   )
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildHeader("Thông tin chung", AppColors.primaryCheckOut),
                IconButton(
                  icon: const Icon(Icons.cleaning_services_rounded, color: Colors.orange),
                  onPressed: _confirmReset,
                ),
              ],
            ),
            buildSectionCard(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: DropdownButtonFormField<String>(
                      value: _selectedSP,
                      decoration: const InputDecoration(labelText: "SP", prefixIcon: Icon(Icons.badge), border: OutlineInputBorder(), filled: true),
                      items: _uniqueSPs.map((sp) => DropdownMenuItem(value: sp, child: Text(sp))).toList(),
                      onChanged: _onSPChanged,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: DropdownButtonFormField<String>(
                      value: _selectedOutletName,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: "Cửa Hàng", prefixIcon: Icon(Icons.store), border: OutlineInputBorder(), filled: true),
                      items: _selectedSP == null
                          ? []
                          : _filteredOutlets.map((out) => DropdownMenuItem(value: out.name, child: Text(out.name, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: _onOutletChanged,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(child: buildTextField("Mã Outlet", _outletIdController, 'in_outlet_id', Icons.qr_code)),
                    ],
                  ),
                ],
              ),
            ),

            buildHeader("1/ Traffic", AppColors.primaryCheckOut),
            buildSectionCard(
              child: Column(
                children: [
                  buildNumberInput("Khách đến", _trafficTotalController, 'out_traffic_total'),
                  const SizedBox(height: 10),
                  buildNumberInput("Khách chuyển đổi", _trafficConvertController, 'out_traffic_convert'),
                  const SizedBox(height: 10),
                  buildNumberInput("Mua bia HVN", _trafficBuyHVNController, 'out_traffic_hvn'),
                  const SizedBox(height: 10),
                  buildNumberInput("Tổng mua bia", _trafficBuyBeerController, 'out_traffic_beer'),
                ],
              ),
            ),

            buildHeader("2/ Doanh Số Bán Hàng", AppColors.primaryCheckOut),
            buildSectionCard(
              child: Column(
                children: [
                  // Header nhỏ
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0, left: 4, right: 4),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: SizedBox()),
                        Expanded(flex: 2, child: Text("Thùng", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12))),
                        SizedBox(width: 20), // Khoảng cách cho dấu +
                        Expanded(flex: 2, child: Text("Lon", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12))),
                      ],
                    ),
                  ),
                  ...productListCheckOut.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tên sản phẩm
                        Expanded(
                          flex: 3, 
                          child: Text(p, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))
                        ),
                        const SizedBox(width: 4),
                        // Nhập Thùng
                        Expanded(
                          flex: 2, 
                          child: buildNumberInput("", _salesControllers[p]!, 'out_sales_$p')
                        ),
                        // Dấu Cộng
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text("+", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                        // Nhập Lon
                        Expanded(
                          flex: 2, 
                          child: buildNumberInput("", _salesCanControllers[p]!, 'out_sales_can_$p')
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            buildHeader("3/ Quà tặng sử dụng", AppColors.primaryCheckOut),
             buildSectionCard(
              child: Column(
                children: giftList.map((g) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(g)),
                        Expanded(flex: 1, child: buildNumberInput("SL", _giftUsedControllers[g]!, 'out_gift_$g')),
                      ],
                    ),
                  )).toList(),
              ),
             ),

            buildHeader("Phản hồi & Ghi chú", AppColors.primaryCheckOut),
            buildSectionCard(
              child: Column(
                children: [
                  buildTextField("Thuận lợi", _advantageController, 'out_advantage', Icons.thumb_up_alt_outlined),
                  buildTextField("Khó khăn", _difficultyController, 'out_difficulty', Icons.warning_amber_rounded),
                  buildTextField("Note/Ghi chú...", _noteController, 'out_note', Icons.note, maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}