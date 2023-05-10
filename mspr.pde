import java.util.Arrays;

int maxMine = 40;
float squareLength = 25;
float sq = squareLength / 2.0;
float gap = 3;
int tilecount = 20;

float offset = (700/2.0 - (tilecount - 1) * sq);

boolean uncoveredTiles[][] = new boolean[tilecount][tilecount];
int[][] grid = new int[tilecount][tilecount];

void setup()
{
  // size(200, 200);
  // String[] fontList = PFont.list();
  // printArray(fontList);

  size(700, 700);
  background(0);
  for (int i = 0; i < tilecount; i++) {
    Arrays.fill(uncoveredTiles[i], 0, tilecount, false);
  }
  for (int i = 0; i < tilecount; i++) {
    Arrays.fill(grid[i], 0, tilecount, 1);
  }
  // // PFont font = loadFont("Serif.bolditalic-20");

  // PFont  myFont = createFont("Roboto Black", 20, true);
  // textFont(myFont);
}

void updateGrid(boolean showMines) // false by default, makes function optional
{
  for (int y = 0; y < tilecount; y++)
  {
    for (int x = 0; x < tilecount; x++)
    {
      float scaledy = y * squareLength + offset;
      float scaledx = x * squareLength + offset;

      if (grid[y][x] == 420) {
        stroke(255);
        fill(255, 255, 255);
        rect(scaledx, scaledy, squareLength - gap, squareLength - gap);
      } else if (uncoveredTiles[y][x] == true)
      {
        if (grid[y][x] == 0)
        {
          stroke(255);
          fill(0, 0, 255);
          rect(scaledx, scaledy, squareLength - gap, squareLength - gap);
        }    // show 0 as ∙

        else
        {
          // show muvbers
          stroke(255);
          fill(255);
          textSize(10);

          fill(0,255,0);

          //rect(scaledx, scaledy, squareLength - gap, squareLength - gap);
          fill(255);
          textAlign(CENTER, CENTER);
          text((str(grid[y][x])), scaledx, scaledy, squareLength - gap, squareLength - gap);
        }
      } else if (showMines && grid[y][x] == -666)
      {
        stroke(255);
        fill(255, 0, 0);
        rect(scaledx, scaledy, squareLength - gap, squareLength - gap);
      } else
      {
        stroke(255);
        noFill();
        rect(scaledx, scaledy, squareLength - gap, squareLength - gap);
      }
    }
  }
}

void generateMines(int posY, int posX)
{
  // ensure total of 10 mines
  for (int mineCount = 0; mineCount < maxMine; ) // expert - 99, intermediate - 40, beginner - 10
  {
    int x = int(random(tilecount));
    int y = int(random(tilecount));

    if ((y > posY + 1) || (y<posY - 1) || (x>posX + 1) || (x<posX - 1)) // first selection never a mine
    {
      if (grid[y][x] != -666)
        mineCount++;

      grid[y][x] = -666;
    }
  }
}

void generateNums()
{
  int nearbyMineCount = 0;

  for (int y = 0; y < tilecount; y++)
  {
    for (int x = 0; x < tilecount; x++)
    {
      if (grid[y][x] != -666) // ignore searching around mines
      {
        // search 3x3 nearby tiles for mines
        for (int i = -1; i <= 1; i++)
        {
          for (int j = -1; j <= 1; j++)
          {
            if (((y + i) >= 0) && ((y + i) < tilecount) && ((x + j) >= 0) && ((x + j) < tilecount)) // avoid out of bounds searches
            {
              if (grid[y + i][x + j] == -666)
                nearbyMineCount++;
            }
          }
        }

        grid[y][x] = nearbyMineCount;
        nearbyMineCount = 0;
      }
    }
  }
}

void search(int y, int x)
{
  uncoveredTiles[y][x] = true;

  for (int i = -1; i <= 1; i++)
  {
    for (int j = -1; j <= 1; j++)
    {
      if (((y + i) >= 0) && ((y + i) < tilecount) && ((x + j) >= 0) && ((x + j) < tilecount)) // search within bounds
      {
        if ((grid[y + i][x + j] == 0) && (uncoveredTiles[y + i][x + j] == false))
          search((y + i), (x + j));
        else
          uncoveredTiles[y + i][x + j] = true; // set to true,  mine uncovered
      }
    }
  }
}

void lost()
{
  boolean showMines = true;

  updateGrid(showMines);
  println("You lost.");
  exit();
}

void uncover(int posY, int posX)
{
  // Depending on what's clicked...

  if (grid[posY][posX] == -666)
    lost();

  else if (grid[posY][posX] == 0)
    search(posY, posX);

  else
    uncoveredTiles[posY][posX] = true; // set to true

  updateGrid(false);
}
void winnerCheck()
{
  int mineCount = 0;

  for (int y = 0; y < tilecount; y++)
  {
    for (int x = 0; x < tilecount; x++)
    {
      if (uncoveredTiles[y][x] == false)
      {
        mineCount++;
      }
    }
  }
  if (mineCount == maxMine)
  {
    println("You won.");
    exit();
  }
}

void flag(int posY, int posX)
{
  grid[posY][posX] = 420;
  updateGrid(false);
}

boolean firstclick = true;
void draw() {
  rectMode(CENTER);
  updateGrid(true);

  if (mousePressed) {
    for (int i = 0; i < tilecount; i++) 
    {
      for (int j = 0; j < tilecount; j++) 
      {
        float x = i * squareLength + offset;
        float y = j * squareLength + offset;
        // Scaling up to draw a rectangle at (x,y)
        if (mouseX >=  x - sq && mouseX <=  x + sq && mouseY >=  y - sq && mouseY <=  y + sq) 
        {
          if (firstclick)
          {
            firstclick = false;

            generateMines(j, i);
            generateNums();
          }
          updateGrid(false);
          uncover(j, i);
          winnerCheck();

          // fill(0,255,0);
          // rect(x, y, squareLength - gap, squareLength - gap);
        }
      }
    }
  }
}
