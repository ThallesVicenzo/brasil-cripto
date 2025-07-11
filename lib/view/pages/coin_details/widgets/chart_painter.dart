import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/view/utils/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view_model/utils/formatters/currency_formatter.dart';
import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final bool showLabels;
  final bool showCurrentPrice;
  final Offset? touchPosition;
  final Function(double value, Offset position)? onTouch;

  ChartPainter({
    required this.data,
    required this.color,
    this.showLabels = true,
    this.showCurrentPrice = true,
    this.touchPosition,
    this.onTouch,
  });

  final AppLocalizations intl = sl<GlobalAppLocalizations>().current;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final fillPaint =
        Paint()
          ..color = color.withValues(alpha: 0.1)
          ..style = PaintingStyle.fill;

    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) {
      final y = size.height / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }

    final path = Path();
    final fillPath = Path();

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x =
          data.length > 1
              ? (i / (data.length - 1)) * size.width
              : size.width / 2;
      final normalizedValue = (data[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));
    }

    final gridPaint =
        Paint()
          ..color = Colors.grey[300]!
          ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      fillPath.moveTo(0, size.height);
      fillPath.lineTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      }
      fillPath.lineTo(size.width, size.height);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);

      canvas.drawPath(path, paint);

      if (showLabels) {
        _drawLabels(canvas, size, minValue, maxValue);
      }

      if (points.length > 1) {
        _drawMinMaxPoints(canvas, points, minValue, maxValue);
      }

      if (touchPosition != null) {
        _drawTouchIndicator(canvas, size, points, minValue, maxValue);
      }
    }
  }

  void _drawMinMaxPoints(
    Canvas canvas,
    List<Offset> points,
    double minValue,
    double maxValue,
  ) {
    final minPointPaint =
        Paint()
          ..color = AppColors.negativeRed
          ..style = PaintingStyle.fill;

    final maxPointPaint =
        Paint()
          ..color = AppColors.positiveGreen
          ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      if (data[i] == minValue) {
        canvas.drawCircle(points[i], 4, minPointPaint);
      }
      if (data[i] == maxValue) {
        canvas.drawCircle(points[i], 4, maxPointPaint);
      }
    }
  }

  void _drawLabels(Canvas canvas, Size size, double minValue, double maxValue) {
    _drawLabel(
      canvas,
      CurrencyFormatter.formatCurrencyForCurrentLocale(
        maxValue,
        countryCode: intl.country_code,
      ),
      Offset(4, 8),
    );
    _drawLabel(
      canvas,
      CurrencyFormatter.formatCurrencyForCurrentLocale(
        minValue,
        countryCode: intl.country_code,
      ),
      Offset(4, size.height - 20),
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: AppColors.textGray,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  void _drawTouchIndicator(
    Canvas canvas,
    Size size,
    List<Offset> points,
    double minValue,
    double maxValue,
  ) {
    if (touchPosition == null || points.isEmpty) return;

    final closestPointIndex = _findClosestPointIndex(points, touchPosition!);
    final closestPoint = points[closestPointIndex];
    final value = data[closestPointIndex];

    final linePaint =
        Paint()
          ..color = AppColors.textGray.withValues(alpha: 0.5)
          ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(closestPoint.dx, 0),
      Offset(closestPoint.dx, size.height),
      linePaint,
    );

    final circlePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final circleBorderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawCircle(closestPoint, 6, circleBorderPaint);
    canvas.drawCircle(closestPoint, 4, circlePaint);

    _drawTooltip(canvas, size, closestPoint, value);

    onTouch?.call(value, closestPoint);
  }

  int _findClosestPointIndex(List<Offset> points, Offset touchPosition) {
    double minDistance = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < points.length; i++) {
      final distance = (points[i] - touchPosition).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  void _drawTooltip(Canvas canvas, Size size, Offset point, double value) {
    final text = CurrencyFormatter.formatCurrencyForCurrentLocale(
      value,
      countryCode: intl.country_code,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    const padding = 10.0;
    final tooltipWidth = textPainter.width + padding * 2;
    final tooltipHeight = textPainter.height + padding * 2;

    double tooltipX = point.dx - tooltipWidth / 2;
    double tooltipY = point.dy - tooltipHeight - 15;

    if (tooltipX < 4) tooltipX = 4;
    if (tooltipX + tooltipWidth > size.width - 4) {
      tooltipX = size.width - tooltipWidth - 4;
    }
    if (tooltipY < 4) tooltipY = point.dy + 15;

    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tooltipX + 2, tooltipY + 2, tooltipWidth, tooltipHeight),
      const Radius.circular(8),
    );

    final shadowPaint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;

    canvas.drawRRect(shadowRect, shadowPaint);

    final tooltipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
      const Radius.circular(8),
    );

    final tooltipPaint =
        Paint()
          ..color = color.withValues(alpha: 0.95)
          ..style = PaintingStyle.fill;

    canvas.drawRRect(tooltipRect, tooltipPaint);

    final borderPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    canvas.drawRRect(tooltipRect, borderPaint);

    textPainter.paint(canvas, Offset(tooltipX + padding, tooltipY + padding));
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.touchPosition != touchPosition;
  }
}
