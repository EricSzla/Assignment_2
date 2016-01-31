/* Program developed by Eryk Szlachetka
 * Student number: C14386641
 */

/* Ketai Library is an android library
 * for working with sensors, cameras
 * multi-touch, UI , networking, Bluetooth, 
 * WiFi Direct, Near Field Communication etc.
 */

/* TO DO */
// drawBg() function ? 
// if enough time different levels and new enemies ? 
// Solve android sound issue 



import ketai.ui.*;
//import apwidgets.*;
//import processing.sound.*;
/*import android.*;
 import android.media.*;
 import android.media.MediaPlayer.*;
 import android.content.*;*/

KetaiList menuList;
KetaiVibrate vibration;

// Sound library for Android. Not working?
MediaPlayer myTrack; // < -- doesn't work ( android )
MediaPlayer coinMusic;
MediaPlayer livesMusic;
MediaPlayer lostLiveMusic;
MediaPlayer shootMusic;
MediaPlayer jumpMusic;
MediaPlayer level1Music;
MediaPlayer level2Music;
MediaPlayer level3Music;

//PMediaPlayer player; //< -- ( apwidgets )
//SoundFile file; // < -- (processing.sound)

BaseClass cat;
BaseClass enemy;
Levels level1;

float lx, ly;
color c, d;

int levels2 = 0;
int levels = 0;           // Used to choose between levels
int stage = 0;            // Used to diffrenciate between talk stages in menu
int GAME_STEEP = 0;

boolean drawLive = false; // Used to draw a powerUp after enemy dies
boolean drawCoin = false; // Used to draw a powerUp after enemy dies
boolean keyboardToggled = false;
boolean add = true;
boolean coinup = false;
boolean liveup = false;
boolean firstplay = false;

String name;
String localtion;
String answer;

PImage menuCat;
PImage menuTalk;
PImage[] catWalk;         // Used to store images for cat walk animation
PImage[] enemyWalk;       // Used to store images for enemy walk animation
PImage[] enemyFire;       // Used to store images for enemy fire
PImage[] catFire;         // Used to store images for cat to shoot
PImage[] img;             // Used to store background images
PImage[] coins;           // Used to store images for coins
PImage[] ground;            // Used to store ground image
PImage lives;             // Used to store lives image

// ArrayList objectsArray is used to store class objects
ArrayList<BaseClass> objectsArray = new ArrayList<BaseClass>();
// menuChoice used for KetaiList ( used with Ketai Library )
ArrayList<String> menuChoice = new ArrayList<String>();


void setup()
{  
  /* For import apwidgets.* 
   player = new PMediaPlayer(this);
   player.setMediaFile("./sounds/gameover.wav");  //< -- doesn't work
   player.start();
   player.setLooping(true);
   player.setVolume(1.0, 1.0);
   */

  /* For import.andriod.media.
   MediaPlayer mediaPlayer = new MediaPlayer();
   mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
   mediaPlayer.setDataSource("gameover.wav",this);
   mediaPlayer.prepare();
   mediaPlayer.start();
   */

  /* For processing.sound
   file = new SoundFile(this, "/gameover.wav");
   file.play();
   */

  //for mod_sound_android
  myTrack = soundLoad("Sounds/menu.mp3", true);
  coinMusic = soundLoad("Sounds/coin.mp3", true);
  livesMusic = soundLoad("Sounds/life.mp3", true);
  lostLiveMusic = soundLoad("Sounds/gameover.mp3", true);
  shootMusic = soundLoad("Sounds/shoot.mp3", true);
  jumpMusic = soundLoad("Sounds/jump.mp3", true);
  level1Music = soundLoad("Sounds/levelOne.mp3", true);
  level2Music = soundLoad("Sounds/levelTwo.mp3", true);
  soundSetLoop(myTrack, true);
  soundSetLoop(level1Music, true);
  soundSetLoop(level2Music, true);

  size(displayWidth, displayHeight);    // Display in full screen mode
  colorMode(RGB, 255, 255, 255, 100);
  textSize(height/20);
  textAlign(CENTER);
  imageMode(CENTER);
  orientation(LANDSCAPE);               // Display in LANDSCAPE mode
  setFrameRate();
  smooth();

  vibration = new KetaiVibrate(this);

  img = new PImage[3];                  // Initialize PImage arrays
  catWalk = new PImage[4];
  catFire = new PImage[10];
  enemyWalk = new PImage[4];
  enemyFire = new PImage[10];
  coins = new PImage[6];
  ground = new PImage[3];

  loadData();                           // Call load data function

  // Initialize classes
  cat = new Cat(width/2-width/5, height - (height/5), height - (height/5));
  objectsArray.add(cat);
  enemy = new Enemy();
  objectsArray.add(enemy);
  level1 = new Levels(img[0], ground[0]);
}

