public static final float DROP_SIZE = 0.1f;

public class DropWorld {
  LinkedList<Drop> drops;
  
  public DropWorld() {
    drops = new LinkedList<Drop>();
  }
  
  void add(Drop d) {
    drops.add(d);
  }
  
  void add(int count,Vector3f pos) {
    for (int t=0; t<count; t++) {
      drops.add(new Drop(pos));
    }
  }
  
  void update(float dt) {
    Iterator<Drop> i = drops.iterator();
    while (i.hasNext()) {
      Drop d = i.next();
      d.moveAndCheck(dt);
    }
  }
  
  void draw() {
    stroke(0,255,255);
    strokeWeight(5);
    
    for (Drop d:drops) {
      pushMatrix();
      point(d.pos.x,-d.pos.y,d.pos.z);
      popMatrix();
    }
  }
}
  
public class Drop {
  Vector3f pos;
  float fall;
  
  public Drop(Vector3f p) {
    pos = p;
    fall = 0;
  }
  
  public void moveAndCheck(float dt) {
    fall += GRAVITY*dt;
    println(fall + "    " + DOWN);
    
    Vector3f vel = new Vector3f(DOWN);
    vel.scale(fall*dt);
    CollisionPath cp = new CollisionPath(pos,vel);
    gameMap.collideDrop(cp);
  }
}
