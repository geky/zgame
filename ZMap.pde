
final static Vector3f DROP_DIM = new Vector3f(DROP_SIZE,DROP_SIZE,DROP_SIZE);

final static int WORLD_SIZE = 1000;

final static Vector3f DOWN = new Vector3f (0,-1,0);
final static float GRAVITY = 50f;


class ZMap {
  
  String name;
  OBJModel render;
  
  MapWorld world;
  PlaneWorld dropWorld;
  MapWorld personWorld;
  
  BulletWorld bWorld;
  DropWorld dWorld;
  BotWorld aWorld;
  ZPerson player;
  
  
  ZMap(String filename) {
    name = filename;
    
    render = new OBJModel(main, "maps/" + filename + "/" + filename + "Render.obj", OBJModel.ABSOLUTE, TRIANGLES);
    render.scale(2);
    loadWorlds(render);
  }
  
  ZMap(String filename, BulletWorld b, DropWorld d, BotWorld a, ZPerson p) {
    this(filename);
    bWorld = b;
    dWorld = d;
    aWorld = a;
    player = p;
    
    //quick hack to get locs of everything
    
    Gun tempGun = new Gun("Blaster",bWorld);
    
    Scanner data = new Scanner(createInput("maps/"+filename+"/"+filename+"Data.dat"));
    data.next();
    p.setLoc(new Vector3f(data.nextFloat(),100,data.nextFloat()));
    p.arm(tempGun);
    data.next();
    
    while(data.hasNext()) {
      ZBot tempBot = new ZBot(new Vector3f(data.nextFloat(),100,data.nextFloat()));
      tempBot.arm(tempGun);
      aWorld.add(tempBot);
    }
  }
  
  private void loadWorlds(OBJModel source) {
    int faceCount = source.getFaceCount();
    Plane[] w = new Plane[faceCount];
    
    for (int t=0; t<faceCount; t++) {
      PVector[] face = source.getFaceVertices(t);
      w[t] = new Plane(to3f(face[0]),to3f(face[1]),to3f(face[2]));
    }
    
    PlaneWorld tempWorld = new PlaneWorld(w);
    dropWorld = new PlaneWorld(tempWorld);
    PlaneWorld tempPersonWorld = new PlaneWorld(tempWorld);
    
    dropWorld.transform(DROP_DIM);
    tempPersonWorld.transform(PERSON_DIM);
    
    world = new MapWorld(tempWorld);
    personWorld = new MapWorld(tempPersonWorld);
    
  }
  
  void draw() { 
    noStroke();
    render.draw();
//    stroke(0,0,255);
//    for(Plane p:world.world)
//      p.draw();
//    stroke(0,255,255);
//    for(Plane p:personWorld.world)
//      p.draw();
  }
  
  Vector3f look(CollisionPersonPath rp) {
    rp.velocity.scale(WORLD_SIZE);
    collideRay(rp);
    Vector3f at = new Vector3f();
    if (WORLD_SIZE * rp.hitFraction > veiwDistance*2)
      at.scaleAdd(rp.hitFraction,rp.velocity,rp.pos);
    else
      at.add(rp.velocity,rp.pos);
      
    seeTarget = rp.target != null; //last minute
    
    return at; 
  }
  
  void collideRay(CollisionPath rp) { 
    personWorld.prep();
    rp.transform(PERSON_DIM);
    personWorld.transformOtherPeople(PERSON_DIM,null);
    personWorld.rayTest(rp);
    personWorld.reverseTransformOtherPeople(PERSON_DIM,null);
    rp.reverseTransform(PERSON_DIM);
  }
  
  void collidePerson(CollisionPersonPath cp) {
    personWorld.prep();
    cp.transform(PERSON_DIM);
    personWorld.transformOtherPeople(PERSON_DIM,cp.user);
    collide(cp,personWorld);
    personWorld.reverseTransformOtherPeople(PERSON_DIM,cp.user);
    cp.reverseTransform(PERSON_DIM);
  }
  
  void collideDrop(CollisionPath cp) {
    cp.transform(DROP_DIM);
    collide(cp,dropWorld);    
    cp.reverseTransform(DROP_DIM);
  }
  
  private class MapWorld extends World {
    
    PlaneWorld basis;
    ZPerson[] people;
    
    public MapWorld(PlaneWorld b) {
      basis = b;
    }
    
    void rayTest(CollisionPath cp) { //there is a quick hack to make people more realistically shaped, so don't reuse this code  
      basis.rayTest(cp);
      
      for (int t=0; t<people.length; t++) {
       if (cp instanceof CollisionPersonPath && ((CollisionPersonPath)cp).user == people[t])
         continue;
        
       Vector3f temp = new Vector3f();
       
       float a = cp.velocity.lengthSquared();
       
       //point a
       temp.sub(cp.pos,people[t].getLoc());
       
       float b = 2f*cp.velocity.dot(temp);
       
       temp.sub(people[t].getLoc(),cp.pos);
       
       float c = temp.lengthSquared() - 1f;
       
       float newT = getLowestRoot(a,b,c,cp.hitFraction);
       if (newT != -1f) {
         cp.hitFraction = newT;
         cp.hit = true;
         cp.intersectionPoint = new Vector3f(people[t].getLoc()); 
         if (cp instanceof CollisionPersonPath) {
           ((CollisionPersonPath)cp).target = people[t];
         }
       } 
      }
    }
    
    //takes locations of other spheres
    void ellipseTest(CollisionPath cp) {
      basis.ellipseTest(cp);
      
      for (int t=0; t<people.length; t++) {
       if (cp instanceof CollisionPersonPath && ((CollisionPersonPath)cp).user == people[t])
         continue;
        
       Vector3f temp = new Vector3f();
       
       float a = cp.velocity.lengthSquared();
       
       //point a
       temp.sub(cp.pos,people[t].getLoc());
       
       float b = 2f*cp.velocity.dot(temp);
       
       temp.sub(people[t].getLoc(),cp.pos);
       
       float c = temp.lengthSquared() - 4f; //2 squared
       
       float newT = getLowestRoot(a,b,c,cp.hitFraction);
       if (newT != -1f) {
         cp.hitFraction = newT;
         cp.hit = true;
         cp.intersectionPoint = new Vector3f(people[t].getLoc()); 
         if (cp instanceof CollisionPersonPath) {
           ((CollisionPersonPath)cp).target = people[t];
         }
       } 
      }
    }
    
    void prep() { //shortcut to create an array of people, in too much of a rush to make this "good programming"
      people = new ZPerson[aWorld.bots.size()+1];
      for (int t=0; t<aWorld.bots.size(); t++) {
        people[t] = aWorld.bots.get(t);
      }
      people[people.length-1] = player;
    }
  
    void transform(Vector3f rads) {} //not enough time to code these, oh well there not needed
    void reverseTransform(Vector3f rads) {}
    
    void transformOtherPeople(Vector3f rads, ZPerson user) {
      for (ZPerson p:people) {
        if (p != user) 
          transformSpace(p.loc,rads);
      }
    }
    
    void reverseTransformOtherPeople(Vector3f rads, ZPerson user) {
      for (ZPerson p:people) {
        if (p != user) 
          reverseTransSpace(p.loc,rads);
      }
    }
  }
}

class CollisionPersonPath extends CollisionPath {
  ZPerson target;
  ZPerson user;
  
  public CollisionPersonPath(Vector3f pos,Vector3f velocity,ZPerson u) {
    super(pos,velocity);
    user = u;
    target = null;
  }
}




