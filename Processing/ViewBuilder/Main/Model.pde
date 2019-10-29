// The Element class describes a particular type of element we 
// might see in a given view, such as a tree.
//
class Element {
  
  // The name of our element (e.g. "sky")
  String name;
  
  // The magnitude of the element's view desirability
  // For example, +100 is very good, -50 is very bad
  //
  float weight; 
  
  // The false color representation of this object
  //
  color col;
  
  Element(String name, float weight, color col) {
    this.name = name;
    this.weight = weight;
    this.col = col;
  }
}

// Returns the element with the color value that most closely
// resembles the input color passed to it using a least-
// sum-squares method.
//
Element nearest(HashMap<String, Element> reference, color input) {
  Element nearest = null;
  float shortest_distance = Float.POSITIVE_INFINITY;
  for(Map.Entry e : reference.entrySet()) {
    Element element = (Element)e.getValue();
    float distance = sq(hue(input) - hue(element.col)) + 
                     sq(saturation(input) - saturation(element.col)) + 
                     sq(brightness(input) - brightness(element.col));
    if(distance < shortest_distance) {
      shortest_distance = 0 + distance;
      nearest = element;
    }
  } 
  return nearest;
}

// The Facade of a Building from which we are generating "Views"
// Intialized as a 4-sided building (i.e. square footprint)
// with specified number of stories. For each side of each story,
// A View() object is generated to represent a curtain window.
//
class Facade {
  
  // Location of Facade 
  //
  PVector location;
  
  // Number of floors/stories of Facade
  //
  int floors;
  
  // w = width of each window (i.e. building width)
  // h = height of each window (i.e. floor height)
  // window = collection of windows that comprise the facade
  // windowIndex = specific window of analysis
  //
  float w, h;
  ArrayList<View> window;
  int windowIndex;
  
  // if true, situate camera from point of view of specific window/View
  //
  boolean setCamera;

  // if true, automatically calculate all scores
  //
  boolean calcViewScores;
  
  //Average View Score for Entire Facade
  float viewScore;
  
  Facade(PVector location, int floors, float w, float h) {
    this.location = location;
    this.floors = floors;
    this.w = w;
    this.h = h;
    calcViewScores = false;
    setCamera = false;
    window = new ArrayList<View>();
    windowIndex = 2*floors - 1; // initial window index
    viewScore = 0;
    
    // Creates the window for each side of each floor
    //
    for(int i=0; i<floors; i++) {
      for (int j=0; j<4; j++) { // 4 sides of a square-plan building
      
        // direction = the direction that a hypothetical person is looking
        // from = origin of a person's hypothetical view
        //
        PVector direction = new PVector(0, 0, 0);
        PVector from = new PVector(location.x, location.y, location.z + h*(0.5 + i));
        
        // Adjust each vector depending on side of building
        //
        if (j==0) {
          direction.x = -1;
          from.x += -0.5*w;
        } else if (j==1) {
          direction.y = -1;
          from.y += -0.5*w;
        } else if (j==2) {
          direction.x = +1;
          from.x += +0.5*w;
        } else if (j==3) {
          direction.y = +1;
          from.y += +0.5*w;
        }
        
        // Add window to facade:
        //
        View v = new View(w, h, from, direction);
        window.add(v);
      }
    }
  }
  
  // Run Evaluation Algorithm on current window
  // iterates windowIndex to next position
  //
  void evaluateCurrent() {
    if(calcViewScores) {
      window.get(windowIndex).evaluate();
      if(windowIndex < window.size() - 1) {
        windowIndex++;
      } else {
        calcViewScores = false;
        
        // Calculate average viewScore
        //
        for(View v : window) viewScore += v.viewScore;
        viewScore /= window.size();
      }
    }
  }
  
  void nextWindow() {
    if(windowIndex == window.size()-1) {
      windowIndex = 0;
    } else {
      windowIndex++;
    }
  }
  
  void prevWindow() {
    if(windowIndex == 0) {
      windowIndex = window.size()-1;
    } else {
      windowIndex--;
    }
  }
  
}

// A subset of the building's surface that we are analysing
// for view quality. Synonomous with a "window", for instance
//
class View {
  
  // Vectors describing view origin and direction
  //
  PVector viewDirection, viewFrom;
  
  // width and height of view/window
  //
  float w, h; 
  
  // 4 points the describe corners of window
  //
  ArrayList<PVector> points;
  
