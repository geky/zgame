final static Vector3f PERSON_DIM = new Vector3f(0.5f,1f,0.5f);

class ZPerson {
  
  int health;
  
//  OBJModel[] models;
  
  Vector3f loc;
  Vector3f lookAt;
  
  Vector3f move;
  float speed;
  
  float fall;
  
  GunUser weapon;
  
  ZPerson() {
    this(new Vector3f(1,100,0));
  }
  
  ZPerson(Vector3f v) {
    health = 100;
    
//    models = new OBJModel[8];
//    for(int t=0; t<models.length; t++) {
//      models[t] = new OBJModel(main, "guy" + t + ".obj", OBJModel.ABSOLUTE, TRIANGLES);
//      models[t].scale(0.01);
//    }    
    
    loc = v;    
  }
  
  Gun arm(Gun g) {
    Gun temp = weapon == null ? null : weapon.weapon;
    weapon = new GunUser(g,this);
    return temp;
  }
  
  Gun getGun() {
    return weapon.weapon;
  }
  
  void draw(int c) {
    
    Vector3f tloc = getLoc();
    Vector3f tla = getLookAt();    
    
    float z = tla.z-tloc.z;
    float y = tla.y-tloc.y-1;
    float x = tla.x-tloc.x;
    
    pushMatrix(); {
      translate(tloc.x, -tloc.y, tloc.z);  
     
      pushMatrix();
        if (weapon != null) {
          Vector3f weaponLoc = new Vector3f(PERSON_DIM.x*0.75f,0,0);
          weaponLoc.add(tloc);
          float wz = tla.z-weaponLoc.z;
          float wy = tla.y-weaponLoc.y;
          float wx = tla.x-weaponLoc.x;
          
          
          
          rotateY(-atan2(wz,wx));
          rotateZ(-atan2(wy,sqrt(wz*wz+wx*wx)));
          rotateY(-HALF_PI);
                   
          translate(PERSON_DIM.x*0.75f,0,0);
          weapon.draw();
        }
      popMatrix();    
      
      rotateY(-atan2(z,x));
      pushMatrix();
        translate(0f,PERSON_DIM.y/2f,0f);
        fill(c);
        box(PERSON_DIM.x,PERSON_DIM.y,PERSON_DIM.z);
      popMatrix();
      
      //super.draw();
      
      translate(0.0f,-PERSON_DIM.y/2f,0.0f);
      rotateZ(-atan2(y,sqrt(z*z+x*x)));
      box(PERSON_DIM.x,PERSON_DIM.y/2f,PERSON_DIM.z);
    } popMatrix();  
    
//    pushMatrix();
//      models[0].draw();
//      pushMatrix();
//        translate(0,-0.25,0);
//        models[1].draw();
//        pushMatrix();
//          translate(0,-0.3,0);
//          models[2].draw();
//        popMatrix();
//        pushMatrix();
//          translate(0.15,-0.25,0);
//          translate(0,0.4,0);
//          models[3].draw();
//          pushMatrix();
//            translate(0,0.35,0);
//            models[4].draw();
//            pushMatrix();
//              translate(0,0.075,0);
//              models[5].draw();
//            popMatrix();
//          popMatrix();
//        popMatrix();
//        pushMatrix();
//          translate(-0.15,-0.25,0);
//          translate(0,0.4,0);
//          models[3].draw();
//          pushMatrix();
//            translate(0,0.35,0);
//            models[4].draw();
//            pushMatrix();
//              translate(0,0.075,0);
//              models[5].draw();
//            popMatrix();
//          popMatrix();
//        popMatrix();
//      popMatrix();
//    popMatrix();
//    pushMatrix();
//      translate(0.1,0,0);
//      translate(0,0.5,0);
//      models[6].draw();
//      pushMatrix();
//        translate(0,0.5,0);
//        models[7].draw();
//      popMatrix();
//    popMatrix();
//    pushMatrix();
//      translate(-0.1,0,0);
//      translate(0,0.5,0);
//      models[6].draw();
//      pushMatrix();
//        translate(0,0.5,0);
//        models[7].draw();
//      popMatrix();
//    popMatrix();

//    strokeWeight(50);
//    stroke(200,200,200);
//    point(0,0,0);
    
  }
  
  int getHealth() {
    return health;
  }
  
  void setLookAt(Vector3f la) {
    lookAt = la;
  }
  
  Vector3f getLookAt() {
    return lookAt;
  }
  
  void setSpeed(float s) {
    speed = s;
  }
  
  float getSpeed() {
    return speed;
  }
  
  void setMove(Vector3f m) {
    move = m;
  }
  
  Vector3f getMove() {
    return move;
  }
  
  void jump(float jumpSpeed) {
    fall = -jumpSpeed;
  }
  
  boolean onGround() {
    return fall == 0f;
  }
  
  Vector3f getLoc() {
    return loc;
  }
    
  void setLoc(Vector3f l) {
    loc = l;
  }

  void update(float dt) {
    
    if (weapon != null) {
      weapon.updateAction(dt);
    }
    
    if (move != null && move.lengthSquared() != 0 && go) {
        Vector3f vel = new Vector3f(move);
        vel.scale(speed*dt);
        CollisionPersonPath cp = new CollisionPersonPath(loc,vel,this);
        gameMap.collidePerson(cp);
    }
    
    fall += GRAVITY*dt;
    
    Vector3f vel = new Vector3f(DOWN);
    vel.scale(fall*dt);
    CollisionPersonPath cp = new CollisionPersonPath(loc,vel,this);
    gameMap.collidePerson(cp);
    
    if (cp.hit) {
      fall = 0;
    }
    
    if (loc.y < -25) {
      health+=loc.y+25;
    }
  }
}
  
  
