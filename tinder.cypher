// Create User nodes
CREATE (alice:User {name: 'Alice', age: 25, gender: 'Female', interests: ['music', 'movies']})
CREATE (bob:User {name: 'Bob', age: 28, gender: 'Male', interests: ['sports', 'travel']})
CREATE (carol:User {name: 'Carol', age: 22, gender: 'Female', interests: ['books', 'art']})
CREATE (dave:User {name: 'Dave', age: 30, gender: 'Male', interests: ['cooking', 'fitness']})
CREATE (eve:User {name: 'Eve', age: 27, gender: 'Female', interests: ['technology', 'travel']})
CREATE (frank:User {name: 'Frank', age: 29, gender: 'Male', interests: ['music', 'gaming']})

// Create LIKE relationships
MATCH (alice:User {name: 'Alice'}), (bob:User {name: 'Bob'})
CREATE (alice)-[:LIKES]->(bob);

MATCH (alice:User {name: 'Alice'}), (dave:User {name: 'Dave'})
CREATE (alice)-[:LIKES]->(dave);

MATCH (bob:User {name: 'Bob'}), (alice:User {name: 'Alice'})
CREATE (bob)-[:LIKES]->(alice);

MATCH (bob:User {name: 'Bob'}), (carol:User {name: 'Carol'})
CREATE (bob)-[:LIKES]->(carol);

MATCH (carol:User {name: 'Carol'}), (dave:User {name: 'Dave'})
CREATE (carol)-[:LIKES]->(dave);

MATCH (dave:User {name: 'Dave'}), (eve:User {name: 'Eve'})
CREATE (dave)-[:LIKES]->(eve);

MATCH (eve:User {name: 'Eve'}), (frank:User {name: 'Frank'})
CREATE (eve)-[:LIKES]->(frank);

MATCH (frank:User {name: 'Frank'}), (alice:User {name: 'Alice'})
CREATE (frank)-[:LIKES]->(alice);

// Create LIKE relationships
MATCH (alice:User {name: 'Alice'}), (frank:User {name: 'Frank'})
CREATE (alice)-[:DISLIKES]->(frank);

MATCH (bob:User {name: 'Bob'}), (eve:User {name: 'Eve'})
CREATE (bob)-[:DISLIKES]->(eve);

MATCH (carol:User {name: 'Carol'}), (frank:User {name: 'Frank'})
CREATE (carol)-[:DISLIKES]->(frank);

MATCH (dave:User {name: 'Dave'}), (alice:User {name: 'Alice'})
CREATE (dave)-[:DISLIKES]->(alice);

MATCH (eve:User {name: 'Eve'}), (bob:User {name: 'Bob'})
CREATE (eve)-[:DISLIKES]->(bob);

MATCH (frank:User {name: 'Frank'}), (carol:User {name: 'Carol'})
CREATE (frank)-[:DISLIKES]->(carol);

// Get all users
MATCH (u:User)
RETURN u;

// Get users and their LIKES
PROFILE MATCH (u:User)-[r:LIKES]->(liked:User)
RETURN u, r, liked;

//Get the MATCHES
MATCH (u1:User)-[:LIKES]->(u2:User)-[:LIKES]->(u1)
RETURN u1, u2;

//Updating relashionship
MATCH (a:User {name: 'Alice'})-[old:DISLIKES]->(f:User {name: 'Frank'})
DELETE old;
MATCH (a:User {name: 'Alice'}), (f:User {name: 'Frank'})
CREATE (a)-[:LIKES]->(f);

//Get the MATCHES
MATCH (u1:User)-[:LIKES]->(u2:User)-[:LIKES]->(u1)
RETURN u1, u2;

// Loads graph into memory
CALL gds.graph.project(
  'tinderGraph',
  'User',
  {
    LIKES: {
      type: 'LIKES',
      properties: []
    },
    DISLIKES: {
      type: 'DISLIKES',
      properties: []
    }
  }
);

// Run dijkstra algorithm
MATCH (source:User {name: 'Alice'}), (target:User {name: 'Eve'})
CALL gds.shortestPath.dijkstra.stream('tinderGraph', {
  sourceNode: source,
  targetNode: target,
  relationshipWeightProperty: null, // Assuming no specific weight property
  relationshipTypes: ['LIKES']      // Specify to only consider LIKES relationships
})
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN
  index,
  gds.util.asNode(sourceNode).name AS sourceNodeName,
  gds.util.asNode(targetNode).name AS targetNodeName,
  totalCost,
  [nodeId IN nodeIds | gds.util.asNode(nodeId).name] AS nodeNames,
  costs,
  path
ORDER BY index;

MATCH (n)
DETACH DELETE n;