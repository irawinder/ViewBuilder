import java.util.Map;
import java.util.Iterator;

// show from point of view of specific floor
boolean scenarioView;
int viewIndex = 21;

// automatically calculate all scores
boolean calcViewScores;

void setup() {
  size(800, 400, P3D);
  
  int seed = 0;
  initModel(0);
  
  initCamera();
  
  scenarioView = false;
  viewIndex = 21;
  
  calcViewScores = false;
}

int randomInt(float range) {
  return int(random(0, range));
}

void draw() {
  
  // Update camera position settings for a number of frames after key updates
  //
  if (cam.moveTimer > 0) {
    cam.moved();
  }
  
  // Draw and Calculate 3D Graphics 
  //
  hint(ENABLE_DEPTH_TEST);
  cam.on();
  
  // Draw Environment in 3D
  //
  background(VIEW_ELEMENT.get("sky").col);
  directionalLight(200, 200, 200, -50, -25, -50);
  
  float uv_scale = GRID_SCALE;
  float z_scale = 1;
  
  if(scenarioView || calcViewScores) {
    scenario.window.get(viewIndex).facadeCam(uv_scale, z_scale);
  } else {
    translate(0.5*world.U, 0.5*world.V);
  }
  
  drawEnvironment(uv_scale, z_scale);
  
  // 2D Stuff
  //
  hint(DISABLE_DEPTH_TEST);
  cam.off();
  
  if(!scenarioView && !calcViewScores) {
    // Draw Slider Bars for Controlling Zoom and Rotation
    //
    cam.drawControls();
  }
  
  PImage snap = scenario.window.get(viewIndex).capture;
  PGraphics s = scenario.window.get(viewIndex).score_graphic;
  if(snap != null && !calcViewScores) {
    image(snap, 10, 10, width/2, height/2);
    image(s, 10, 10, width/2, height/2);
    noFill(); stroke(0); strokeWeight(5);
    rect(10, 10, width/2, height/2);
    noStroke(); strokeWeight(0.5);
  }
  
  if(calcViewScores) {
    
    scenario.window.get(viewIndex).capture();
    
    if(viewIndex < scenario.window.size() - 1) {
      viewIndex++;
    } else {
      calcViewScores = false;
    }
  }
}

void drawEnvironment(float uv_scale, float z_scale) {
  
  // Draw Land
  fill(VIEW_ELEMENT.get("land").col);
  for(int u = 0; u<world.U; u++) {
    for(int v = 0; v<world.V; v++) {
      pushMatrix();
      float x = uv_scale*u;
      float y = uv_scale*v;
      float h = z_scale*world.land[u][v];
      translate(x, y, 0.5*h);
      box(uv_scale, uv_scale, h);
      popMatrix();
    }
  }
  
  // Draw Ocean
  fill(VIEW_ELEMENT.get("water").col);
  pushMatrix(); translate(-5000, -5000, world.OCEAN*z_scale); // ocean level
  rect(0, 0, uv_scale*world.U + 10000, uv_scale*world.V + 10000);
  popMatrix();
  
  // Draw Buildings
  fill(VIEW_ELEMENT.get("building").col);
  for(PVector location: world.buildings) {
    pushMatrix();
    int u = int(location.x);
    int v = int(location.y);
    float x = uv_scale*u;
    float y = uv_scale*v;
    float z = z_scale*world.land[u][v];
    float h = location.z;
    translate(x, y, h + 0.5*z);
    box(0.75*uv_scale, 0.75*uv_scale, z);
    popMatrix();
  }
  
  // Draw Trees
  fill(VIEW_ELEMENT.get("tree").col);
  for(PVector location: world.trees) {
    pushMatrix();
    int u = int(location.x);
    int v = int(location.y);
    float x = uv_scale*u;
    float y = uv_scale*v;
    float z = z_scale*world.land[u][v];
    float h = location.z;
    translate(x, y, h + 0.5*z);
    box(0.25*uv_scale, 0.25*uv_scale, z);
    popMatrix();
  }
  
  // Draw Scenario Building
  for(Facade f: scenario.window) {
    float hue = map(f.viewScore, 0, 100, 0, 100);
    colorMode(HSB);
    fill(hue, 255, 255);
    colorMode(RGB);
    stroke(255); strokeWeight(0.5);
    beginShape();
    for(PVector v: f.points) vertex(uv_scale*v.x, uv_scale*v.y, z_scale*v.z);
    endShape();
    fill(255); noStroke();
    pushMatrix(); translate(uv_scale*f.viewFrom.x, uv_scale*f.viewFrom.y, z_scale*f.viewFrom.z);
    sphere(0.25);
    popMatrix();
  }
}

void mouseMoved() {
  cam.moved(); 
}

void mouseReleased() {
  cam.moved();    
}

void mouseClicked() {
  cam.moved();
}

void mousePressed() {
  cam.pressed(true);
}

void keyPressed() {
  switch(key) {
    case 'r':
      int random_seed = int(random(-1000, 1000));
      initModel(random_seed);
      break;
    case 'c':
      cam.reset();
      break;
    case 'p':
      scenarioView = !scenarioView;
      break;
    case 's':
      if(scenarioView) scenario.window.get(viewIndex).capture();
      break;
    case 'g':
      if(!calcViewScores) {
        calcViewScores = true;
        viewIndex = 0;
      }
      break;
  }
}
