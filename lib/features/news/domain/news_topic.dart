/// Topic supportati da GNews via parametro `topic=`.
///
/// Nota: `all` significa "nessun filtro topic".
enum NewsTopic {
  all,
  world,
  nation,
  business,
  technology,
  science,
  health,
  sports,
  entertainment,
}

extension NewsTopicApi on NewsTopic {
  /// Valore da passare a GNews (`topic=`). `null` → non inviare il parametro.
  String? get apiValue {
    switch (this) {
      case NewsTopic.all:
        return null;
      case NewsTopic.world:
        return 'world';
      case NewsTopic.nation:
        return 'nation';
      case NewsTopic.business:
        return 'business';
      case NewsTopic.technology:
        return 'technology';
      case NewsTopic.science:
        return 'science';
      case NewsTopic.health:
        return 'health';
      case NewsTopic.sports:
        return 'sports';
      case NewsTopic.entertainment:
        return 'entertainment';
    }
  }
}

/// Ordine ufficiale dei topic per le chips UI.
const List<NewsTopic> kNewsTopics = <NewsTopic>[
  NewsTopic.all,
  NewsTopic.world,
  NewsTopic.nation,
  NewsTopic.business,
  NewsTopic.technology,
  NewsTopic.science,
  NewsTopic.health,
  NewsTopic.sports,
  NewsTopic.entertainment,
];