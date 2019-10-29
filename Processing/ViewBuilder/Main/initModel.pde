// Initialize Model Elements from "Model" Tab
//
HashMap<String, Element> VIEW_ELEMENT;
CityScape world;
Facade scenario;

// Dimensions of our test case 
// (i.e. 50x50 grid with each cell 5 units wide)
//
int GRID_SCALE = 5;
int GRID_U = 50;
int GRID_V = 50;

// Initialize our View Evaluation Model
//
void initModel(int seed) {
  
  // 1. Define the weight (i.e. benefits) of having certain
  //    elements within your view, and their false color value.
  //
  VIEW_ELEMENT = new HashMap<String, Element>();
  VIEW_ELEMENT.put("sky", new Element("sky", 100.0, color(#AFDCFF)));
  VIEW_ELEMENT.put("land", new Element("land", 50.0, color(#A0C14E)));
  VIEW_ELEMENT.put("water", new Element("water", 100.0, color(#0000FF)));
  VIEW_ELEMENT.put("building", new Element("building", -50.0, color(#666666)));
  VIEW_ELEMENT.put("landmark", new Element("landmark", 400.0, color(#FF00FF)));
  VIEW_ELEMENT.put("tree", new Element("tree", 100.0, color(#007607)));
  
  // Print weights to console
  //
  for(Map.Entry e : VIEW_ELEMENT.entrySet()) {
    Element element = (Element)e.getValue();
    println(element.name + ": " + element.weight);
  }
  
  // Init World
  //
  world = new CityScape(GRID_U, GRID_V, seed);
  
  // Init Facade Scenario
  //
  int u = randomInt(world.U);
  int v = randomInt(world.V);
  // Ensure that scenario is on land:
  while(world.land[u][v] < world.OCEAN) {
    u = randomInt(world.U);
    v = randomInt(world.V);
  }
  // Constructor: Building(PVector location, int floors, float w, float h)
  PVector location = new PVector(u, v, world.land[u][v]); // z = elevation
  scenario = new Facade(location, 10, 0.9, 1);
}

int randomInt(float range) {
  return int(random(0, range));
}
