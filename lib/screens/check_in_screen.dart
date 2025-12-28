import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../data/app_data.dart';
import '../data/outlet_model.dart';
import '../widgets/common_widgets.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});
  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _dateController = TextEditingController();
  final _supController = TextEditingController();
  final _outletIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedSP;
  String? _selectedOutletName;

  List<String> _uniqueSPs = [];
  List<OutletModel> _filteredOutlets = [];

  final Map<String, TextEditingController> _qtyControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, TextEditingController> _giftControllers = {};
  final Map<String, TextEditingController> _posmControllers = {};

  @override
  void initState() {
    super.initState();
    _uniqueSPs = masterData.map((e) => e.spName).toSet().toList();

    for (var p in productListCheckIn) {
      _qtyControllers[p] = TextEditingController();
      _priceControllers[p] = TextEditingController();
    }
    for (var g in giftList) {
      _giftControllers[g] = TextEditingController();
    }
    for (var p in posmList) {
      _posmControllers[p] = TextEditingController();
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
      _noteController.text = prefs.getString('in_note') ?? "";

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

      for (var p in productListCheckIn) {
        _qtyControllers[p]?.text = prefs.getString('in_qty_$p') ?? "";
        _priceControllers[p]?.text = prefs.getString('in_price_$p') ?? "";
      }
      for (var g in giftList) {
        _giftControllers[g]?.text = prefs.getString('in_gift_$g') ?? "";
      }
      for (var p in posmList) {
        _posmControllers[p]?.text = prefs.getString('in_posm_$p') ?? "";
      }
    });
  }

  Future<void> _saveSelection(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) await prefs.setString(key, value);
  }

  void _onSPChanged(String? newValue) {
    setState(() {
      _selectedSP = newValue;
      _selectedOutletName = null;
      _outletIdController.clear();
      _addressController.clear();
      _filteredOutlets = masterData.where((e) => e.spName == newValue).toList();
    });
    _saveSelection('in_sp_name', newValue);
  }

  void _onOutletChanged(String? newValue) {
    setState(() {
      _selectedOutletName = newValue;
      final outletObj = masterData.firstWhere((e) => e.name == newValue);
      _outletIdController.text = outletObj.id;
      _addressController.text = outletObj.address;
    });
    _saveSelection('in_store_name', newValue);
    _saveSelection('in_outlet_id', _outletIdController.text);
    _saveSelection('in_address', _addressController.text);
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận làm mới"),
          content: const Text(
            "Bạn có chắc chắn muốn xoá hết dữ liệu Check-in đang nhập không?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetDailyData();
              },
              child: const Text(
                "Đồng ý",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String today = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _dateController.text = today;
      prefs.setString('in_date', today);

      _noteController.clear();
      prefs.setString('in_note', '');
      for (var c in _qtyControllers.values) {
        c.clear();
      }
      for (var c in _priceControllers.values) {
        c.clear();
      }
      for (var c in _giftControllers.values) {
        c.clear();
      }
      for (var c in _posmControllers.values) {
        c.clear();
      }

      for (var p in productListCheckIn) {
        prefs.remove('in_qty_$p');
        prefs.remove('in_price_$p');
      }
      for (var g in giftList) {
        prefs.remove('in_gift_$g');
      }
      for (var p in posmList) {
        prefs.remove('in_posm_$p');
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã làm mới dữ liệu cho ngày hôm nay!")),
    );
  }

  void _copyReport() {
    StringBuffer sb = StringBuffer();
    sb.writeln("CHECK IN ĐẦU CA");
    sb.writeln("Ngày thực hiện: ${_dateController.text}");
    sb.writeln("SUP: ${_supController.text}");
    sb.writeln("SP: ${_selectedSP ?? ""}");
    sb.writeln("Cửa Hàng: ${_selectedOutletName ?? ""}");
    sb.writeln("Mã Outlet: ${_outletIdController.text}");
    sb.writeln("Địa Chỉ: ${_addressController.text}");

    sb.writeln("1/ Hàng hoá tồn đầu:");
    for (int i = 0; i < productListCheckIn.length; i++) {
      final p = productListCheckIn[i];

      String qty = _qtyControllers[p]?.text ?? "";
      String price = _priceControllers[p]?.text ?? "";



      if (qty.isNotEmpty || price.isNotEmpty) {
        sb.writeln("- $p ${i != (productListCheckIn.length - 1) ? "(thùng): $qty  Giá bán: $price/thùng" : ""}");
      } else {
        sb.writeln("- $p ${i != (productListCheckIn.length - 1) ? "(thùng): Giá bán: /thùng" : ""}");
      }
    }

    sb.writeln("2/ Quà tặng tồn đầu:");
    for (var g in giftList) {
      sb.writeln("- $g: ${_giftControllers[g]?.text}");
    }
    sb.writeln("3/ POSM :");
    for (var p in posmList) {
      sb.writeln("- $p (cái): ${_posmControllers[p]?.text}");
    }
    sb.writeln("Ghi chú: ${_noteController.text}");

    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép!'),
        backgroundColor: AppColors.primaryCheckIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _copyReport,
        label: const Text("SAO CHÉP CHECK-IN"),
        icon: const Icon(Icons.copy),
        backgroundColor: AppColors.primaryCheckIn,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.deepOrange,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "YÊU CẦU HÌNH ẢNH:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "• Selfie",
                          style: TextStyle(color: Colors.black87, height: 1.4),
                        ),
                        Text(
                          "• Toàn quán",
                          style: TextStyle(color: Colors.black87, height: 1.4),
                        ),
                        Text(
                          "• Ụ bia",
                          style: TextStyle(color: Colors.black87, height: 1.4),
                        ),
                        Text(
                          "• Hình checkin trong phần nhân sự",
                          style: TextStyle(color: Colors.black87, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildHeader("Thông tin chung", AppColors.primaryCheckIn),
                IconButton(
                  icon: const Icon(
                    Icons.cleaning_services_rounded,
                    color: Colors.orange,
                  ),
                  onPressed: _confirmReset,
                ),
              ],
            ),
            buildSectionCard(
              child: Column(
                children: [
                  buildTextField(
                    "Ngày thực hiện",
                    _dateController,
                    'in_date',
                    Icons.calendar_today,
                  ),
                  buildTextField("SUP", _supController, 'in_sup', Icons.person),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: DropdownButtonFormField<String>(
                      value: _selectedSP,
                      decoration: InputDecoration(
                        labelText: "Chọn SP (Nhân viên)",
                        prefixIcon: const Icon(Icons.badge, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _uniqueSPs
                          .map(
                            (sp) =>
                                DropdownMenuItem(value: sp, child: Text(sp)),
                          )
                          .toList(),
                      onChanged: _onSPChanged,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: DropdownButtonFormField<String>(
                      value: _selectedOutletName,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Chọn Cửa Hàng",
                        prefixIcon: const Icon(Icons.store, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _selectedSP == null
                          ? []
                          : _filteredOutlets
                                .map(
                                  (out) => DropdownMenuItem(
                                    value: out.name,
                                    child: Text(
                                      out.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                      onChanged: _onOutletChanged,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          "Mã Outlet",
                          _outletIdController,
                          'in_outlet_id',
                          Icons.qr_code,
                        ),
                      ),
                    ],
                  ),
                  buildTextField(
                    "Địa Chỉ",
                    _addressController,
                    'in_address',
                    Icons.location_on,
                  ),
                ],
              ),
            ),
            buildHeader("1/ Hàng hoá tồn đầu", AppColors.primaryCheckIn),
            buildSectionCard(
              child: Column(
                children: productListCheckIn
                    .map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                product,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: buildNumberInput(
                                "SL",
                                _qtyControllers[product]!,
                                'in_qty_$product',
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              flex: 3,
                              child: buildNumberInput(
                                "Giá",
                                _priceControllers[product]!,
                                'in_price_$product',
                                hintText: "100.000",
                                isCurrency: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            buildHeader("2/ Quà tặng & POSM", AppColors.primaryCheckIn),
            buildSectionCard(
              child: Column(
                children: [
                  ...giftList.map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(g)),
                          Expanded(
                            flex: 1,
                            child: buildNumberInput(
                              "SL",
                              _giftControllers[g]!,
                              'in_gift_$g',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  ...posmList.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(p)),
                          Expanded(
                            flex: 1,
                            child: buildNumberInput(
                              "Cái",
                              _posmControllers[p]!,
                              'in_posm_$p',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            buildHeader("Ghi chú", AppColors.primaryCheckIn),
            buildSectionCard(
              child: buildTextField(
                "Ghi chú...",
                _noteController,
                'in_note',
                Icons.note,
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
