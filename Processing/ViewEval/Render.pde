// Draw the 3D environment and Screen Elements
//
void drawCityScape() {
    
  // Set background color and lighting
  //
  background(VIEW_ELEMENT.get("sky").col);
  directionalLight(200, 200, 200, -50, -25, -50);
  
  // Determine superficial scaler for grid values
  //
  float uv_scale = GRID_SCALE;
  float z_scale = 1;
  
  // Determine camera location
  //
  if(scenario.setCamera || scenario.calcViewScores) {
    // move camera to a particular window
    scenario.window.get(scenario.windowIndex).viewCam(uv_scale, z_scale);
  } else {
    translate(0.5*world.U, 0.5*world.V);
  }
  
  // Draw Land
  //
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
  //
  fill(VIEW_ELEMENT.get("water").col);
  pushMatrix(); translate(-5000, -5000, world.OCEAN*z_scale); // ocean level
  rect(0, 0, uv_scale*world.U + 10000, uv_scale*world.V + 10000);
  popMatrix();
  
  // Draw Buildings
  //
  fill(VIEW_ELEMENT.get("building").col);
  for(PVector location: world.buildings) {
    pushMatrix();
    int u = int(location.x);
    int v = int(location.y);
    float x = uv_scale*u;
    float y = uv_scale*v;
    float z = z_scale*world.land[u][v];
    float h = location.z;
    translate(x, y, z + 0.5*h);
    box(0.75*uv_scale, 0.75*uv_scale, h);
    popMatrix();
  }
  
  // Draw Landmarks
  //
  fill(VIEW_ELEMENT.get("landmark").col);
  for(PVector location: world.landmarks) {
    pushMatrix();
    int u = int(location.x);
    int v = int(location.y);
    float x = uv_scale*u;
    float y = uv_scale*v;
    float z = z_scale*world.land[u][v];
    float h = location.z;
    translate(x, y, z + 0.5*h);
    box(0.8*uv_scale, 0.8*uv_scale, h);
    popMatrix();
  }
  
  // Draw Trees
  //
  fill(VIEW_ELEMENT.get("tree").col);
  for(PVector location: world.trees) {
    pushMatrix();
    int u = int(location.x);
    int v = int(location.y);
    float x = uv_scale*u;
    float y = uv_scale*v;
    float z = z_scale*world.land[u][v];
    float h = location.z;
    translate(x, y, z + 0.5*h);
    box(0.25*uv_scale, 0.25*uv_scale, h);
    popMatrix();
  }
  
  // Draw Facade Scenario
  //
  for(int i=0; i<scenario.window.size(); i++) {
    View f = scenario.window.get(i);
    float hue = map(f.viewScore, 0, 100, 0, 100);
    colorMode(HSB);
    fill(hue, 255, 255);
    colorMode(RGB);
    if(f.viewScore == 0) fill(230);
    if(scenario.windowIndex == i) {
      strokeWeight(2);
      stroke(#FFFF00); 
    } else {
      strokeWeight(0.5);
      stroke(255); 
    }
    beginShape();
    for(PVector v: f.points) vertex(uv_scale*v.x, uv_scale*v.y, z_scale*v.z);
    endShape();
    fill(255); noStroke();
    pushMatrix(); translate(uv_scale*f.viewFrom.x, uv_scale*f.viewFrom.y, z_scale*f.viewFrom.z);
    sphere(0.25);
    popMatrix();
  }
}

// Draw 2D view of current window index and score overlay
// Make sure camera is set to 2D mode
//
void drawViewAnalysis() {
  PImage view = scenario.window.get(scenario.windowIndex).capture;
  PGraphics score = scenario.window.get(scenario.windowIndex).score_graphic;
  if(view != null && !scenario.calcViewScores) {
    image(view, 10, 10, width/2, height/2);
    image(score, 10, 10, width/2, height/2);
    noFill(); stroke(0); strokeWeight(5);
    rect(10, 10, width/2, height/2);
    noStroke(); strokeWeight(0.5);
    
    drawText();
  }
  
}

// Draw Key Command Descriptions and average Score
//
void drawText() {
  String commands = "";
  commands += "Key Commands: \n";
  commands += "\nr - Regenerate Random CityScape";
  commands += "\ne - Evaluate All Window View Scores";
  commands += "\n-/+ Previous/Next Window View";
  commands += "\np - Set camera to window point of view";
  commands += "\nc - Reset Camera";
  commands += "\n\nSelected View: " + (1+scenario.windowIndex) + " of " + scenario.window.size();
  commands += "\nSelected View's Score: " + int(10*scenario.window.get(scenario.windowIndex).viewScore)/10.0 + "%";
  if(scenario.viewScore != 0) {
    commands += "\nGross View Score of Building: " + int(10*scenario.viewScore)/10.0 + "%";
  }
  textAlign(LEFT, TOP);
  fill(0, 100);
  rect(10, height/2 + 20, 0.3*width + 10, 0.4*height + 10, 5);
  fill(255);
  text(commands, 15, height/2 + 25);
}
