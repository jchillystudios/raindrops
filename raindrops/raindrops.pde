int nRaindrops = 30;
//Raindrop[] raindrops = new Raindrop[nRaindrops];
ArrayList<Raindrop> raindrops = new ArrayList<Raindrop>();
float squishiness = 0.6f;
float squishinessRandFactor = 0.2f; 
int raindropBW = 255;
int raindropDiameterMax = 70;
int raindropDiameterMin = 30;
int bgColor = 50;

// set up pixelation
int cellSize = 8; // the bigger the convolution cell, the more blocky the pixelation. NOTE: this assumes square convolution, cell width is equal to cell height!
int cellsWide;
int cellsHigh;

void setup() {
  // set up window; screen width, height
  //size(960, 640); // each must be divisible by cellSize
  size(1080, 1920); // each must be divisible by cellSize
  cellsWide = width / cellSize;
  cellsHigh = height / cellSize;
  //println(width + " " + height);
  // have border of raindrop ellipse draw same color as raindrop (no dark border)
  stroke(raindropBW);
  // initialize raindrops
  for (int i = 0; i < nRaindrops; i++) {
    initRaindrop(i);
  }
  
  // misc debug
  //println("getCellColor():");
  //getCellColor(0, 0);
  //println(red(get(0, 0)) + " " + green(get(0, 0)) + " " + blue(get(0, 0)));
  //println(hue(get(0, 0)));
  //println(brightness(get(0, 0)));
  //println(saturation(get(0, 0)));
}

float getRandXPosition() {
  return random(0 + raindropDiameterMin, width - raindropDiameterMax);
}

float getRandYPosition() {
  return random(0 + raindropDiameterMin, height - raindropDiameterMax);
}

float getRandXDiameter() {
  return random(raindropDiameterMin, raindropDiameterMax);
}

int getRandOpacity() {
  return Math.round(random(0, 255));
}

float getRandSquishiness() {
  return squishiness + random(-1 * squishinessRandFactor * squishiness, squishinessRandFactor * squishiness);
}

void initRaindrop(int id) {
  float xDiameter = getRandXDiameter();
  float yDiameter = xDiameter * getRandSquishiness();
  int opacity = getRandOpacity();
  //raindrops[id] = new Raindrop(id, random(width), random(height), xDiameter, yDiameter);
  raindrops.add(
    new Raindrop(
      id,
      getRandXPosition(), //random(width), // position x: random x along screen width
      getRandYPosition(), //random(height), // position y: random y along screen height
      xDiameter,
      yDiameter,
      opacity,
      getRandFadeRate()
    )
  );
}

int getRandFadeRate() {
  return Math.round(random(1, 5));
  //return random(0.01, 0.1);
}

int getPixelXTrue(int pixelX, int cellX) {
  return (cellX * cellSize) + pixelX;
}

int getPixelYTrue(int pixelY, int cellY) {
  return (cellY * cellSize) + pixelY;
}

int getCellColor(int cellX, int cellY) {
  // return BW color (from 0 to 255)
  // apply this convolution to pixelate the image
  // add all the BW color values together (i.e. from 0 - 255)
  // and divide by the number of pixels to get avg BW pixel color value
  int nPixelsInCell = cellSize * cellSize;
  int bwColorCumulative = 0; 
  for (int pixelX = 0; pixelX < cellSize; pixelX++) {
    for (int pixelY = 0; pixelY < cellSize; pixelY++) {
      //int pixelColor = pixels[getPixelIndex(getPixelXTrue(pixelX, cellX), getPixelYTrue(pixelY, cellY))];
      //println(pixelColor);
      color pixelColor = get(getPixelXTrue(pixelX, cellX), getPixelYTrue(pixelY, cellY));
      //println(pixelColor);
      //println(get(0, 0));
      //colorCumulative += pixelColor;
      bwColorCumulative += brightness(pixelColor);
    }
  }
  // intercept possible div by 0 error in avgColor calculation
  if (bwColorCumulative == 0) {
    return 0;
  }
  int avgColor = Math.round(bwColorCumulative / nPixelsInCell);
  //println(avgColor);
  return avgColor;
  
  // get(x, y, w, h) // https://processing.org/reference/get_.html
  //int c = get(cellX * cellSize, cellY * cellSize, cellSize, cellSize);
  
  //return 0;
}

