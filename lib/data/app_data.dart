import 'outlet_model.dart';

// DỮ LIỆU CỨNG
final List<OutletModel> masterData = [
  OutletModel("69214399", "NUTRIMART", "1 Đỗ Quang, Quế Sơn", "Nguyễn Thị Tú Mẫn"),
  OutletModel("69214632", "HƯƠNG NGUYỄN", "QL 1A, Quế Sơn", "Nguyễn Kim Ngân"),
  OutletModel("69211385", "ANH ĐÀO", "Quế Phú, Quế Sơn", "Đoàn Thị Thu Hiền"),
  OutletModel("69224803", "MINI HÀ PHƯƠNG", "4 Trần Phú, TT Hà Lam", "Nguyễn Thị Hiệp"),
  OutletModel("69201926", "LỆ TUÂN", "Ngã ba chợ Nón, Quế Thuận", "Nguyễn Thị Tú Mẫn"),
  OutletModel("69210054", "THỦY (KIM NGÂN)", "Ngã Ba Hương An, Quế Sơn", "Đoàn Thị Thu Hiền"),
  OutletModel("69221726", "NGA", "Chợ Bà Rén, Quế Sơn", "Nguyễn Kim Ngân"),
  OutletModel("69225423", "DIỆU KHƯƠNG (THỨC)", "438 Tiểu La, TT Hà Lam", "Nguyễn Thị Hiệp"),
];

// --- DATA LIST SẢN PHẨM ---
final List<String> _baseBeerList = [
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
];
// --- LIST CHO MÀN HÌNH CHECK-IN ---
final List<String> productListCheckIn = [
  ..._baseBeerList,
  "Sản phẩm khác của HVN:", // Dòng cuối dành riêng cho Check-in
];

// --- LIST CHO MÀN HÌNH CHECK-OUT ---
final List<String> productListCheckOut = [
  ..._baseBeerList,
  "Số bán HVN khác: (thùng)" // Dòng cuối dành riêng cho Check-out
];
final List<String> giftList = [
  "Heineken Giftbox (hộp)",
  "Tiger Giftbox (hộp)",
  "Mainstream Giftbox (hộp)",
  "Bao Lì xì (bao)",
];

final List<String> posmList = ["Standee", "Pallet"];