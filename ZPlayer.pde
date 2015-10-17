float veiwDistance = 3;
float veiwHeight = 1.25f;
static final int UP = 0;
static final int DN = 1;
static final int LEFT = 2;
static final int RIGHT = 3;
static final int U = 4;
static final int D = 5;

static final float PLAYER_SPEED = 10;


class ZPlayer extends ZPerson implements HUDPanel {
  
  PImage healthPic;
  PGraphics healthDisplay;
  
  boolean mouseReturn = false;
  static final float LOC_SPEED = 1;
  static final float ROT_SPEED = PI / 2000;
  int centerX; 
  int centerY;
  Robot mouseControl;

  
  boolean[] dir = new boolean[6];
  boolean jump;
  Vector3f rot;
  Vector3f cameraLoc;
  
  ZPlayer() {
    super();
    
    centerX = main.getBounds().width/2 - main.getBounds().x;
    centerY = main.getBounds().height/2 - main.getBounds().y;
    
    try { 
      mouseControl = new Robot();
    } catch (AWTException e) {
      e.printStackTrace();
    }
    
    setSpeed(PLAYER_SPEED);
    rot = new Vector3f();
    cameraLoc = new Vector3f();
    
    
    controls.add(new Control("FovyA") {
      public void press() {
        fovy++;
      }
      
      public void release() {
      }
    });
    
    controls.add(new Control("FovyM") {
      public void press() {
        fovy--;
      }
      
      public void release() {
      }
    });
    
    controls.add(new Control("Move_Forward") {
      public void press() {
        dir[UP] = true; 
      }
      
      public void release() {
        dir[UP] = false; 
      }
    });
    
    controls.add(new Control("Move_Backward") {
      public void press() {
        dir[DN] = true; 
      }
      
      public void release() {
        dir[DN] = false; 
      }
    });
    
    controls.add(new Control("Move_Left") {
      public void press() {
        dir[LEFT] = true; 
      }
      
      public void release() {
        dir[LEFT] = false; 
      }
    });
    
    controls.add(new Control("Move_Right") {
      public void press() {
        dir[RIGHT] = true; 
      }
      
      public void release() {
        dir[RIGHT] = false; 
      }
    });
    
    controls.add(new Control("Move_Up") {
      public void press() {
        dir[U] = true; 
      }
      
      public void release() {
        dir[U] = false; 
      }
    });
    
    controls.add(new Control("Move_Down") {
      public void press() {
        dir[D] = true; 
      }
      
      public void release() {
        dir[D] = false; 
      }
    });
    
    controls.add(new Control("Jump") {
      public void press() {
        jump = true; 
      }
      
      public void release() {
        jump = false; 
      }
    });
    
    
    
    controls.add(new Control("Shoot") {
      public void press() {
        if (weapon != null) {
          weapon.shooting = go;
        }
      }
      
      public void release() {
        if (weapon != null) {
          weapon.shooting = false;
        }
      }
    });
    
    controls.add(new Control("Throw") {
      public void press() {
        gameMap.dWorld.add(1,new Vector3f(0f,2f,0f));
      }
      
      public void release() {
      }
    });
    
    health = 1000;
    
    healthPic = loadImage("heart.gif");
    
    healthDisplay = createGraphics(healthPic.width,healthPic.height,JAVA2D);
    hud.update(this);
    
  }
  
  void veiw(int offsetX, int offsetY) {
    Vector3f facing = new Vector3f(sin(rot.x)*cos(rot.y), -sin(rot.y), cos(rot.y)*cos(rot.x));
    
    Vector3f center = new Vector3f(getLoc());
    cameraLoc.set(center);
    cameraLoc.scaleAdd(-veiwHeight,DOWN,cameraLoc);
    cameraLoc.scaleAdd(-veiwDistance,facing,cameraLoc);
    
    Vector3f temp = new Vector3f();
    temp.sub(center,cameraLoc);
    temp.negate();
    
    CollisionPersonPath rp = new CollisionPersonPath(center,temp,this);
    gameMap.collideRay(rp);
    if (rp.hit) {
      cameraLoc.interpolate(cameraLoc, center, 1-rp.hitFraction);
    }
    
    rp = new CollisionPersonPath(cameraLoc,facing,this);
    setLookAt(gameMap.look(rp));
    
    camera(cameraLoc.x+offsetX,-cameraLoc.y+offsetY,cameraLoc.z,
         super.lookAt.x,-super.lookAt.y,super.lookAt.z,
         DOWN.x,-DOWN.y,DOWN.z);
         //super.lookAt ~= facing
  }
  
  void update(float dt) {    
    super.update(dt);
    
    //println(loc);
    
    if (onGround()) {
      Vector3f mFacing = new Vector3f(sin(rot.x), 0, cos(rot.x));
      Vector3f sideMFacing = new Vector3f(mFacing.z,mFacing.y,-mFacing.x);
      Vector3f move = new Vector3f();
      if (dir[UP])
        move.add(mFacing);
      if (dir[DN])
        move.scaleAdd(-1,mFacing,move);
      if (dir[LEFT])
        move.add(sideMFacing);
      if (dir[RIGHT])
        move.scaleAdd(-1,sideMFacing,move);
      if (dir[U])
        move.add(new Vector3f(0,1,0));
      if (dir[D])
        move.add(new Vector3f(0,-1,0));
  
      if (move.lengthSquared() != 0 && move.lengthSquared() != 1) {
        move.normalize();
      }
      setMove(move);
    }
    
    if (jump && onGround() && go) {
      jump(15);
    }
  }
  
//  void draw() {  
//    
////    Vector3f temp = getLoc();
//    
////    pushMatrix(); {
////      fill(204,204,0);
////      translate(temp.x, -temp.y, temp.z);   
////      rotateY(rot.x);
////      //box(0.5,1,0.5);
////      super.draw();
////      
////      translate(0.0f,-1.0f,0.0f);
////      rotateX(-rot.y);
////      //box(0.5);
////      fill(204);
////    } popMatrix();  
//
//    
////    pushMatrix();
////    noFill();
////    stroke(0,255,0);
////    translate(temp.x, -temp.y, temp.z); 
////    sphere(PERSON_DIM.x); 
////    popMatrix();
//  }
  

  synchronized void mouseMoved() {    
    if (mouseReturn && mouseX == centerX && mouseY == centerY) {
      mouseReturn = false;
    } else {
      mouseReturn = true;
      rot.x -= ROT_SPEED * (mouseX - centerX);
      rot.x %= TWO_PI;
      rot.y += ROT_SPEED * (mouseY - centerY);
      if (rot.y > HALF_PI)
        rot.y = HALF_PI;
      if (rot.y < -HALF_PI)
        rot.y = -HALF_PI;
      mouseControl.mouseMove(frame.getLocation().x + width/2,frame.getLocation().y + height/2);
    }
  }
  
  PGraphics drawHUD() {
   
    healthDisplay.beginDraw();
    healthDisplay.background(healthPic);
    
    healthDisplay.noStroke();
    healthDisplay.fill(140,0,0);
    healthDisplay.rect(10,30,health/5,3);
    healthDisplay.endDraw();
    return healthDisplay;
  }
  
  String getHUDName() {
    return "Health";
  }
  
  
}
