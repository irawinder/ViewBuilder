// Camera Object with built-in GUI for navigation and selection
//
Camera cam;
PVector B; // Bounding Box for 3D Environment
int MARGIN; // Pixel margin allowed around edge of screen

void initCamera() {
  
  // Bounding Box for Environment
  //
  B = new PVector(GRID_SCALE*GRID_U, GRID_SCALE*GRID_V, 0);
  MARGIN = 20;
  
  // Initialize 3D World Camera Defaults
  //
  cam = new Camera (B, MARGIN);
  cam.ZOOM_DEFAULT = +0.49;
  cam.X_DEFAULT    = +0.00;
  cam.Y_DEFAULT    = -85.0;
  cam.ZOOM_POW     = +2.75;
  cam.ZOOM_MAX     = +0.10;
  cam.ZOOM_MIN     = +0.75;
  cam.ROTATION_DEFAULT = PI; // (0 - 2*PI)
  cam.CHUNK_RESOLUTION = GRID_SCALE;
  cam.BASE_ALPHA = 150;   // (0-255) Default baseline alpha value
  cam.init(); // Must End with init() if any BASIC variables within Camera() are changed from default
  
  // Turn cam off while still initializing
  //
  cam.off();  
}