int getPixelIndex(int x, int y) {
  // input x,y pixel coordinate on screen and return pixel index
  // starting from top left = 0 and going right-down
  // i.e., if the screen were size 3x3 pixel indexing would work like this: 
  // 0|1|2
  // 3|4|5
  // 6|7|8
  return (y * width) + x;
}

void setCellColor(int cellX, int cellY, int cellColor) {
  // for each pixel in cell, set the pixel to the color of the cell
  for (int pixelX = 0; pixelX < cellSize; pixelX++) {
    for (int pixelY = 0; pixelY < cellSize; pixelY++) {
      // pixelX and pixelY are relative positions within cell; need to convert to true screen position
      int pixelXTrue = getPixelXTrue(pixelX, cellX);
      int pixelYTrue = getPixelYTrue(pixelY, cellY);
      pixels[getPixelIndex(pixelXTrue, pixelYTrue)] = color(cellColor);
    }
  }
}

void pixelate() {
  // for each cell, set the color of each pixel in the cell
  // to the average color over all the pixels in the cell
  for (int cellX = 0; cellX < cellsWide; cellX++) {
    for (int cellY = 0; cellY < cellsHigh; cellY++) {
      int cellColor = getCellColor(cellX, cellY);
      //if (cellColor != bgColor) {
      //  println(cellColor);
      //}
      setCellColor(cellX, cellY, cellColor);
    }
  }
  //println("");
}


void draw() {
  // clear pixel buffer
  //clear();
  // clear screen with background color
  background(bgColor);
  
  // draw raindrops!
  for (Raindrop rainDrop : raindrops) {
    rainDrop.fade();
    rainDrop.display();
  }
  
  // apply pixelate convolution
  // suppress this block of code to get smooth picture!
  loadPixels();
  pixelate();
  updatePixels();
  
}

int clamp(int val, int minVal, int maxVal) {
  if (val < minVal) {
    return minVal;
  }
  if (val > maxVal) {
    return maxVal;
  }
  return val;
}

class Raindrop {
  int id;
  float x, y;
  float diameterX;
  float diameterY;
  
  // set up raindrop fade
  int opacity; // out of 255
  int lastMillis;
  //float fadeRate;
  int fadeRate;
  
  Raindrop(int idIn, float xIn, float yIn, float diameterXIn, float diameterYIn, int opacityIn, int fadeRateIn) {
    id = idIn;
    x = xIn;
    y = yIn;
    diameterX = diameterXIn;
    diameterY = diameterYIn;
    
    opacity = opacityIn; 
    lastMillis = 0;
    //fadeRate = 0.1;
    fadeRate = fadeRateIn;
  }
  
  void display() {
    stroke(raindropBW, opacity);
    fill(raindropBW, opacity);
    ellipse(x, y, diameterX, diameterY);
  }
  
  void fade() {
    // scale fade by number of milliseconds that have elapsed since last frame
    // (so animation is smooth)
    int thisMillis = millis();
    int millisDelta = thisMillis - lastMillis;
    //int opacityDelta = Math.round(millisDelta * fadeRate);
    //int newOpacity = opacity - opacityDelta;
    int newOpacity = opacity - fadeRate;
    // debug first raindrop
    //if (id == 0) {
    //  //println(millisDelta + ", " + newOpacity);
    //  //println(opacityDelta);
    //  //println(millisDelta);
    //  //println(opacityDelta);
    //}
    opacity = clamp(newOpacity, 0, 255);
    lastMillis = thisMillis;
    
    // if raindrop faded completely, reset it and send it somewhere else!
    if (opacity <= 0) {
      reset();
    }
  }
  
  void reset() {
    x = getRandXPosition(); //random(width);
    y = getRandYPosition(); //random(height);
    diameterX = getRandXDiameter();
    diameterY = diameterX * getRandSquishiness();
    opacity = getRandOpacity();
    fadeRate = getRandFadeRate();
  }
  
}
