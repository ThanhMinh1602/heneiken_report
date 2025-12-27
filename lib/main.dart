import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: WorkReportApp()),
  );
}

// --- DATA MODEL TỪ FILE ẢNH ---
class OutletModel {
  final String id;
  final String name;
  final String address;
  final String spName;

  OutletModel(this.id, this.name, this.address, this.spName);
}

// DỮ LIỆU CỨNG (Đã nhập từ file ảnh excel)
final List<OutletModel> masterData = [
  OutletModel(
    "69214399",
    "NUTRIMART",
    "1 Đỗ Quang, Quế Sơn",
    "Nguyễn Thị Tú Mẫn",
  ),
  OutletModel("69214632", "HƯƠNG NGUYỄN", "QL 1A, Quế Sơn", "Nguyễn Kim Ngân"),
  OutletModel("69211385", "ANH ĐÀO", "Quế Phú, Quế Sơn", "Đoàn Thị Thu Hiền"),
  OutletModel(
    "69224803",
    "MINI HÀ PHƯƠNG",
    "4 Trần Phú, TT Hà Lam",
    "Nguyễn Thị Hiệp",
  ),
  OutletModel(
    "69201926",
    "LỆ TUÂN",
    "Ngã ba chợ Nón, Quế Thuận",
    "Nguyễn Thị Tú Mẫn",
  ),
  OutletModel(
    "69210054",
    "THỦY (KIM NGÂN)",
    "Ngã Ba Hương An, Quế Sơn",
    "Đoàn Thị Thu Hiền",
  ),
  OutletModel(
    "69221726",
    "CHI NGA (NGA)",
    "Chợ Bà Rén, Quế Sơn",
    "Nguyễn Kim Ngân",
  ),
  OutletModel(
    "69225423",
    "DIỆU KHƯƠNG (THỨC)",
    "438 Tiểu La, TT Hà Lam",
    "Nguyễn Thị Hiệp",
  ),
];

// --- MÀU SẮC & THEME ---
class AppColors {
  static const Color primaryCheckIn = Color(0xFF1976D2);
  static const Color primaryCheckOut = Color(0xFF009688);
  static const Color bgGrey = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
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

// --- DATA LIST SẢN PHẨM ---
final List<String> productList = [
  "Heineken Original 33cl",
  "Heineken Silver 33cl",
  "Heineken Silver 25cl",
  "Heineken 0.0 25cl",
  "Tiger Regular 33cl",
  "Tiger Regular 25cl",
  "Tiger Crystal 33cl",
  "Tiger Crystal 25cl",
  "Larue Special 33cl",
  "Larue Blue 33cl",
  "Larue Smooth 33cl",
  "Sản phẩm khác của HVN",
];
final List<String> giftList = [
  "Heineken Giftbox",
  "Tiger Giftbox",
  "Mainstream Giftbox",
  "Bao Lì xì",
];
final List<String> posmList = ["Standee", "Pallet"];

// --- HELPER WIDGETS ---
Widget _buildHeader(String title, Color color) {
  return Container(
    margin: const EdgeInsets.only(bottom: 15, top: 5),
    padding: const EdgeInsets.only(left: 10),
    decoration: BoxDecoration(
      border: Border(left: BorderSide(color: color, width: 4)),
    ),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 1,
      ),
    ),
  );
}

Widget _buildSectionCard({required Widget child}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

Widget _buildTextField(
  String label,
  TextEditingController controller,
  String saveKey,
  IconData icon, {
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (val) async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(saveKey, val);
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    ),
  );
}

// ĐÃ SỬA: Thêm tham số hintText, bỏ suffix mặc định
Widget _buildNumberInput(
  String label,
  TextEditingController controller,
  String saveKey, {
  String suffix = "",
  String hintText = "",
}) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    onChanged: (val) async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(saveKey, val);
    },
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffix,
      hintText: hintText, // Hint text (ví dụ: 100.000)
      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.4), fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      isDense: true,
    ),
  );
}

