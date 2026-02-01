import 'dart:ui';
import 'dart:math' as math;

/// Severity levels for drug interactions
enum InteractionSeverity {
  low('Low', Color(0xFF4CAF50)),
  moderate('Moderate', Color(0xFFFF9800)),
  high('High', Color(0xFFF44336)),
  contraindicated('Contraindicated', Color(0xFF9C27B0));

  final String displayName;
  final Color color;
  const InteractionSeverity(this.displayName, this.color);
}

/// Represents a single drug in the interaction graph
class DrugNode {
  final String id;
  final String name;
  final String category; // e.g., "Anticoagulant", "Antihypertensive"
  final math.Point<double> position;
  final double radius;

  DrugNode({
    required this.id,
    required this.name,
    required this.category,
    this.position = const math.Point<double>(0, 0),
    this.radius = 40,
  });
}

/// Represents an interaction between two drugs
class DrugInteraction {
  final String id;
  final String drug1Id;
  final String drug2Id;
  final String description;
  final InteractionSeverity severity;
  final List<String> symptoms; // List of symptoms if this interaction occurs
  final String recommendation;

  DrugInteraction({
    required this.id,
    required this.drug1Id,
    required this.drug2Id,
    required this.description,
    required this.severity,
    required this.symptoms,
    required this.recommendation,
  });

  /// Get the severity color for this interaction
  Color get severityColor => severity.color;
}

/// Drug interaction graph data containing nodes and edges
class DrugInteractionGraph {
  final List<DrugNode> nodes;
  final List<DrugInteraction> interactions;

  DrugInteractionGraph({
    required this.nodes,
    required this.interactions,
  });

  /// Get all interactions for a specific drug
  List<DrugInteraction> getInteractionsForDrug(String drugId) {
    return interactions
        .where((interaction) =>
            interaction.drug1Id == drugId || interaction.drug2Id == drugId)
        .toList();
  }

  /// Check if a drug has any high severity interactions
  bool hasHighSeverityInteractions(String drugId) {
    return getInteractionsForDrug(drugId).any(
      (interaction) =>
          interaction.severity == InteractionSeverity.high ||
          interaction.severity == InteractionSeverity.contraindicated,
    );
  }

  /// Get all interacting drug pairs
  List<String> getInteractingDrugPairs() {
    return interactions.map((e) => '${e.drug1Id}-${e.drug2Id}').toList();
  }
}