void draw()
{
  if (levels == 0)             // If level is 0 then draw menu
  {
    drawMenu();
    if (firstplay == false)
    {
      soundPlay(myTrack);
      firstplay = true;
    }
  } else if (levels >= 1 && levels <= 3)      // If users chooses level 1 then the game begins
  {
    soundPause(myTrack, true);
    if (levels == 1)
    {
      if (!soundIsPlaying(level1Music))
      {
        soundPlay(level1Music);
      }
    } else if (levels == 2)
    {
      soundPause(level1Music, true);
      if (!soundIsPlaying(level2Music))
      {
        soundPlay(level2Music);
      }
    } else if ( levels == 3)
    {
      soundPause(level2Music, true);
    }

    drawBg();
    level1.updatelevel();      // Updates the level one
    level1.drawlevel();        // Draws the level one

    checkCollisions();
    if (coinup || liveup)
    {
      powerUpfxn();
    }
    // For loop to manipulate the class objects
    for (int i = 0; i <= objectsArray.size()-1; i++)
    {
      BaseClass draw = objectsArray.get(i);

      if (draw instanceof Cat)
      {
        if (draw.win || draw.livesLeft < 1)
        {
          // Remove the life and coins if drawn, after completing or losing level
          for (int j = objectsArray.size() - 1; j >= 0; j --)
          {
            BaseClass life = objectsArray.get(j);
            if (life instanceof Lives || life instanceof Coin) // Check the type of an object
            {
              drawLive = false;
              drawCoin = false;
              objectsArray.remove(life);
            }
          }
        }
      }

      if (draw.win)
      {
        background(255);
        fill(0);
        stroke(0);
        if (levels < 3)
        {
          text("Level " + levels + " passed !", width/2, height/2);
          fill(255);
          rect(width/4, height/2+height/20, width/2, height/15);
          fill(0);
          text("Click to progress to next level!", width/2, height/2+height/10);
          if (mousePressed)
          {
            if (mouseX > width/4 && mouseX < width/2+width/4)
            {
              if (mouseY> height/2 && mouseY < height-height/20)
              {
                draw.lostLife();
                draw.enemiesKilled = 0;
                draw.win = false;
                draw.livesLeft = 3;
                draw.respawn = false;
                draw.pos.y = height-height/3;
                draw.godown = false;
                draw.goup = false;


                if (levels == 1)
                {
                  draw.enemiesLeft = 15;
                  draw.timeleft = 60;
                } else if (levels == 2)
                {
                  draw.enemiesLeft = 20;
                  draw.timeleft = 65;
                }

                levels ++;
              }
            }
          }
        } else 
        {
          text("Congratulations ! You have completed all the levels!", width/2, height/2);
          text("Your score: " + draw.score, width/2, height/2+height/20);
          fill(255);
        }
      } else
      {
        draw.update();
        draw.render();
      }
    }
  }
} // End of draw()