// --- MÀN HÌNH CHECK-IN ---
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

    for (var p in productList) {
      _qtyControllers[p] = TextEditingController();
      _priceControllers[p] = TextEditingController();
    }
    for (var g in giftList) _giftControllers[g] = TextEditingController();
    for (var p in posmList) _posmControllers[p] = TextEditingController();

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

      for (var p in productList) {
        _qtyControllers[p]?.text = prefs.getString('in_qty_$p') ?? "";
        _priceControllers[p]?.text = prefs.getString('in_price_$p') ?? "";
      }
      for (var g in giftList)
        _giftControllers[g]?.text = prefs.getString('in_gift_$g') ?? "";
      for (var p in posmList)
        _posmControllers[p]?.text = prefs.getString('in_posm_$p') ?? "";
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

  Future<void> _resetDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String today = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _dateController.text = today;
      prefs.setString('in_date', today);

      _noteController.clear();
      prefs.setString('in_note', '');
      for (var c in _qtyControllers.values) c.clear();
      for (var c in _giftControllers.values) c.clear();
      for (var c in _posmControllers.values) c.clear();

      for (var p in productList) prefs.remove('in_qty_$p');
      for (var g in giftList) prefs.remove('in_gift_$g');
      for (var p in posmList) prefs.remove('in_posm_$p');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã làm mới dữ liệu cho ngày hôm nay!")),
    );
  }

  void _copyReport() {
    StringBuffer sb = StringBuffer();
    sb.writeln("-> CHECKIN");
    sb.writeln("CHECK IN ĐẦU CA");
    sb.writeln("Ngày thực hiện: ${_dateController.text}");
    sb.writeln("SUP: ${_supController.text}");
    sb.writeln("SP: ${_selectedSP ?? ""}");
    sb.writeln("Cửa Hàng: ${_selectedOutletName ?? ""}");
    sb.writeln("Mã Outlet: ${_outletIdController.text}");
    sb.writeln("Địa Chỉ: ${_addressController.text}");

    sb.writeln("1/ Hàng hoá tồn đầu:");
    for (var p in productList) {
      String qty = _qtyControllers[p]?.text ?? "";
      String price = _priceControllers[p]?.text ?? "";
      if (qty.isNotEmpty || price.isNotEmpty) {
        sb.writeln("- $p (thùng): $qty  Giá bán: $price/thùng");
      } else {
        sb.writeln("- $p (thùng):   Giá bán:   /thùng");
      }
    }
    sb.writeln("2/ Quà tặng tồn đầu:");
    for (var g in giftList)
      sb.writeln("- $g (hộp/bao): ${_giftControllers[g]?.text}");
    sb.writeln("3/ POSM :");
    for (var p in posmList)
      sb.writeln("- $p (cái): ${_posmControllers[p]?.text}");
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader("Thông tin chung", AppColors.primaryCheckIn),
                IconButton(
                  icon: const Icon(
                    Icons.cleaning_services_rounded,
                    color: Colors.orange,
                  ),
                  onPressed: _resetDailyData,
                ),
              ],
            ),
            _buildSectionCard(
              child: Column(
                children: [
                  _buildTextField(
                    "Ngày thực hiện",
                    _dateController,
                    'in_date',
                    Icons.calendar_today,
                  ),
                  _buildTextField(
                    "SUP",
                    _supController,
                    'in_sup',
                    Icons.person,
                  ),

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
                        child: _buildTextField(
                          "Mã Outlet",
                          _outletIdController,
                          'in_outlet_id',
                          Icons.qr_code,
                        ),
                      ),
                    ],
                  ),
                  _buildTextField(
                    "Địa Chỉ",
                    _addressController,
                    'in_address',
                    Icons.location_on,
                  ),
                ],
              ),
            ),

            _buildHeader("1/ Hàng hoá tồn đầu", AppColors.primaryCheckIn),
            _buildSectionCard(
              child: Column(
                children: productList
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
                              child: _buildNumberInput(
                                "SL",
                                _qtyControllers[product]!,
                                'in_qty_$product',
                              ),
                            ),
                            const SizedBox(width: 5),
                            // ĐÃ SỬA: Hint 100.000, Bỏ chữ k
                            Expanded(
                              flex: 3,
                              child: _buildNumberInput(
                                "Giá",
                                _priceControllers[product]!,
                                'in_price_$product',
                                hintText: "100.000",
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            _buildHeader("2/ Quà tặng & POSM", AppColors.primaryCheckIn),
            _buildSectionCard(
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
                            child: _buildNumberInput(
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
                            child: _buildNumberInput(
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
            _buildHeader("Ghi chú", AppColors.primaryCheckIn),
            _buildSectionCard(
              child: _buildTextField(
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

// --- MÀN HÌNH CHECK-OUT ---
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
  final _feedbackController = TextEditingController();
  final Map<String, TextEditingController> _salesControllers = {};
  final Map<String, TextEditingController> _giftUsedControllers = {};

  @override
  void initState() {
    super.initState();
    _uniqueSPs = masterData.map((e) => e.spName).toSet().toList();
    for (var p in productList) _salesControllers[p] = TextEditingController();
    for (var g in giftList) _giftUsedControllers[g] = TextEditingController();
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
      _feedbackController.text = prefs.getString('out_feedback') ?? "";

      for (var p in productList)
        _salesControllers[p]?.text = prefs.getString('out_sales_$p') ?? "";
      for (var g in giftList)
        _giftUsedControllers[g]?.text = prefs.getString('out_gift_$g') ?? "";
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
      _feedbackController.clear();
      prefs.setString('out_feedback', '');
      for (var c in _salesControllers.values) c.clear();
      for (var c in _giftUsedControllers.values) c.clear();
      for (var p in productList) prefs.remove('out_sales_$p');
      for (var g in giftList) prefs.remove('out_gift_$g');
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Đã xoá số liệu bán hàng!")));
  }

  void _copyReport() {
    StringBuffer sb = StringBuffer();
    sb.writeln("-> Checkout:");
    sb.writeln("CHECK OUT CUỐI CA");
    sb.writeln("Ngày thực hiện: ${_dateController.text}");
    sb.writeln("SUP: ${_supController.text}");
    sb.writeln("SP: ${_selectedSP ?? ""}");
    sb.writeln("Cửa Hàng: ${_selectedOutletName ?? ""}");
    sb.writeln("Mã Outlet: ${_outletIdController.text}");
    sb.writeln("Địa Chỉ: ${_addressController.text}");
    sb.writeln("1/ Thông tin Traffic");
    sb.writeln("- Số khách hàng đến cửa hàng: ${_trafficTotalController.text}");
    sb.writeln(
      "- Số khách hàng chuyển đổi từ bia đối thủ: ${_trafficConvertController.text}",
    );
    sb.writeln("- Số khách hàng mua bia HVN: ${_trafficBuyHVNController.text}");
    sb.writeln("- Số khách mua bia: ${_trafficBuyBeerController.text}");
    int totalSales = 0;
    for (var c in _salesControllers.values)
      if (c.text.isNotEmpty) totalSales += int.tryParse(c.text) ?? 0;
    sb.writeln("2/ Tổng doanh số bán hàng (thùng) : ${totalSales} thùng");
    for (var p in productList) {
      String val = _salesControllers[p]?.text ?? "";
      sb.writeln("- $p: $val (thùng) + lon");
    }
    sb.writeln("3/ Quà tặng sử dụng:");
    for (var g in giftList)
      sb.writeln("- $g: ${_giftUsedControllers[g]?.text}");
    sb.writeln("Thuận lợi/ khó khăn : ${_feedbackController.text}");

    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép Check-out!'),
        backgroundColor: AppColors.primaryCheckOut,
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
        label: const Text("SAO CHÉP CHECK-OUT"),
        icon: const Icon(Icons.copy),
        backgroundColor: AppColors.primaryCheckOut,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader("Thông tin chung", AppColors.primaryCheckOut),
                IconButton(
                  icon: const Icon(
                    Icons.cleaning_services_rounded,
                    color: Colors.orange,
                  ),
                  onPressed: _resetDailySales,
                ),
              ],
            ),
            _buildSectionCard(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: DropdownButtonFormField<String>(
                      value: _selectedSP,
                      decoration: const InputDecoration(
                        labelText: "SP",
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                        filled: true,
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
                      decoration: const InputDecoration(
                        labelText: "Cửa Hàng",
                        prefixIcon: Icon(Icons.store),
                        border: OutlineInputBorder(),
                        filled: true,
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
                        child: _buildTextField(
                          "Mã Outlet",
                          _outletIdController,
                          'in_outlet_id',
                          Icons.qr_code,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _buildHeader("1/ Traffic & Doanh Số", AppColors.primaryCheckOut),
            _buildSectionCard(
              child: Column(
                children: [
                  _buildNumberInput(
                    "Khách đến",
                    _trafficTotalController,
                    'out_traffic_total',
                  ),
                  const SizedBox(height: 10),
                  _buildNumberInput(
                    "Khách chuyển đổi",
                    _trafficConvertController,
                    'out_traffic_convert',
                  ),
                  const SizedBox(height: 10),
                  _buildNumberInput(
                    "Mua bia HVN",
                    _trafficBuyHVNController,
                    'out_traffic_hvn',
                  ),
                  const SizedBox(height: 10),
                  _buildNumberInput(
                    "Tổng mua bia",
                    _trafficBuyBeerController,
                    'out_traffic_beer',
                  ),
                  const Divider(),
                  ...productList.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(p)),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: _buildNumberInput(
                              "Bán",
                              _salesControllers[p]!,
                              'out_sales_$p',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildHeader("Ghi chú", AppColors.primaryCheckOut),
            _buildSectionCard(
              child: _buildTextField(
                "Khó khăn/Thuận lợi...",
                _feedbackController,
                'out_feedback',
                Icons.feedback,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
