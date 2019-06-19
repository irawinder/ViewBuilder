// Type of View Element
class Element {
  String name;
  float weight;
  color col;
  
  Element(String name, float weight, color col) {
    this.name = name;
    this.weight = weight;
    this.col = col;
  }
}

// The context and environment that one can "see"
class Environment {
  
  int U, V;
  float E_MIN = -0.0;
  float E_MAX = 25.0;
  float OCEAN = 10.0;
  
  Float[][] land;
  ArrayList<PVector> buildings;
  ArrayList<PVector> trees;
  
  Environment(int U, int V, int seed) {
    
    this.U = U;
    this.V = V;
    
    land = new Float[U][V];
    buildings = new ArrayList<PVector>();
    trees = new ArrayList<PVector>();
    
    // Generate Land
    perlinElevation(seed);
    
    // Generate Buildings
    int num_buildings = 500;
    randomBuildings(num_buildings);
    
    // Generate Trees
    int num_trees = 2000;
    randomTrees(num_trees);
  }
  
  // Generates an elevation for all tiles according to a Perlin Noise Function
  void perlinElevation(int seed) {
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
        float e_weight_u = pow(1 + a, -1) * (sin(PI*(u - 0.5 * 0.5*this.U) / (0.5*this.U)) + a);
        e_weight_u = pow(e_weight_u, 0.25);
        elevation *= e_weight_u;
        
        //elevation = int(elevation); // cast to integer
        
        land[u][v] = elevation;
      }
    }
  }
  
  void randomBuildings(int n) {
    buildings.clear();
    for (int i=0; i<n; i++) {
      int u = int(random(U));
      int v = int(random(V));
      if (land[u][v] > OCEAN) {
        PVector location = new PVector(u, v, random(1, 10));
        buildings.add(location);
      }
    }
  }
  
  void randomTrees(int n) {
    trees.clear();
    for (int i=0; i<n; i++) {
      int u = int(random(U));
      int v = int(random(V));
      if (land[u][v] > OCEAN) {
        PVector location = new PVector(u, v, random(1, 4));
        trees.add(location);
      }
    }
  }
}

// The Building from which we are generating "views"
class Building {
  PVector location;
  int floors;
  float w, h;
  ArrayList<Facade> window;
  
  Building(PVector location, int floors, float w, float h) {
    this.location = location;
    this.floors = floors;
    this.w = w;
    this.h = h;
    
    window = new ArrayList<Facade>();
    
    for(int i=0; i<floors; i++) {
      for (int j=0; j<4; j++) {
        PVector direction = new PVector(0, 0, 0);
        PVector from = new PVector(location.x, location.y, location.z + h*(0.5 + i));
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
        
        Facade f = new Facade(w, h, from, direction);
        window.add(f);
      }
    }
  }
}

// A flat subset of the building's surface that we are analysing
class Facade {
  float w, h;
  PVector viewDirection, viewFrom;
  ArrayList<PVector> points;
  PImage capture;
  PGraphics score_graphic;
  Float[][] score_raster;
  int res;
  float viewScore;
  
  Facade(float w, float h, PVector viewFrom, PVector viewDirection) {
    this.w = w;
    this.h = h;
    this.viewFrom = viewFrom;
    this.viewDirection = viewDirection;
    
    float offset_x, offset_y;
    int v = int(20.0*height/width);
    score_raster = new Float[20][v];
    res = width/20;
    viewScore = 0;
    
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
  
  void facadeCam(float uv_scale, float z_scale) {
    camera(uv_scale*viewFrom.x, uv_scale*viewFrom.y, z_scale*viewFrom.z, 
           uv_scale*(viewFrom.x + viewDirection.x), uv_scale*(viewFrom.y + viewDirection.y), z_scale*(viewFrom.z + + viewDirection.z),
           0, 0, -1);
  }
  
  void capture() {
    if(capture == null) {
      capture = get();
      viewScore = evaluateView(capture);
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
          score_graphic.rect(i*res, j*res, res, res);
        }
      }
      score_graphic.endDraw();
    }
  }
  
  float evaluateView(PImage view) {
    float score = 0;
    for(int i=res/2; i<view.width; i+=res) {
      for(int j=res/2; j<view.height; j+=res) {
        color c = get(i, j);
        Element current = nearest(c);
        score_raster[i/res][j/res] = current.weight;
        score += current.weight;
      }
    }
    score /= (score_raster.length * score_raster[0].length);
    println("Score: " + score);
    return score;
  }
}

Element nearest(color input) {
  Element nearest = null;
  float shortest_distance = Float.POSITIVE_INFINITY;
  for(Map.Entry e : VIEW_ELEMENT.entrySet()) {
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