void mousePressed()
{
  // If levels == 0, that means if the Menu is showed
  if (levels == 0 && mouseY > height-height/10)
  {
    if (mouseX < width/3)
    {
      vibration.vibrate(200);
      // Draws the list where user can choose levels
      menuList = new KetaiList(this, menuChoice);
    } else if (mouseX > width/3 && mouseX < (width/3)*2)
    {
      // Turns on the keyboard
      vibration.vibrate(200);
      KetaiKeyboard.toggle(this);
      keyboardToggled = true;
    } else if (mouseX > (width/3)*2)
    {
      exit();
    }
  }
}

void keyPressed()
{
  if (keyboardToggled)
  {
    if (stage == 0)
    {
      if (name == null)
      {
        name = "" + key;
        vibration.vibrate(200);
      } else 
      {
        name = name + key;
        vibration.vibrate(200);
      }

      println(name);
    }
    if (int(key) == 10)  // If key pressed == ENTER in ASCII value
    {
      if (stage == 0 && name != null)
      {
        stage = 1;
      }
      KetaiKeyboard.toggle(this); // Hide the keyboard
      keyboardToggled = false;
    }
  }
}

void loadData()
{
  // Add choices to arrayList
  menuChoice.add("Level 1");
  menuChoice.add("Level 2");
  menuChoice.add("Level 3");

  // Load background for all 3 levels
  for (int i = 0; i < img.length; i++)
  {
    img[i] = loadImage("levels/" + (i+1) + ".jpg");
    img[i].resize(displayWidth, displayHeight);

    ground[i] = loadImage("levels/g" + (i+1) + ".png");
    ground[i].resize(width, height/4);
  }

  // Load images for cat walk && enemy walk
  for (int i=0; i < catWalk.length; i++)
  {
    catWalk[i] = loadImage("Cat/walk/" + (i+1) + ".png"); 
    catWalk[i].resize(displayWidth/5, displayHeight/3);

    enemyWalk[i] = loadImage("Cat/enemyWalk/" + (i+1) + ".png");
    enemyWalk[i].resize(displayWidth/5, displayHeight/3);
  }

  //Load images for cat fire
  for (int i = 0; i < catFire.length; i++)
  {
    catFire[i] = loadImage("Cat/fire/" + i + ".png");
    catFire[i].resize(displayWidth/4, displayHeight/4);

    enemyFire[i] = loadImage("Cat/enemyFire/" + i + ".png");
    enemyFire[i].resize(displayWidth/3, displayHeight/4);
  }

  for (int i = 0; i < coins.length; i++)
  {
    coins[i] = loadImage("Coins/coin" + (int)(i+1) + ".png");
    coins[i].resize(displayWidth/20, displayHeight/10);
  }

  // Load rest of the images
  lives = loadImage("Cat/lives.png");
  lives.resize(width/15, height/15);
  menuCat = loadImage("Menu/cat.png");
  menuCat.resize(width/3, height);
  menuTalk = loadImage("Menu/talk.png");
  menuTalk.resize(width/3, height/2);
}

