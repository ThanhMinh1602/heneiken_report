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

  // =========================
  // KEY NAMESPACE THEO SHOP
  // =========================
  String get _shopKey {
    // Ưu tiên outletId (ổn định), fallback outletName
    final id = _outletIdController.text.trim();
    final name = (_selectedOutletName ?? '').trim();
    final base = id.isNotEmpty ? id : name;

    // tránh ký tự lạ
    return base.isEmpty
        ? "NO_SHOP"
        : base.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
  }

  String _k(String field) => "in_${_shopKey}_$field";

  bool get _hasSelectedShop =>
      _selectedOutletName != null &&
      (_outletIdController.text.trim().isNotEmpty ||
          (_selectedOutletName ?? '').trim().isNotEmpty);

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

      // SP + Outlet đã chọn lần trước
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
          // outletId/address đã set ở trên từ prefs
        }
      }
    });

    // Load dữ liệu theo shop nếu có shop
    if (_hasSelectedShop) {
      await _loadShopData();
    } else {
      // nếu chưa chọn shop thì chỉ load note "global" (tuỳ bạn)
      // ở đây mình để trống các field theo shop
      _clearShopControllersOnly();
    }
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

    // đổi SP thì chưa có shop => clear controllers theo shop
    _clearShopControllersOnly();
  }

  void _onOutletChanged(String? newValue) async {
    setState(() {
      _selectedOutletName = newValue;
      final outletObj = masterData.firstWhere((e) => e.name == newValue);
      _outletIdController.text = outletObj.id;
      _addressController.text = outletObj.address;
    });

    await _saveSelection('in_store_name', newValue);
    await _saveSelection('in_outlet_id', _outletIdController.text);
    await _saveSelection('in_address', _addressController.text);

    // Quan trọng: load data theo shop vừa chọn
    await _loadShopData();
  }

  Future<void> _loadShopData() async {
    if (!_hasSelectedShop) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var p in productListCheckIn) {
        _qtyControllers[p]?.text = prefs.getString(_k("qty_$p")) ?? "";
        _priceControllers[p]?.text = prefs.getString(_k("price_$p")) ?? "";
      }
      for (var g in giftList) {
        final val = prefs.getString(_k("gift_$g"));
        _giftControllers[g]?.text = (val == null || val.trim().isEmpty)
            ? "0"
            : val;
      }
      for (var p in posmList) {
        final val = prefs.getString(_k("posm_$p"));
        _posmControllers[p]?.text = (val == null || val.trim().isEmpty)
            ? "0"
            : val;
      }

      _noteController.text = prefs.getString(_k("note")) ?? "";
    });
  }

  void _clearShopControllersOnly() {
    setState(() {
      for (var c in _qtyControllers.values) {
        c.clear();
      }
      for (var c in _priceControllers.values) {
        c.clear();
      }
      for (var c in _giftControllers.values) {
        c.text = "0";
      }
      for (var c in _posmControllers.values) {
        c.text = "0";
      }

      _noteController.clear();
    });
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận làm mới"),
          content: Text(
            _hasSelectedShop
                ? "Bạn có chắc chắn muốn xoá hết dữ liệu Check-in của shop này không?"
                : "Bạn chưa chọn shop. Bạn có chắc chắn muốn xoá dữ liệu đang nhập không?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetShopData(); // reset theo shop
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

  Future<void> _resetShopData() async {
    final prefs = await SharedPreferences.getInstance();

    // vẫn giữ ngày hôm nay + sup + selection
    setState(() {
      String today = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _dateController.text = today;
      prefs.setString('in_date', today);
    });

    // Nếu chưa có shop, chỉ clear controller trên UI
    if (!_hasSelectedShop) {
      _clearShopControllersOnly();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã làm mới dữ liệu đang nhập!")),
      );
      return;
    }

    setState(() {
      _noteController.clear();
      prefs.remove(_k("note"));

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
        prefs.remove(_k("qty_$p"));
        prefs.remove(_k("price_$p"));
      }
      for (var g in giftList) {
        prefs.remove(_k("gift_$g"));
      }
      for (var p in posmList) {
        prefs.remove(_k("posm_$p"));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã làm mới dữ liệu cho shop hiện tại!")),
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
        sb.writeln(
          "- $p ${i != (productListCheckIn.length - 1) ? "(thùng): $qty  Giá bán: $price/thùng" : ""}",
        );
      } else {
        sb.writeln(
          "- $p ${i != (productListCheckIn.length - 1) ? "(thùng): Giá bán: /thùng" : ""}",
        );
      }
    }

    sb.writeln("2/ Quà tặng tồn đầu:");
    for (var g in giftList) {
      final v = (_giftControllers[g]?.text.trim() ?? "");
      sb.writeln("- $g: ${v.isEmpty ? "0" : v}");
    }
    sb.writeln("3/ POSM :");
    for (var p in posmList) {
      final v = (_posmControllers[p]?.text.trim() ?? "");
      sb.writeln("- $p (cái): ${v.isEmpty ? "0" : v}");
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
      floatingActionButton: FloatingActionButton(
        onPressed: _copyReport,
        backgroundColor: AppColors.primaryCheckIn,
        child:  Icon(Icons.copy, color: Colors.white),
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
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), // xanh nhạt
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.tips_and_updates_outlined,
                          color: Colors.green,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Lưu ý khi nhập giá",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text("• Nhập theo định dạng: 100.000"),
                              Text("• Đừng quên thêm 000 ở cuối"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  ...productListCheckIn
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
                                  _k("qty_$product"),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                flex: 3,
                                child: buildNumberInput(
                                  "Giá",
                                  _priceControllers[product]!,
                                  _k("price_$product"),
                                  hintText: "100.000",
                                  isCurrency: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
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
                              _k("gift_$g"),
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
                              _k("posm_$p"),
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
                _k("note"),
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
