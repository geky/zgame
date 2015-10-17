import javax.vecmath.*;
import processing.opengl.*;
 
import java.awt.*;
import javax.media.opengl.*;
import javax.media.opengl.glu.*;
import java.nio.IntBuffer;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import com.sun.opengl.util.BufferUtil;

import saito.objloader.*;

int fovy = 0;

PApplet main;

boolean init = false;
ZMode mode;
GameMode game;



void setMode(ZMode newM) {
//  if (!init) {
//    InitMode im = newM.getInit();
//    im.go = newM;
//    mode = im;
//    init = true;
//  } else {
    mode = newM;
    if (mode instanceof GameMode)
      game = (GameMode)mode;
//      init = false;
//  }
}

void setup() {
  size(800,400,OPENGL);
  //size(screenWidth, screenHeight,OPENGL);
  main = this;
  //textFont(createFont("astronbo.ttf",16));
  
  setMode(new MenuMode());
}

void draw() {  
  //frustum(-1f-fovy, 1f+fovy, -height/(float)width - fovy, height/(float)width + fovy, 5f, WORLD_SIZE);
  perspective(PI/3,width/(float)height,0.01f,WORLD_SIZE);
  hint(ENABLE_DEPTH_TEST);
  
  background(0);

  mode.draw3D();
  camera();
  perspective();
  hint(DISABLE_DEPTH_TEST);

  mode.draw2D();
}

void mouseDragged() {
  mode.mouseDragged();
}

void mouseMoved() {
  mode.mouseMoved();
}

void keyPressed() {
  mode.keyPressed();
}

void keyReleased() {
  mode.keyReleased();
}

void mousePressed() {
  mode.mousePressed();
}

void mouseReleased() {
  mode.mouseReleased();
}


ControllerMap controls;
HUD hud;
ZMap gameMap;
ZPlayer player;

boolean go;
float countdown = 4f;
String whatHappened = null;

boolean seeTarget; //last minute, really should be coded differently

int lastTime;
float totalTime = 0;


public class GameMode extends ZMode {
  
  DynamicsWorld myWorld;
  BulletWorld bWorld;
  DropWorld dWorld;
  BotWorld aWorld;
  
  int retCount = 0;
  PImage ret1,ret2;
  PImage[] ret3;

  public GameMode(String name) {  
    noCursor();
    //frameRate(60);
    fill(204);

    //frustum(-1.0f, 1.0f, -height / width, height / width, 5.0f, WORLD_SIZE);

    controls = new ControllerMap();
    controls.add(new Control("Menu") { 
      void press() {
        setMode(new MenuMode());
      }
    });
        
    hud = new HUD();
    hud.add(new HUDPanel() {
        PGraphics pg = createGraphics(200,20,JAVA2D);
        
      
        PGraphics drawHUD() {
          pg.beginDraw();
          pg.background(0,0,0,0);
          pg.fill(255,255,255);
          pg.text("Time: " + (int)totalTime,20,20);//(millis()-lastTime)
          pg.endDraw();
          return pg;
        }
  
        String getHUDName() {
          return "RT";
        }
    });
    
    

    int maxProxies = 1024;

    bWorld = new BulletWorld();
    dWorld = new DropWorld();
    aWorld = new BotWorld(); 
    
//    Gun tempGun = new Gun("Blaster",bWorld);
//    
//    ZBot tempBot = new ZBot(new Vector3f(10,100,0));
//    tempBot.arm(tempGun);
//    aWorld.add(tempBot);
//    tempBot = new ZBot(new Vector3f(-10,100,0));
//    tempBot.arm(tempGun);
//    aWorld.add(tempBot);
//    tempBot = new ZBot(new Vector3f(0,100,10));
//    tempBot.arm(tempGun);
//    aWorld.add(tempBot);
//    tempBot = new ZBot(new Vector3f(0,100,-10));
//    tempBot.arm(tempGun);
//    aWorld.add(tempBot);
//
//    player = new ZPlayer();
//    player.arm(tempGun);

    player = new ZPlayer();

    gameMap = new ZMap(name,bWorld,dWorld,aWorld,player);
    //gameMap.addToPhysics(myWorld);

    ret1 = loadImage("ret1.gif");
    ret2 = loadImage("ret2.gif");
    ret3 = new PImage[4];
    for (int t=0; t<ret3.length; t++) {
      ret3[t] = loadImage("ret3"+t+".gif");
    }
    
    controls.load("default");
    hud.load("default");
    
    lastTime = millis();
  }
  
//  public InitMode getInit() {
//    return new InitMode(2000) {
//      public void drawInit(float dt) {
//        player.mouseControl.mouseMove(frame.getLocation().x + width/2,frame.getLocation().y + height/2);
//      }
//      
//      public void mouseMoved() {
//        player.centerX = mouseX;
//        player.centerY = mouseY;
//        println(mouseX + " " + mouseY);
//      }
//    };
//  }

