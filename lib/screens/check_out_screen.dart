import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Đảm bảo bạn đã có các file này trong dự án
import '../constants/app_colors.dart';
import '../data/app_data.dart'; // Chứa biến productListCheckOut, giftList, masterData
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

  // Controllers
  final _dateController = TextEditingController();
  final _supController = TextEditingController();
  final _outletIdController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedSP;
  String? _selectedOutletName;
  List<String> _uniqueSPs = [];
  List<OutletModel> _filteredOutlets = [];

  // Tổng (Auto)
  final _totalCaseController = TextEditingController();
  final _totalCanController = TextEditingController();

  // Traffic
  final _trafficTotalController = TextEditingController();
  final _trafficConvertController = TextEditingController();
  final _trafficBuyHVNController = TextEditingController();
  final _trafficBuyBeerController = TextEditingController();

  // Feedback
  final _advantageController = TextEditingController();
  final _difficultyController = TextEditingController();
  final _noteController = TextEditingController();

  // Sales & Gift Controllers
  final Map<String, TextEditingController> _salesControllers = {};
  final Map<String, TextEditingController> _salesCanControllers = {};
  final Map<String, TextEditingController> _giftUsedControllers = {};

  bool _updatingTotals = false;

  // ======================
  // HELPERS
  // ======================

  int _parseInt(String s) {
    final t = s.trim();
    if (t.isEmpty) return 0;
    return int.tryParse(t.replaceAll('.', '')) ?? 0;
  }

  // Tự động tính tổng khi nhập số liệu (Hiển thị trên UI)
  void _recalcTotalsFromProducts() {
    if (_updatingTotals) return;

    int sumCases = 0;
    int sumCans = 0;

    for (final p in productListCheckOut) {
      sumCases += _parseInt(_salesControllers[p]?.text ?? "");
      sumCans += _parseInt(_salesCanControllers[p]?.text ?? "");
    }

    _updatingTotals = true;
    _totalCaseController.text = sumCases == 0 ? "" : sumCases.toString();
    _totalCanController.text = sumCans == 0 ? "" : sumCans.toString();
    _updatingTotals = false;
  }

  // ======================
  // LOGIC FORMAT REPORT
  // ======================

  // 1. Làm sạch tên (Bỏ chữ thùng nếu có)
  String _cleanProductName(String rawName) {
    return rawName.replaceAll("(thùng)", "").trim();
  }

  // 2. Format dòng chi tiết từng sản phẩm
  String _formatDetailFormNew(String productName) {
    final valCase = _parseInt(_salesControllers[productName]?.text ?? "");
    final valCan = _parseInt(_salesCanControllers[productName]?.text ?? "");

    String strCase = "$valCase";
    String strCanNumber = valCan > 0 ? "$valCan " : "";

    return "$strCase thùng + ${strCanNumber}lon";
  }

  // [UPDATED] 3. Tính tổng quy đổi dạng: X thùng + Y lon
  String _calculateTotalMixed() {
    int sumCases = 0;
    int sumCans = 0;

    for (final p in productListCheckOut) {
      sumCases += _parseInt(_salesControllers[p]?.text ?? "");
      sumCans += _parseInt(_salesCanControllers[p]?.text ?? "");
    }

    // Quy đổi: 24 lon = 1 thùng
    int extraCases = sumCans ~/ 24; // Lấy phần nguyên (số thùng từ lon)
    int remainingCans = sumCans % 24; // Lấy phần dư (số lon lẻ)

    int finalCases = sumCases + extraCases;

    if (remainingCans > 0) {
      return "$finalCases thùng + $remainingCans lon";
    } else {
      return "$finalCases thùng";
    }
  }

  // HÀM COPY CHÍNH
  void _copyReport() {
    final sb = StringBuffer();

    // -- Header --
    sb.writeln("CHECK OUT CUỐI CA");
    DateTime? pickedDate;
    try {
      pickedDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);
    } catch (e) {
      pickedDate = DateTime.now();
    }
    String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);

    sb.writeln("Ngày thực hiện:$formattedDate");
    sb.writeln("SUP: ${_supController.text}");
    sb.writeln("SP: ${_selectedSP ?? ""}");
    sb.writeln("Cửa Hàng: ${_selectedOutletName ?? ""}");
    sb.writeln("Mã Outlet: ${_outletIdController.text}");
    sb.writeln("Địa Chỉ: ${_addressController.text}");

    // -- Traffic --
    sb.writeln("1/ Thông tin Traffic");
    sb.writeln("- Số khách hàng đến cửa hàng: ${_trafficTotalController.text}");
    sb.writeln(
      "- Số khách hàng chuyển đổi từ bia đối thủ: ${_trafficConvertController.text}",
    );
    sb.writeln("- Số khách hàng mua bia HVN: ${_trafficBuyHVNController.text}");
    sb.writeln("- Số khách mua bia: ${_trafficBuyBeerController.text}");
    sb.writeln("");

    // -- Doanh số --
    // [UPDATED] Sử dụng hàm tính mới
    String totalStr = _calculateTotalMixed();
    sb.writeln("2/ Tổng doanh số bán hàng : $totalStr");

    for (final p in productListCheckOut) {
      if (p.toLowerCase().contains("số bán hvn khác")) {
        final detail = _formatDetailFormNew(p);
        sb.writeln("- số bán HVN khác:  ${detail.replaceAll('lon', 'lon')}");
        continue;
      }
      sb.writeln("- ${_cleanProductName(p)}: ${_formatDetailFormNew(p)}");
    }

    // -- Quà tặng --
    sb.writeln("3/ Quà tặng sử dụng:");
    final giftsInReportOrder = [
      "Bao Lì xì (bao)",
      "Tiger Giftbox (hộp)",
      "Heineken Giftbox (hộp)",
      "Mainstream Giftbox (hộp)",
    ];

    for (final g in giftsInReportOrder) {
      final val = _parseInt(_giftUsedControllers[g]?.text ?? "");
      sb.writeln("- $g: $val");
    }

    sb.writeln("");

    // -- Footer --
    sb.writeln("Khó khăn : ${_difficultyController.text.trim()}");
    if (_noteController.text.trim().isNotEmpty) {
      sb.writeln("Ghi chú : ${_noteController.text.trim()}");
    }

    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép báo cáo!'),
        backgroundColor: AppColors.primaryCheckOut,
      ),
    );
  }

  // ======================
  // INIT & LIFECYCLE
  // ======================

  @override
  void initState() {
    super.initState();
    _uniqueSPs = masterData.map((e) => e.spName).toSet().toList();

    for (var p in productListCheckOut) {
      _salesControllers[p] = TextEditingController();
      _salesCanControllers[p] = TextEditingController();
      _salesControllers[p]!.addListener(_recalcTotalsFromProducts);
      _salesCanControllers[p]!.addListener(_recalcTotalsFromProducts);
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
        _salesCanControllers[p]?.text =
            prefs.getString('out_sales_can_$p') ?? "";
      }

      for (var g in giftList) {
        _giftUsedControllers[g]?.text = prefs.getString('out_gift_$g') ?? "";
      }
    });
    _recalcTotalsFromProducts();
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

  // Reset
  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận làm mới"),
        content: const Text("Xoá hết số liệu bán hàng hôm nay?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Huỷ"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetDailySales();
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetDailySales() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String today = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _dateController.text = today;
      prefs.setString('in_date', today);

      _trafficTotalController.clear();
      _trafficConvertController.clear();
      _trafficBuyHVNController.clear();
      _trafficBuyBeerController.clear();
      _advantageController.clear();
      _difficultyController.clear();
      _noteController.clear();
      _totalCaseController.clear();
      _totalCanController.clear();

      prefs.remove('out_traffic_total');
      prefs.remove('out_traffic_convert');
      prefs.remove('out_traffic_hvn');
      prefs.remove('out_traffic_beer');
      prefs.remove('out_advantage');
      prefs.remove('out_difficulty');
      prefs.remove('out_note');

      for (var c in _salesControllers.values) c.clear();
      for (var c in _salesCanControllers.values) c.clear();
      for (var c in _giftUsedControllers.values) c.clear();

      for (var p in productListCheckOut) {
        prefs.remove('out_sales_$p');
        prefs.remove('out_sales_can_$p');
      }
      for (var g in giftList) prefs.remove('out_gift_$g');
    });
    _recalcTotalsFromProducts();
  }

  // ======================
  // UI
  // ======================

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      floatingActionButton: FloatingActionButton(
        onPressed: _copyReport,
        backgroundColor: AppColors.primaryCheckOut,
        child: const Icon(Icons.copy, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: const [
                  Icon(Icons.camera_alt, color: Colors.deepOrange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "YÊU CẦU HÌNH ẢNH:\n• Selfie\n• Toàn quán\n• Doanh số\n• Check-in Nhân sự",
                      style: TextStyle(height: 1.4, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildHeader("Thông tin chung", AppColors.primaryCheckOut),
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
                    "Ngày (dd/MM/yyyy)",
                    _dateController,
                    'in_date',
                    Icons.calendar_today,
                  ),
                  buildTextField("SUP", _supController, 'in_sup', Icons.person),

                  // SP Dropdown
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: DropdownButtonFormField<String>(
                      value: _selectedSP,
                      decoration: InputDecoration(
                        labelText: "Chọn SP",
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

                  // Outlet Dropdown
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

                  buildTextField(
                    "Mã Outlet",
                    _outletIdController,
                    'in_outlet_id',
                    Icons.qr_code,
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

            // Traffic
            buildHeader("1/ Traffic", AppColors.primaryCheckOut),
            buildSectionCard(
              child: Column(
                children: [
                  _trafficRow(
                    "Khách đến",
                    _trafficTotalController,
                    'out_traffic_total',
                  ),
                  const SizedBox(height: 10),
                  _trafficRow(
                    "Khách chuyển đổi",
                    _trafficConvertController,
                    'out_traffic_convert',
                  ),
                  const SizedBox(height: 10),
                  _trafficRow(
                    "Mua bia HVN",
                    _trafficBuyHVNController,
                    'out_traffic_hvn',
                  ),
                  const SizedBox(height: 10),
                  _trafficRow(
                    "Tổng mua bia",
                    _trafficBuyBeerController,
                    'out_traffic_beer',
                  ),
                ],
              ),
            ),

            // Sales
            buildHeader("2/ Doanh Số", AppColors.primaryCheckOut),
            buildSectionCard(
              child: Column(
                children: [
                  // Auto Total Display
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "TỔNG (Auto): ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: buildNumberInput(
                            "",
                            _totalCaseController,
                            'out_total_case',
                            hintText: "Thùng",
                          ),
                        ),
                        const Text(" + ", style: TextStyle(color: Colors.grey)),
                        Expanded(
                          child: buildNumberInput(
                            "",
                            _totalCanController,
                            'out_total_can',
                            hintText: "lon",
                          ),
                        ),
                      ],
                    ),
                  ),

                  ...productListCheckOut.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              p,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: buildNumberInput(
                              "",
                              _salesControllers[p]!,
                              'out_sales_$p',
                              hintText: "Thùng",
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              "+",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: buildNumberInput(
                              "",
                              _salesCanControllers[p]!,
                              'out_sales_can_$p',
                              hintText: "lon",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Gifts
            buildHeader("3/ Quà tặng", AppColors.primaryCheckOut),
            buildSectionCard(
              child: Column(
                children: giftList
                    .map(
                      (g) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(g)),
                            Expanded(
                              flex: 1,
                              child: buildNumberInput(
                                "SL",
                                _giftUsedControllers[g]!,
                                'out_gift_$g',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            // Feedback
            buildHeader("Phản hồi & Khó khăn", AppColors.primaryCheckOut),
            buildSectionCard(
              child: Column(
                children: [
                  buildTextField(
                    "Khó khăn",
                    _difficultyController,
                    'out_difficulty',
                    Icons.warning_amber_rounded,
                  ),
                  buildTextField(
                    "Ghi chú (nếu cần)",
                    _noteController,
                    'out_note',
                    Icons.note,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _trafficRow(String label, TextEditingController ctrl, String key) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(flex: 2, child: buildNumberInput("", ctrl, key)),
      ],
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _supController.dispose();
    _outletIdController.dispose();
    _addressController.dispose();
    _totalCaseController.dispose();
    _totalCanController.dispose();
    _trafficTotalController.dispose();
    _trafficConvertController.dispose();
    _trafficBuyHVNController.dispose();
    _trafficBuyBeerController.dispose();
    _advantageController.dispose();
    _difficultyController.dispose();
    _noteController.dispose();
    for (var c in _salesControllers.values) c.dispose();
    for (var c in _salesCanControllers.values) c.dispose();
    for (var c in _giftUsedControllers.values) c.dispose();
    super.dispose();
  }
}
