import 'dart:async';

import 'package:brasil_cripto/app_injector.dart';
import 'package:brasil_cripto/l10n/global_app_localizations.dart';
import 'package:brasil_cripto/view/pages/coin_details/widgets/chart_painter.dart';
import 'package:brasil_cripto/view/pages/coin_details/widgets/chart_stats.dart';
import 'package:brasil_cripto/view/utils/widgets/colors/app_colors.dart';
import 'package:brasil_cripto/view/utils/widgets/text/app_text.dart';
import 'package:brasil_cripto/view_model/coin_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ChartSection extends StatefulWidget {
  const ChartSection({super.key, required this.viewModel});

  final CoinDetailsViewModel viewModel;

  @override
  State<ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<ChartSection> {
  final AppLocalizations intl = sl<GlobalAppLocalizations>().current;
  Offset? touchPosition;
  double? touchedValue;
  bool showTouchValue = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showTouchValue = false;
          touchPosition = null;
          touchedValue = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        if (showTouchValue) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final localPosition = renderBox.globalToLocal(
              details.globalPosition,
            );
            final containerHeight = renderBox.size.height;
            final chartAreaTop = containerHeight - 200 - 40;

            if (localPosition.dy < chartAreaTop) {
              _hideTimer?.cancel();
              setState(() {
                showTouchValue = false;
                touchPosition = null;
                touchedValue = null;
              });
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.transparentWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            if (widget.viewModel.hasError)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: AppText.small(
                      widget.viewModel.errorMessage,
                      style: MyTextStyle(
                        color: AppColors.negativeRed,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.viewModel.retryFetchData,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.positiveGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: AppText.small(
                        intl.try_again,
                        style: MyTextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (!widget.viewModel.hasError)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.large(
                        intl.price_chart,
                        style: MyTextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.viewModel.chartData.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              widget.viewModel.isChartPositive
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color:
                                  widget.viewModel.isChartPositive
                                      ? AppColors.positiveGreen
                                      : AppColors.negativeRed,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            AppText.mediumSmall(
                              '${widget.viewModel.chartPriceChangePercent >= 0 ? '+' : ''}${widget.viewModel.chartPriceChangePercent.toStringAsFixed(2)}%',
                              style: MyTextStyle(
                                color:
                                    widget.viewModel.isChartPositive
                                        ? AppColors.positiveGreen
                                        : AppColors.negativeRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (widget.viewModel.chartData.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ChartStats(viewModel: widget.viewModel),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children:
                        widget.viewModel.periodKeys.map((periodKey) {
                          final isSelected =
                              periodKey == widget.viewModel.selectedPeriodKey;
                          return Expanded(
                            child: GestureDetector(
                              onTap:
                                  () =>
                                      widget.viewModel.changePeriod(periodKey),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.positiveGreen
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: AppText.small(
                                    periodKey,
                                    style: MyTextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : AppColors.disabledGray,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (details) {
                      _hideTimer?.cancel();
                      setState(() {
                        touchPosition = details.localPosition;
                        showTouchValue = true;
                      });
                      _startHideTimer();
                    },
                    onPanUpdate: (details) {
                      _hideTimer?.cancel();
                      setState(() {
                        touchPosition = details.localPosition;
                        showTouchValue = true;
                      });
                    },
                    onPanEnd: (_) {
                      _startHideTimer();
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          widget.viewModel.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomPaint(
                                painter: ChartPainter(
                                  data: widget.viewModel.chartData,
                                  color:
                                      widget.viewModel.isChartPositive
                                          ? AppColors.positiveGreen
                                          : AppColors.negativeRed,
                                  showLabels: true,
                                  showCurrentPrice: true,
                                  touchPosition:
                                      showTouchValue ? touchPosition : null,
                                  onTouch: (value, position) {
                                    SchedulerBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) {
                                            setState(() {
                                              touchedValue = value;
                                            });
                                          }
                                        });
                                  },
                                ),
                              ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
