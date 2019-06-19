# ViewEval
Demonstration of algorithmic method for automated analysis of viewlines from hypothetical building.

![Viewline Evaluation by Ira Winder](screenshots/screenshot2.png?raw=true "Viewline Evaluation by Ira Winder")

## How to Use

1. Make sure you have installed the latest version of [Java](https://www.java.com/verify/)
2. Download [Processing 3](https://processing.org/download/)
3. Clone or download this Github repository to your computer
4. Open and run "Processing/ViewEval/ViewEval.pde" with Processing 3

## Explanation of Method

 The purpose of this algorithmic "sketch" is to demonstrate how 
 one might implement a relatively efficient and straight-forward
 analysis of a piece of real estate's view quality. For instance,
 if one were to stand and look out the window of a particular 
 facade, how can we computationally generate a quantified 
 estimate of the quality of that view?
 
 Method:

 1. This demonstration first generates a random cityscape that 
    includes elements of land, water, sky, buildings, and trees 
    rendered in 3D geometry with false colors associated with 
    each element. 
 2. A building representing our "development", and consequently 
    the views we would like to analyze, is randomly placed on 
    our cityscape. The building contains a number of viewpoints, 
    one for each side of each floor of the building. Therefore,
    a 10-story building with a rectangular footprint has 40 
    viewpoints we wish to analyze.
 3. A virtual camera is placed at each of the viewpoints, 
    pointing perpendicular away from the building's surface. 
    The resulting views are saved to memory as two-dimensional 
    projections (i.e. bitmaps).
 4. Each bitmap is simplified as a low resolution matrix of
    colors that are sampled directly from the bitmap. The 
    colors in the matrix are cross-referenced with a table
    of known false colors associated with each element in order
    to generate a crude map of which elements are being seen in
    each part of a view. The sampled colors may be slightly
    different from the reference colors, so a sum-squares method
    is used to determine the least-differnt matching color based
    on hue, saturation, and brightness.
 5. The element table includes a "hard-coded" weight that 
    describes how desirable an element is to have in one's view.
    for example, a water pixel is weighted as +100 view quality,
    while the view of another building facade is -50 view quality.
    These coefficients are placeholders, for now, but could be 
    updated to be more accurate with further statistical analysis.

 Note to developers: Those intending to learn the algorithm with 
 the intention of rebuilding the logic in their own environment, 
 the "Model" Tab will likely be most relevant.

 Class Structures:

    Element() -> View() -> Facade()
                   
    CityScape()
    
 Example View Element Data Structure
 
    | Element Name  | False Color    | View Quality Weight |
    | ------------- | -------------- | ------------------- |
    | Sky           | #FFFFFF (White)| +60                 |
    | Land          | #FF0000 (Red)  | +50                 |
    | Building      | #666666 (Gray) | -50                 |
    | Water         | #0000FF (Blue) | +100                |
    | Tree          | #00FF00 (Green)| +100                |
    | Landmark      | #FF00FF (Pink) | +500                |
