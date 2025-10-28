import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'order_model.dart';

class OrderQrPage extends StatefulWidget {
  final OrderCreateResponse order;
  const OrderQrPage({super.key, required this.order});

  @override
  State<OrderQrPage> createState() => _OrderQrPageState();
}

class _OrderQrPageState extends State<OrderQrPage> with TickerProviderStateMixin {
  static const int minAmt = 20;
  static const int maxAmt = 50000;
  final List<int> quicks = const [20, 100, 500, 5000, 10000, 50000];

  late final TabController _tab;
  final TextEditingController _amountCtrl = TextEditingController();
  int? _amount; // 选择/输入的金额

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  bool get _valid => _amount != null && _amount! >= minAmt && _amount! <= maxAmt;

  void _setAmount(int v) {
    setState(() {
      _amount = v;
      _amountCtrl.text = v.toString();
    });
  }

  void _onChanged(String v) {
    final n = int.tryParse(v);
    setState(() => _amount = n);
  }

  Future<void> _submit() async {
    if (!_valid) return;
    // 这里直接弹出 QR 对话框；若你要重新向后端申请该金额的支付单，可在这里调用接口后再展示
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: const Text('Scan to Pay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order: ${widget.order.orderId}   Amount: ₱$_amount'),
            const SizedBox(height: 12),
            Image.network(widget.order.qrCodeUrl, width: 220, height: 220, fit: BoxFit.cover),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Deposit')),
      body: Column(
        children: [
          // 顶部 Tabs
          Material(
            color: Colors.white,
            elevation: 1,
            child: TabBar(
              controller: _tab,
              isScrollable: true,
              labelColor: cs.primary,
              unselectedLabelColor: Colors.black87,
              indicatorColor: cs.primary,
              tabs: const [
                Tab(text: 'QRPH (1)'),
                Tab(text: 'E-wallet (4)'),
                Tab(text: 'Bank (16)'),
                Tab(text: 'OTC (3)'),
                Tab(text: 'Voucher'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _qrphPane(cs),
                _comingSoon('E-wallet'),
                _comingSoon('Bank'),
                _comingSoon('OTC'),
                _comingSoon('Voucher'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // —— QRPH 面板（按截图布局） ——
  Widget _qrphPane(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 推荐标签 + 渠道卡
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
            ),
            child: Row(
              children: [
                // 推荐角标
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1E6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFC7A6)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.recommend, size: 16, color: Colors.deepOrange),
                      SizedBox(width: 4),
                      Text('RECOMMEND', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // QRPh 标识
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFD6DFFF)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.qr_code_2, color: Color(0xFF3765F0)),
                      SizedBox(width: 6),
                      Text('QRPh', style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(width: 6),
                      Icon(Icons.verified, color: Colors.green, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 快速金额按钮
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quicks.map((v) {
              final bool active = _amount == v;
              return ChoiceChip(
                label: Text('+ $v'),
                selected: active,
                onSelected: (_) => _setAmount(v),
                selectedColor: cs.primary.withOpacity(.15),
                labelStyle: TextStyle(
                  color: active ? cs.primary : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: active ? cs.primary : Colors.black26),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // 金额输入框（₱ 前缀）
          TextField(
            controller: _amountCtrl,
            onChanged: _onChanged,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 6),
                child: Text('₱', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: 'Enter Amount: $minAmt–${_fmt(maxAmt)}',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(_valid ? Icons.check_circle : Icons.error_outline,
                  size: 18, color: _valid ? Colors.green : Colors.redAccent),
              const SizedBox(width: 6),
              Text(
                _valid ? '可提交的金额' : '范围需在 ₱$minAmt–${_fmt(maxAmt)}',
                style: TextStyle(color: _valid ? Colors.green : Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Submit 按钮（橙色、禁用时半透明）
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                disabledBackgroundColor: Colors.orangeAccent.withOpacity(.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: _valid ? _submit : null,
              child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  // 其他 Tab：占位
  Widget _comingSoon(String name) {
    return Center(
      child: Text('$name — Coming Soon', style: TextStyle(color: Colors.grey.shade600)),
    );
  }

  String _fmt(int n) {
    final s = n.toString();
    // 简单千分位（不引入 intl）
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      final left = s.length - i - 1;
      if (left > 0 && left % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }
}
