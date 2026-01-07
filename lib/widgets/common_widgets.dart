import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../utils/formatters.dart';

Widget buildHeader(String title, Color color) {
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

Widget buildSectionCard({required Widget child}) {
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

Widget buildTextField(
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
Widget buildNumberInput(
  String label,
  TextEditingController controller,
  String saveKey, {
  String suffix = "",
  String hintText = "",
  bool isCurrency = false,
}) {
  final showLabel = label.trim().isNotEmpty;

  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      if (isCurrency) ThousandsSeparatorInputFormatter(),
    ],
    onChanged: (val) async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(saveKey, val);
    },
    decoration: InputDecoration(
      // ✅ chỉ set labelText khi label có nội dung
      labelText: showLabel ? label : null,

      // ✅ hint sẽ luôn hiện khi ô đang rỗng (không cần focus)
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.withOpacity(0.6),
        fontSize: 12,
      ),

      // ✅ tránh label floating gây “nuốt” hint/nhìn khó chịu
      floatingLabelBehavior:
          showLabel ? FloatingLabelBehavior.auto : FloatingLabelBehavior.never,

      suffixText: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      isDense: true,
    ),
  );
}
