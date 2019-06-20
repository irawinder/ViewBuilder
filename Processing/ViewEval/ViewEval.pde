/* View Evaluation Analysis Demonstration
 * Ira Winder: jiw@mit.edu, winder@ar-ma.net
 *
 * The purpose of this algorithmic "sketch" is to demonstrate how 
 * one might implement a relatively efficient and straight-forward
 * analysis of a piece of real estate's view quality. For instance,
 * if one were to stand and look out the window of a particular 
 * facade, how can we computationally generate a quantified 
 * estimate of the quality of that view?
 * 
 * Method:
 *
 * 1. This demonstration first generates a random cityscape that 
 *    includes elements of land, water, sky, buildings, and trees 
 *    rendered in 3D geometry with false colors associated with 
 *    each element. 
 *
 * 2. A building representing our "development", and consequently 
 *    the views we would like to analyze, is randomly placed on 
 *    our cityscape. The building contains a number of viewpoints, 
 *    one for each side of each floor of the building. Therefore,
 *    a 10-story building with a rectangular footprint has 40 
 *    viewpoints we wish to analyze.
 *
 * 3. A virtual camera is placed at each of the viewpoints, 
 *    pointing perpendicular away from the building's surface. 
 *    The resulting views are saved to memory as two-dimensional 
 *    projections (i.e. bitmaps).
 *
 * 4. Each bitmap is simplified as a low resolution matrix of
 *    colors that are sampled directly from the bitmap. The 
 *    colors in the matrix are cross-referenced with a table
 *    of known false colors associated with each element in order
 *    to generate a crude map of which elements are being seen in
 *    each part of a view. The sampled colors may be slightly
 *    different from the reference colors, so a sum-squares method
 *    is used to determine the least-differnt matching color based
 *    on hue, saturation, and brightness.
 *
 * 5. The element table includes a "hard-coded" weight that 
 *    describes how desirable an element is to have in one's view.
 *    for example, a water pixel is weighted as +100 view quality,
 *    while the view of another building facade is -50 view quality.
 *    These coefficients are placeholders, for now, but could be 
 *    updated to be more accurate with further statistical analysis.
 *
 * Note to developers: Those intending to learn the algorithm with 
 * the intention of rebuilding the logic in their own environment, 
 * the "Model" Tab will likely be most relevant.
 *
 * Class Structures:
 *
 *    Element() -> View() -> Facade()
 *                   
 *    CityScape()
 */
 
// Java Libraries Required (Aside from processing.core.*, which is
// automatically loaded into Processing IDE).

  // Includes the HashMap() class, which we use to make a dictionary
  //
  import java.util.Map; 
  
  // Tools that allow us to iterate through HashMap()
  //
  import java.util.Iterator; 

// 1. setup() runs FIRST and ONCE upon program execution
//
void setup() {
  size(800, 400, P3D);
  //fullScreen(P3D);
  
  // Initialize our View Evaluation Model
  //
  int world_seed = 0;
  initModel(world_seed);
  
  // Initialize our 3D Camera
  //
  initCamera();
}

// 2. draw() runs on an infinite loop after setup() is complete
//
void draw() {
  
  // Update camera position settings for a number of frames after key updates
  //
  if (cam.moveTimer > 0) {
    cam.moved();
  }
  
  // Draw 3D Graphics 
          
          // Turn baseline 3D Camera On
          hint(ENABLE_DEPTH_TEST);
          cam.on();
  
          drawCityScape();
  
  // Draw 2D Graphics
          
          // Turn baseline 3D Camera Off
          hint(DISABLE_DEPTH_TEST);
          cam.off();
          
          // Draw Slider Bars for Controlling Zoom and Rotation
          // ... if view isn't currently being evaluated
          //
          if(!scenario.setCamera && !scenario.calcViewScores) {
            cam.drawControls();
          }
          
          // Draw view of current window index and score overlay in upper left corner
          //
          drawViewAnalysis();
  
  // Run Evaluation Algorithm on current window
  // iterates windowIndex to next position
  //
  scenario.evaluateCurrent();
}

// Listeners to Update camera location based on mouse inputs
//
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

// Listeners to Trigger functions when certain keys are pressed
//
void keyPressed() {
  switch(key) {
    case 'r': // randomly generate a new Cityscape
      int random_seed = int(random(-1000, 1000));
      initModel(random_seed);
      initCamera();
      break;
    case 'c': // reset camera view
      scenario.setCamera = false;
      cam.reset();
      break;
    case 'p': // toggle camera position to facade POV
      scenario.setCamera = !scenario.setCamera;
      break;
    case 'e': // Evaluate the scores for all possible views
      if(!scenario.calcViewScores) {
        scenario.calcViewScores = true;
        scenario.windowIndex = 0;
      }
      break;
    case '+': // Next Window Index
      scenario.nextWindow();
      break;
    case '-': // Previous Window Index
      scenario.prevWindow();
      break;
  }
}