  void draw3D() {
    
    float dt = (millis()-lastTime)/1000f;
    lastTime = millis();
    
    if (go)
      totalTime += dt;

    if (!go && whatHappened == null) {
      go = countdown <= 0;
      countdown -= dt;
    }
    
    bWorld.update(dt);
    dWorld.update(dt);
    aWorld.update(dt);
    player.update(dt);
    
    if (aWorld.size() <= 0) {
      go = false;
      whatHappened = "Win";
    }
    
    if (player.health <= 0) {
      go = false;
      whatHappened = "Fail";
    }

    lights();
    
    player.veiw(0,0);
    render();
//    player.veiw(0,0.01f);
//    render();
//    player.veiw(0.01f,0);
//    render();
//    player.veiw(-0.01f,-0.01f);
//    render();
    
//    pushMatrix();
//    Vector3f wireColor = new Vector3f(1f, 0f, 0f);
//    for (int i = 0; i < myWorld.getNumCollisionObjects(); i++) {
//      CollisionObject body = myWorld.getCollisionObjectArray().getQuick(i);
//      Transform tran = body.getWorldTransform(new Transform());
//      bugger.drawShape(body.getCollisionShape(),tran,new Vector3f(0,0,1));
//    }
//    popMatrix();

    //translate(yLoc+sin(yRot)*cos(xRot), zLoc+sin(yRot), xLoc+cos(xRot)*cos(yRot));
    //noStroke();
    //box(100);
  }
  
  void render() {
    player.draw(250);

    gameMap.draw();

    dWorld.draw();

    bWorld.draw();
    
    aWorld.draw();   
  }

  void draw2D() { //tons of quick hacks here
    if (go) {
      image(ret1,width/2-ret1.width/2,height/2-ret1.height/2);
      if (seeTarget)
        image(ret2,width/2-ret2.width/2,height/2-ret2.height/2);
      if (player.weapon.smallAmmo == 0) {//quick hack
        image(ret3[retCount],width/2-ret3[retCount].width/2,height/2-ret3[retCount].height/2);
        retCount = ++retCount % 4;
      }
    } else if (whatHappened == null) {
      fill(255);
      text(countdown < 1f ? "GO!" : ""+(int)countdown ,width/2,height/2);      
    } else {
      player.weapon.shooting = false;
      fill(255);
      text("You " + whatHappened + "!",width/2,height/2-40);
      text("and it only took " + totalTime + " seconds",width/2,height/2-20);
      text("and " + bWorld.bulletCount + " bullets",width/2,height/2);
      text("press Enter",width/2,height/2+20);
    }
    hud.draw(); 
  }

  void mouseMoved() {
    player.mouseMoved();
  }

  void keyPressed() {
//    println(keyCode);
//    if (keyCode == 32) {
//      myWorld.stepSimulation(1/60f,8);
//      return;
//    }
    controls.press(keyCode);
    
    if (keyCode == 10 && whatHappened != null) {

      totalTime = 0;

      countdown = 4f;
      whatHappened = null;

      totalTime = 0;
      
      init = false;
      game = null;
      
      ambient(0);
      specular(0);
      shininess(0);
      
      setup();
    }
    
  }

  void keyReleased() {
    controls.release(keyCode);
  }

  void mousePressed() {
    //println(-mouseButton);
    controls.press(-mouseButton);
  }

  void mouseReleased() {
    controls.release(-mouseButton);
  }
}