  // A graphics object that holds the 2D bitmap of the 
  // false-colored wndow view
  //
  PImage capture;
  
  // A low-resolution 2D matrix for storing collection 
  // of scores on image.
  //
  Float[][] score_raster;
  
  // Resolution of the score_raster in both u and v directions
  // (i.e. 1 cell = [res] pixels)
  //
  float res_u, res_v;
  
  // A simplified graphic that renders the score of each 
  // cell in the score_raster
  //
  PGraphics score_graphic;
  
  // The aggregated view score for the entire view 
  // (i.e. average of score_raster values)
  float viewScore;
  
  View(float w, float h, PVector viewFrom, PVector viewDirection) {
    this.w = w;
    this.h = h;
    this.viewFrom = viewFrom;
    this.viewDirection = viewDirection;
    viewScore = 0;
    
    // Calculation of window corner locations
    //
    float offset_x, offset_y;
    if(viewDirection.x == 0) {
      offset_x = 0.5*w;
      offset_y = 0;
    } else {
      offset_x = 0;
      offset_y = 0.5*w;
    }
    points = new ArrayList<PVector>();
    points.add(new PVector(viewFrom.x - offset_x, viewFrom.y - offset_y, viewFrom.z + 0.5*h));
    points.add(new PVector(viewFrom.x + offset_x, viewFrom.y + offset_y, viewFrom.z + 0.5*h));
    points.add(new PVector(viewFrom.x + offset_x, viewFrom.y + offset_y, viewFrom.z - 0.5*h));
    points.add(new PVector(viewFrom.x - offset_x, viewFrom.y - offset_y, viewFrom.z - 0.5*h));
  }
  
  // Set the 3D camera position and angle at a given view
  //
  void viewCam(float uv_scale, float z_scale) {
    
    float iX = uv_scale*viewFrom.x;
    float iY = uv_scale*viewFrom.y;
    float iZ = z_scale*viewFrom.z;
    float oX = uv_scale*(viewFrom.x + viewDirection.x);
    float oY = uv_scale*(viewFrom.y + viewDirection.y);
    float oZ = z_scale*(viewFrom.z + viewDirection.z);
    float rX =  0;
    float rY =  0;
    float rZ = -1;
    
    noLights();
    camera(iX, iY, iZ, oX, oY, oZ, rX, rY, rZ);
  }
  
  // Capture a given view, evaluate its score, and render the 
  // disaggreated score onto a score_graphic.
  //
  void evaluate() {
    if(capture == null) {
      
      // 1. Saves the screen canvas to "capture" graphics object
      //
      capture = get(); 
      
      // 2. Evaluate the view
      //
      viewScore = evaluateView(capture); 
      
      // 3. Write the intermediate score calculations to a 
      //    score_graphic
      //
      generateScoreGraphic(); 
    }
  }
  
  // For each cell in score_raster, determine a score based 
  // on the element that is most closesly associated with
  // the false color of the image.
  //
  float evaluateView(PImage view) {
    
    // number of cells to horizontally divide bitmap
    //
    int div_u = 40; 
    int div_v = 20; 
    
    score_raster = new Float[div_u][div_v];
    res_u = float(width)/div_u;
    res_v = float(height)/div_v;
    
    float score = 0;
    for(int i=0; i<div_u; i++) {
      for(int j=0; j<div_v; j++) {
        
        // Retrieve the color value at a given location in the image
        //
        int x = int( res_u * (0.5 + i) );
        int y = int( res_v * (0.5 + j) );
        color c = view.get(x, y); 
        Element current = nearest(VIEW_ELEMENT, c);
        
        // Set Scores based on reference element
        //
        score_raster[i][j] = current.weight;
        score += current.weight;
      }
    }
    score /= (score_raster.length * score_raster[0].length);
    println("Score: " + score);
    return score;
  }
  
  // Write the intermediate view score calculations to a score_graphic
  //
  void generateScoreGraphic() {
    score_graphic = createGraphics(width, height);
    score_graphic.beginDraw();
    score_graphic.stroke(255);
    score_graphic.textAlign(CENTER, CENTER);
    for(int i=0; i<score_raster.length; i++) {
      for(int j=0; j<score_raster[0].length; j++) {
        float hue = map(score_raster[i][j], 0, 100, 0, 100);
        score_graphic.colorMode(HSB);
        score_graphic.fill(hue, 255, 255, 100);
        score_graphic.colorMode(RGB);
        score_graphic.rect(i*res_u, j*res_v, res_u, res_v);
      }
    }
    score_graphic.endDraw();
  }
}

