HashMap<String, Element> VIEW_ELEMENT;
Environment world;
Building scenario;

int GRID_SCALE = 5;
int GRID_U = 50;
int GRID_V = 50;

void initModel(int seed) {
  // Define the weight (benefits) of having 
  // certain elements within your view
  VIEW_ELEMENT = new HashMap<String, Element>();
  VIEW_ELEMENT.put("sky", new Element("sky", 100.0, color(#AFDCFF)));
  VIEW_ELEMENT.put("land", new Element("land", 50.0, color(#A0C14E)));
  VIEW_ELEMENT.put("water", new Element("water", 100.0, color(#0000FF)));
  VIEW_ELEMENT.put("building", new Element("building", -50.0, color(#666666)));
  VIEW_ELEMENT.put("tree", new Element("tree", 100.0, color(#009900)));
  
  // Print weights to console
  for(Map.Entry e : VIEW_ELEMENT.entrySet()) {
    Element element = (Element)e.getValue();
    println(element.name + ": " + element.weight, + element.col);
  }
  
  // Init World
  world = new Environment(GRID_U, GRID_V, seed);
  
  // Init building scenario
  int u = randomInt(world.U);
  int v = randomInt(world.V);
  while(world.land[u][v] < world.OCEAN) {
    u = randomInt(world.U);
    v = randomInt(world.V);
  }
  // Constructor: Building(PVector location, int floors, float w, float h)
  PVector location = new PVector(u, v, world.land[u][v]);
  scenario = new Building(location, 10, 0.9, 1);
}
