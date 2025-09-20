import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import 'wiki_detail.dart';

class CarePlanSearch extends StatelessWidget {
  const CarePlanSearch({super.key});

  final bgColor = const Color.fromARGB(255, 160, 173, 167);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor, // 半透明背景
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus(); // 點擊背景收起鍵盤
        },
        child: FractionallySizedBox(
          heightFactor: 0.95, // 幾乎全屏
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            autofocus: true, // 自動彈出鍵盤
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: '搜尋飼育計畫...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: darkTeal.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.filter_alt, color: Colors.white),
                          tooltip: '篩選',
                          onPressed: () {
                            // 這裡處理篩選功能
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Container(
                    color: bgColor,
                    child: _buildSearchResults(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // 設定圓角半徑
          ),
          child: ListTile(
            title: Text('飼育計畫 $index'),
            subtitle: const Text('副標題'),
          ),
        );
      },
    );
  }
}