void drawMenu()
{
  pushStyle();
  stroke(0);
  // image used instead of background(img) as android mode didnt allow to use background method
  image(img[0], displayWidth/2, displayHeight/2);
  image(menuCat, displayWidth-displayWidth/3, displayHeight/2);
  image(menuTalk, displayWidth/3, displayHeight/3);
  fill(255);

  // Draw rects for the bottom menu
  rect(0, height, width/3, -height/10);
  rect(width/3, height, width/3, -height/10);
  rect((width/3)*2, height, width/3, -height/10);

  // Fill the rectangles with text
  fill(0);
  text("Menu", width/6, height-height/20);
  text("Keyboard", (width/6)*3, height -height/20);
  text("Exit", (width/6)*5, height-height/20);
  popStyle();

  fill(0);
  if (stage == 0)
  {
    text("I'm the ninja cat !", displayWidth/3, displayHeight/4);
    text("What's your name?", displayWidth/3, displayHeight/3);
  } else if (stage == 1)
  {
    text("Hello " + name, displayWidth/3, displayHeight/4);
    text("Help me on my journey!", displayWidth/3, displayHeight/3);
  }
}
// Start of ketaiList
void onKetaiListSelection(KetaiList list)
{
  String levelChoice = list.getSelection();

  // If statements to change levels
  if (levelChoice == "Level 1")
  {
    levels = 1;
  } else if (levelChoice == "Level 2")
  {
    levels = 2;
  } else if (levelChoice == "Level 3")
  {
    levels = 3;
  } else
  {
    levels = 0;
  }

  // For loop to adjust time left and enemies left for each particular level when user access it from the Menu instead from progressing
  for (int i = objectsArray.size() - 1; i >= 0; i --)
  {
    BaseClass catt = objectsArray.get(i);
    if (catt instanceof Cat)
    {
      if (levels == 1)
      {
        level1.platform = ground[0];
        catt.enemiesLeft = 10;
        catt.timeleft = 60;
      } else if (levels == 2)
      {
        level1.platform = ground[1];
        catt.enemiesLeft = 15;
        catt.timeleft = 60;
      } else if (levels == 3)
      {
        level1.platform = ground[2];
        catt.enemiesLeft = 20;
        catt.timeleft = 60;
      }
    }
  }
}

// drawBg() used to draw the background for each level
void drawBg()
{
  for (int i = 1; i <= img.length; i++)
  {
    if (levels == i)
    {
      level1.img = img[i-1];
      level1.platform = ground[i-1];
    }
  }
}

void checkCollisions()
{
  for (int i = objectsArray.size() - 1; i >= 0; i --)
  {
    BaseClass theCat = objectsArray.get(i);
    if (theCat instanceof Cat)
    {
      for (int j = objectsArray.size() - 1; j >= 0; j --)
      {
        BaseClass life = objectsArray.get(j);
        if (life instanceof Lives || life instanceof Coin) // Check the type of an object
        {
          if (theCat.pos.x >= (life.livesx - width/15) && theCat.pos.x <= (life.livesx + width/15))
          {
            if (life instanceof Lives)
            {
              soundPlay(livesMusic, 0);
              drawLive = false;
              if (theCat.livesLeft < 3)
              {
                ((Lives) life). applyTo((Cat)theCat);
                liveup = true;
                c = color(random(0, 255), random(0, 255), random(0, 255));
              }
            } else if (life instanceof Coin)
            {
              soundPlay(coinMusic, 0);
              drawCoin = false;
              ((Coin) life). applyTo((Cat)theCat);
              coinup = true;
              d = color(random(0, 255), random(0, 255), random(0, 255));
            }

            objectsArray.remove(life);
          } else
          {
            continue;
          }
        }
      }
    }
  }
}

void setFrameRate()
{
  /* Method which sets the frameRate depending on the screen size, the smaller the screen the smaller the frameRate */

  if (displayWidth > 2500 && displayHeight > 1400)
  {
    frameRate(60);                        // Change the frameRate to 60
  } else if ( displayWidth > 1100 && displayHeight > 700)
  {
    frameRate(25);                        // Change the frameRate to 25
  } else if ( displayWidth < 1100 && displayHeight < 700 )
  {
    frameRate(10);
  }
}

void powerUpfxn()
{
  if (liveup)
  {
    if (frameCount % 30 < 15)
    {
      fill(c);
      text("Lives ++ !", cat.pos.x - width/10, cat.pos.y - height/10);
    } else
    {
      liveup = false;
    }
  }

  if (coinup)
  {
    if (frameCount % 30 < 15)
    {
      fill(d);
      text("+ 100 !", cat.pos.x + width/10, cat.pos.y - height/10);
    } else
    {
      coinup = false;
    }
  }
}