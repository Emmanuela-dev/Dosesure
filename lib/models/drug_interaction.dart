import 'package:flutter/material.dart';

// Drug Node for graph visualization
class DrugNode {
  final String id;
  final String name;
  final String category;
  final double radius;

  DrugNode({
    required this.id,
    required this.name,
    required this.category,
    this.radius = 40.0,
  });
}

// Drug Interaction Graph
class DrugInteractionGraph {
  final List<DrugNode> nodes;
  final List<GraphInteraction> interactions;

  DrugInteractionGraph({
    required this.nodes,
    required this.interactions,
  });

  bool hasHighSeverityInteractions(String drugId) {
    return interactions.any((i) =>
        (i.drug1Id == drugId || i.drug2Id == drugId) &&
        (i.severity == InteractionSeverity.high ||
            i.severity == InteractionSeverity.contraindicated));
  }

  List<GraphInteraction> getInteractionsForDrug(String drugId) {
    return interactions.where((i) => i.drug1Id == drugId || i.drug2Id == drugId).toList();
  }
}

// Graph Interaction (different from prescription DrugInteraction)
class GraphInteraction {
  final String id;
  final String drug1Id;
  final String drug2Id;
  final String description;
  final InteractionSeverity severity;
  final List<String> symptoms;
  final String recommendation;

  GraphInteraction({
    required this.id,
    required this.drug1Id,
    required this.drug2Id,
    required this.description,
    required this.severity,
    this.symptoms = const [],
    required this.recommendation,
  });

  Color get severityColor => severity.color;
}

// Simple DrugInteraction for prescription checking
class DrugInteraction {
  final String interactingDrugId;
  final String interactingDrugName;
  final String description;
  final InteractionSeverity severity;

  DrugInteraction({
    required this.interactingDrugId,
    required this.interactingDrugName,
    required this.description,
    required this.severity,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) {
    return DrugInteraction(
      interactingDrugId: json['interactingDrugId'] ?? '',
      interactingDrugName: json['interactingDrugName'] ?? '',
      description: json['description'] ?? '',
      severity: InteractionSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => InteractionSeverity.moderate,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interactingDrugId': interactingDrugId,
      'interactingDrugName': interactingDrugName,
      'description': description,
      'severity': severity.name,
    };
  }
}

enum InteractionSeverity {
  low,
  moderate,
  high,
  contraindicated;

  Color get color {
    switch (this) {
      case InteractionSeverity.low:
        return Colors.yellow[700]!;
      case InteractionSeverity.moderate:
        return Colors.orange;
      case InteractionSeverity.high:
        return Colors.red;
      case InteractionSeverity.contraindicated:
        return Colors.red[900]!;
    }
  }

  String get displayName {
    switch (this) {
      case InteractionSeverity.low:
        return 'Low';
      case InteractionSeverity.moderate:
        return 'Moderate';
      case InteractionSeverity.high:
        return 'High';
      case InteractionSeverity.contraindicated:
        return 'Contraindicated';
    }
  }
}
