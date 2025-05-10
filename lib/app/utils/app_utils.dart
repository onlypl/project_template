import 'package:flutter/services.dart';

class AppUtils {
  static void copy(String value) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      //SmartDialog.showToast("复制成功".tr);
    } catch (e) {
      print(e);
    }
  }

  ///导出当前国际化语言的excel文件
  // static void exportLanguageExcel() async {
  //   var translations = AppTranslations().keys;
  //   translations.forEach((key, value) {
  //     print('key: $key');
  //     //print('value: $value');
  //   });
  //   var languageCN = translations['zh_CN'] ?? {};
  //   var languagePH = translations['fil_PH'] ?? {};
  //   var languageUS = translations['en_US'] ?? {};
  //   // 创建一个新的工作簿
  //   xlsio.Workbook workbook = xlsio.Workbook();
  //   // 添加一个工作表
  //   xlsio.Worksheet sheet = workbook.worksheets[0];
  //   sheet.getRangeByName('A1').text = 'Key值';
  //   sheet.getRangeByName('B1').text = '中文';
  //   sheet.getRangeByName('C1').text = '菲律宾语';
  //   sheet.getRangeByName('D1').text = '英语';
  //   int row = 2;
  //   for (var key in languageUS.keys) {
  //     sheet.getRangeByName('A$row').text = key;
  //     // sheet.getRangeByName('B$row').text = languageCN[key] ?? '';
  //     // sheet.getRangeByName('C$row').text = languagePH[key] ?? '';
  //     sheet.getRangeByName('D$row').text = languageUS[key] ?? '';
  //     row++;
  //   }
  //   // 保存文件
  //   List<int> bytes = workbook.saveAsStream();
  //   Directory documentsDirectory = await getApplicationDocumentsDirectory();
  //   print('文档目录: ${documentsDirectory.path}');
  //   final path = '${documentsDirectory.path}/languages.xlsx';
  //   File(path).writeAsBytes(bytes);
  //
  //   // 释放资源
  //   workbook.dispose();
  // }
}