// This class is used to quickly build a random "blocky" cityscape 
// associated with our elements. Ideally, a CityScape is 
// generated from actual geospatial data of known surroundings
// adjacent to an actual site.
//
class CityScape {
  
  // defines the size our city (i.e. 200 x 200 tiles)
  //
  int U, V; 
  
  // Defines the minimum and maximum land elevantions in our cityscape,
  // as well as the elevation at which water level is defined
  //
  float E_MIN = -0.0; 
  float E_MAX = 25.0;
  float OCEAN = 10.0;
  
  // A 2D matrix of values that describe each tile's elevation
  //
  Float[][] land;
  
  // A list of the locations of various objects
  //
  ArrayList<PVector> buildings;
  ArrayList<PVector> landmarks;
  ArrayList<PVector> trees;
  
  CityScape(int U, int V, int seed) {
    
    this.U = U;
    this.V = V;
    
    land = new Float[U][V];
    buildings = new ArrayList<PVector>();
    landmarks = new ArrayList<PVector>();
    trees = new ArrayList<PVector>();
    
    // Generate Land using a noise function included with a Perlin Noise function
    //
    perlinElevation(seed);
    
    // Generate Buildings
    //
    int num_buildings = 500;
    randomBuildings(num_buildings);
    
    // Generate Landmarks
    //
    int num_landmarks = 10;
    randomLandmarks(num_landmarks);
    
    // Generate Trees
    //
    int num_trees = 2000;
    randomTrees(num_trees);
  }
  
  // Generates an elevation for all tiles according to a Perlin Noise Function
  //
  void perlinElevation(int seed) {
    // Defines the resolution of noise map exploration
    // noiseSeed() and noiseDetail() are included with processing.core.*
    //
    float INCREMENT = 9.0/U;
    println("Seed: " + seed);
    noiseSeed(seed);
    noiseDetail(16, 0.5);
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {
        float x = INCREMENT*u;
        float y = INCREMENT*v;
        float elevation = map(noise(x,y), 0.0, 1.0, E_MIN, E_MAX);
        
        // Elevations lower toward poles (but not zero)
        //
        float a = 1.1; // a number between 1.0 and 2.0
        // e_weight is number between (a-1)/(a+1) and 1.0
        float e_weight_v = pow(1 + a, -1) * (sin(PI*(v - 0.5 * 0.5*this.V) / (0.5*this.V)) + a);
        e_weight_v = pow(e_weight_v, 0.25);
        elevation *= e_weight_v;
        
        // Elevations lower toward east and west edges
        //
        float e_weight_u = pow(1 + a, -1) * (sin(PI*(u - 0.5 * 0.5*this.U) / (0.5*this.U)) + a);
        e_weight_u = pow(e_weight_u, 0.25);
        elevation *= e_weight_u;
        
        //elevation = int(elevation); // cast to integer
        
        land[u][v] = elevation;
      }
    }
  }
  
  // Place 'n' buildings randomly on the landscape, as long
  // as they are above water.
  //
  void randomBuildings(int n) {
    buildings.clear();
    for (int i=0; i<n; i++) {
      int u = int(random(U));
      int v = int(random(V));
      if (land[u][v] > OCEAN) {
        // a random building between 1 and 10 units tall
        PVector location = new PVector(u, v, random(1, 10));
        buildings.add(location);
      }
    }
  }
  
  // Place 'n' Lanmarks randomly on the landscape, as long
  // as they are above water.
  //
  void randomLandmarks(int n) {
    landmarks.clear();
    for (int i=0; i<n; i++) {
      int u = int(random(U));
      int v = int(random(V));
      if (land[u][v] > OCEAN) {
        // a random landmark between 10 and 30 units tall
        PVector location = new PVector(u, v, random(10, 30));
        landmarks.add(location);
      }
    }
  }
  
  // Place 'n' Trees randomly on the landscape, as long
  // as they are above water.
  //
  void randomTrees(int n) {
    trees.clear();
    for (int i=0; i<n; i++) {
      int u = int(random(U));
      int v = int(random(V));
      if (land[u][v] > OCEAN) {
        // a random tree between 1 and 4 units tall
        PVector location = new PVector(u, v, random(1, 4));
        trees.add(location);
      }
    }
  }
}
