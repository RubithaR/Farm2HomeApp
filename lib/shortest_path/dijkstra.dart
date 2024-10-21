class Graph {
  final Map<String, Map<String, double>> _nodes = {};

  // Add a node to the graph
  void addNode(String node) {
    _nodes[node] = {};
  }

  // Add an edge to the graph
  void addEdge(String from, String to, double weight) {
    if (!_nodes.containsKey(from)) {
      addNode(from);
    }
    if (!_nodes.containsKey(to)) {
      addNode(to);
    }
    _nodes[from]![to] = weight; // Add the edge with weight
  }

  // Dijkstra's algorithm
  Map<String, double> dijkstra(String startNode) {
    final distances = <String, double>{};
    final priorityQueue = <String>[];
    final visited = <String>{};

    // Initialize distances
    for (var node in _nodes.keys) {
      distances[node] = double.infinity; // Set all distances to infinity
    }
    distances[startNode] = 0; // Distance to the start node is 0
    priorityQueue.add(startNode);

    while (priorityQueue.isNotEmpty) {
      // Get the node with the smallest distance
      String currentNode = priorityQueue.reduce((a, b) => distances[a]! < distances[b]! ? a : b);
      priorityQueue.remove(currentNode);
      visited.add(currentNode);

      // Update distances for neighbors
      for (var entry in _nodes[currentNode]!.entries) {
        String neighbor = entry.key;
        double weight = entry.value;

        if (!visited.contains(neighbor)) {
          double newDistance = distances[currentNode]! + weight;
          if (newDistance < distances[neighbor]!) {
            distances[neighbor] = newDistance;
            priorityQueue.add(neighbor);
          }
        }
      }
    }

    return distances;
  }

  // Find the shortest path using the distances
  List<String> findShortestPath(String startNode, String endNode) {
    final distances = dijkstra(startNode);
    final path = <String>[];
    var currentNode = endNode;

    if (!_nodes.containsKey(currentNode)) {
      print("End node $endNode is not in the graph nodes.");
      return [];
    }

    while (currentNode != startNode) {
      path.add(currentNode);

      if (!distances.containsKey(currentNode)) {
        print("Current node $currentNode is not in distances.");
        return []; // No valid path found
      }

      currentNode = _nodes[currentNode]!
          .entries
          .where((entry) => distances[currentNode]! - entry.value == distances[entry.key])
          .map((entry) => entry.key)
          .isNotEmpty
          ? _nodes[currentNode]!
          .entries
          .where((entry) => distances[currentNode]! - entry.value == distances[entry.key])
          .first
          .key
          : startNode; // Fallback to startNode if no valid previous node is found
    }

    path.add(startNode);
    return path.reversed.toList();
  }
}
