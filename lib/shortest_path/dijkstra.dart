class Graph {
  final Map<String, Map<String, double>> _adjacencyList = {};

  void addEdge(String from, String to, double weight) {
    _adjacencyList.putIfAbsent(from, () => {});
    _adjacencyList[from]![to] = weight;

    // For an undirected graph
    _adjacencyList.putIfAbsent(to, () => {});
    _adjacencyList[to]![from] = weight;
  }

  Map<String, double> shortestPath(String start) {
    Map<String, double> distances = {};
    Map<String, String?> previousNodes = {};
    Set<String> unvisited = Set.from(_adjacencyList.keys);

    // Initialize distances
    _adjacencyList.keys.forEach((node) {
      distances[node] = double.infinity;
    });
    distances[start] = 0;

    while (unvisited.isNotEmpty) {
      // Find the node with the smallest distance
      String currentNode = unvisited.reduce((a, b) => distances[a]! < distances[b]! ? a : b);
      unvisited.remove(currentNode);

      // Update neighbors
      if (_adjacencyList[currentNode] != null) {
        _adjacencyList[currentNode]!.forEach((neighbor, weight) {
          double newDist = distances[currentNode]! + weight;
          if (newDist < distances[neighbor]!) {
            distances[neighbor] = newDist;
            previousNodes[neighbor] = currentNode;
          }
        });
      }
    }

    return distances;
  }
}
