import 'dart:ui';
import '../../../ffi/soloud_ffi.dart';
import 'chart_data.dart';

class ChartSonifier {
  final List<ChartData> data;

  ChartSonifier({required this.data});

  void playSoundAt(Offset position, double chartWidth) {
    final index =
        (position.dx / chartWidth * data.length)
            .clamp(0, data.length - 1)
            .toInt();
    final point = data[index];
    final price = point.price;

    final x = (position.dx / chartWidth - 0.5) * 2;
    final y = (1 - (position.dy / 250.0)) * 2 - 1;
    final z = (price % 10) / 5.0 - 1.0;

    play3d(x, y, z);
  }
}
