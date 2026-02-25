import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/drug_interaction.dart';

class DrugInteractionGraphWidget extends StatefulWidget {
  final DrugInteractionGraph graph;
  final Function(String drugId)? onDrugSelected;
  final Function(GraphInteraction interaction)? onInteractionSelected;
  final Color primaryColor;

  const DrugInteractionGraphWidget({
    super.key,
    required this.graph,
    this.onDrugSelected,
    this.onInteractionSelected,
    this.primaryColor = Colors.blue,
  });

  @override
  State<DrugInteractionGraphWidget> createState() =>
      _DrugInteractionGraphWidgetState();
}

class _DrugInteractionGraphWidgetState
    extends State<DrugInteractionGraphWidget> {
  String? _selectedDrugId;
  Offset _center = Offset.zero;
  double _scale = 1.0;
  final List<math.Point<double>> _nodePositions = [];

  @override
  void initState() {
    super.initState();
    _arrangeNodesInCircle();
  }

  void _arrangeNodesInCircle() {
    final nodes = widget.graph.nodes;
    if (nodes.isEmpty) return;

    _nodePositions.clear();
    final radius = 120.0;
    final angleStep = (2 * math.pi) / nodes.length;

    for (int i = 0; i < nodes.length; i++) {
      final angle = angleStep * i - math.pi / 2;
      _nodePositions.add(math.Point(
        radius * math.cos(angle),
        radius * math.sin(angle),
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        return GestureDetector(
          onTapUp: (details) => _handleTap(details.localPosition, context),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: _DrugGraphPainter(
                    graph: widget.graph,
                    nodePositions: _nodePositions,
                    center: _center,
                    scale: _scale,
                    selectedDrugId: _selectedDrugId,
                    primaryColor: widget.primaryColor,
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: _buildLegend(context),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildInteractionCount(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Severity Level',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _buildLegendItem('Low', InteractionSeverity.low.color),
            _buildLegendItem('Moderate', InteractionSeverity.moderate.color),
            _buildLegendItem('High', InteractionSeverity.high.color),
            _buildLegendItem('Contraindicated',
                InteractionSeverity.contraindicated.color),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildInteractionCount(BuildContext context) {
    final totalInteractions = widget.graph.interactions.length;
    final highSeverity = widget.graph.interactions
        .where((i) => i.severity == InteractionSeverity.high)
        .length;
    final contraindicated = widget.graph.interactions
        .where((i) => i.severity == InteractionSeverity.contraindicated)
        .length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Interactions: $totalInteractions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (highSeverity > 0)
              Text(
                'High: $highSeverity',
                style: TextStyle(
                    color: InteractionSeverity.high.color, fontSize: 12),
              ),
            if (contraindicated > 0)
              Text(
                'Contraindicated: $contraindicated',
                style: TextStyle(
                    color: InteractionSeverity.contraindicated.color, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset localPosition, BuildContext context) {
    final adjustedPosition = localPosition - _center;

    for (int i = 0; i < widget.graph.nodes.length; i++) {
      final node = widget.graph.nodes[i];
      final position = _nodePositions[i] * _scale;
      final distance = math.Point(adjustedPosition.dx, adjustedPosition.dy).distanceTo(position);
      
      if (distance <= node.radius) {
        setState(() {
          _selectedDrugId = _selectedDrugId == node.id ? null : node.id;
        });
        widget.onDrugSelected?.call(node.id);
        _showDrugDetails(node, context);
        return;
      }
    }

    // Check for interaction tap
    for (final interaction in widget.graph.interactions) {
      final idx1 = widget.graph.nodes.indexWhere((n) => n.id == interaction.drug1Id);
      final idx2 = widget.graph.nodes.indexWhere((n) => n.id == interaction.drug2Id);
      
      if (idx1 >= 0 && idx2 >= 0) {
        final pos1 = _nodePositions[idx1] * _scale;
        final pos2 = _nodePositions[idx2] * _scale;
        
        if (_isPointOnLine(adjustedPosition, pos1, pos2, 8)) {
          widget.onInteractionSelected?.call(interaction);
          return;
        }
      }
    }

    setState(() {
      _selectedDrugId = null;
    });
  }

  bool _isPointOnLine(Offset point, math.Point<double> lineStart, math.Point<double> lineEnd, double tolerance) {
    final lineVector = math.Point(lineEnd.x - lineStart.x, lineEnd.y - lineStart.y);
    final pointVector = math.Point(point.dx - lineStart.x, point.dy - lineStart.y);

    final lineLength = math.sqrt(lineVector.x * lineVector.x + lineVector.y * lineVector.y);
    if (lineLength == 0) return false;

    final projection = (pointVector.x * lineVector.x + pointVector.y * lineVector.y) / lineLength;

    if (projection < 0 || projection > lineLength) return false;

    final perpendicularDistance = (pointVector.x * lineVector.y - pointVector.y * lineVector.x).abs() / lineLength;
    return perpendicularDistance <= tolerance;
  }

  void _showDrugDetails(DrugNode node, BuildContext context) {
    final interactions = widget.graph.getInteractionsForDrug(node.id);
    final hasHighRisk = widget.graph.hasHighSeverityInteractions(node.id);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasHighRisk ? Icons.warning : Icons.medication,
                  color: hasHighRisk ? Colors.red : widget.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${node.category}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Text(
              'Interactions (${interactions.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (interactions.isEmpty)
              const Text('No known interactions')
            else
              ...interactions.map((interaction) => _buildInteractionItem(interaction, node.id)),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionItem(GraphInteraction interaction, String currentDrugId) {
    final otherDrugId = interaction.drug1Id == currentDrugId ? interaction.drug2Id : interaction.drug1Id;
    final otherDrug = widget.graph.nodes.firstWhere((n) => n.id == otherDrugId);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: interaction.severityColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  interaction.severity == InteractionSeverity.contraindicated
                      ? Icons.cancel
                      : interaction.severity == InteractionSeverity.high
                          ? Icons.error
                          : Icons.warning,
                  color: interaction.severityColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${otherDrug.name} + ${interaction.severity.displayName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: interaction.severityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              interaction.description,
              style: const TextStyle(fontSize: 14),
            ),
            if (interaction.symptoms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Symptoms: ${interaction.symptoms.join(', ')}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      interaction.recommendation,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrugGraphPainter extends CustomPainter {
  final DrugInteractionGraph graph;
  final List<math.Point<double>> nodePositions;
  final Offset center;
  final double scale;
  final String? selectedDrugId;
  final Color primaryColor;

  _DrugGraphPainter({
    required this.graph,
    required this.nodePositions,
    required this.center,
    required this.scale,
    this.selectedDrugId,
    this.primaryColor = Colors.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    // Draw edges first
    _drawEdges(canvas);

    // Draw nodes
    _drawNodes(canvas);

    canvas.restore();
  }

  void _drawEdges(Canvas canvas) {
    for (final interaction in graph.interactions) {
      final idx1 = graph.nodes.indexWhere((n) => n.id == interaction.drug1Id);
      final idx2 = graph.nodes.indexWhere((n) => n.id == interaction.drug2Id);

      if (idx1 >= 0 && idx2 >= 0 && idx1 < nodePositions.length && idx2 < nodePositions.length) {
        final pos1 = nodePositions[idx1];
        final pos2 = nodePositions[idx2];

        final paint = Paint()
          ..color = interaction.severityColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _getEdgeWidth(interaction);

        _drawDashedLine(canvas, pos1, pos2, paint);
        _drawInteractionIndicator(canvas, pos1, pos2, interaction);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, math.Point<double> start, math.Point<double> end, Paint paint) {
    final dashInterval = 12.0;
    final dashLength = 6.0;
    final totalLength = math.Point(start.x, start.y).distanceTo(math.Point(end.x, end.y));
    final dashCount = (totalLength / dashInterval).floor();

    final dx = end.x - start.x;
    final dy = end.y - start.y;

    for (int i = 0; i < dashCount; i++) {
      final startRatio = (i * dashInterval) / totalLength;
      final endRatio = ((i * dashInterval) + dashLength) / totalLength;

      final dashStart = Offset(
        start.x + dx * startRatio,
        start.y + dy * startRatio,
      );
      final dashEnd = Offset(
        start.x + dx * endRatio,
        start.y + dy * endRatio,
      );

      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  void _drawInteractionIndicator(
      Canvas canvas, math.Point<double> start, math.Point<double> end, GraphInteraction interaction) {
    final midpoint = Offset(
      (start.x + end.x) / 2,
      (start.y + end.y) / 2,
    );

    // Draw circle background
    final circlePaint = Paint()
      ..color = interaction.severityColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(midpoint, 10, circlePaint);

    // Draw severity indicator
    String icon;
    switch (interaction.severity) {
      case InteractionSeverity.low:
        icon = '!';
      case InteractionSeverity.moderate:
        icon = '!!';
      case InteractionSeverity.high:
        icon = '!!!';
      case InteractionSeverity.contraindicated:
        icon = '✕';
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: icon,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      midpoint - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  double _getEdgeWidth(GraphInteraction interaction) {
    switch (interaction.severity) {
      case InteractionSeverity.low:
        return 2.0;
      case InteractionSeverity.moderate:
        return 3.0;
      case InteractionSeverity.high:
        return 4.0;
      case InteractionSeverity.contraindicated:
        return 5.0;
    }
  }

  void _drawNodes(Canvas canvas) {
    for (int i = 0; i < graph.nodes.length; i++) {
      final node = graph.nodes[i];
      final position = nodePositions[i];
      final isSelected = node.id == selectedDrugId;
      final hasInteractions = graph.hasHighSeverityInteractions(node.id);

      // Draw node circle
      Color fillColor;
      if (isSelected) {
        fillColor = primaryColor;
      } else if (hasInteractions) {
        fillColor = Colors.red.shade100;
      } else {
        fillColor = Colors.blue.shade100;
      }

      final circlePaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(position.x, position.y), node.radius, circlePaint);

      // Draw selection ring
      if (isSelected) {
        final ringPaint = Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        canvas.drawCircle(Offset(position.x, position.y), node.radius + 5, ringPaint);
      }

      // Draw warning indicator
      if (hasInteractions && !isSelected) {
        final warningPaint = Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(position.x + node.radius - 10, position.y - node.radius + 10),
          8,
          warningPaint,
        );
      }

      // Draw drug name
      final textPainter = TextPainter(
        text: TextSpan(
          text: _truncateText(node.name, 10),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: node.radius * 2 - 8);
      textPainter.paint(
        canvas,
        Offset(position.x, position.y) - Offset(textPainter.width / 2, textPainter.height / 2),
      );

      // Draw category label below
      final categoryPainter = TextPainter(
        text: TextSpan(
          text: _truncateText(node.category, 14),
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      categoryPainter.layout(maxWidth: node.radius * 2);
      categoryPainter.paint(
        canvas,
        Offset(position.x, position.y + node.radius + 4) -
            Offset(categoryPainter.width / 2, 0),
      );
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 2)}..';
  }

  @override
  bool shouldRepaint(_DrugGraphPainter oldDelegate) {
    return oldDelegate.graph != graph ||
        oldDelegate.nodePositions != nodePositions ||
        oldDelegate.center != center ||
        oldDelegate.scale != scale ||
        oldDelegate.selectedDrugId != selectedDrugId;
  }
}
