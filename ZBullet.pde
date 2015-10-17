 
public class BulletWorld {
  LinkedList<Bullet> bullets;
  int bulletCount = 0; // just for fun
  
  public BulletWorld() {
    bullets = new LinkedList<Bullet>();
  }
  
  void add(Bullet b) {
    bullets.add(b);
    bulletCount++;
  }
  
  void update(float dt) {
    Iterator<Bullet> i = bullets.iterator();
    while (i.hasNext()) {
      Bullet b = i.next();
      if (b.origin.lengthSquared() > WORLD_SIZE*WORLD_SIZE || b.moveAndCheck(dt))
        i.remove();
    }
  }
  
  void draw() {
//    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
//    GL gl = pgl.beginGL();
//    
//    gl.glBegin(GL.GL_LINES);
//    for (Bullet b:bullets) {
//      gl.glColor4f(1f,1f,1f,1f);
//      gl.glVertex3f(b.go.x,-b.go.y,b.go.z);
//      gl.glColor4f(0f,0f,0f,0f);
//      gl.glVertex3f(b.origin.x,-b.origin.y,b.origin.z);
//    }
//    
//    gl.glEnd();
//    pgl.endGL();

    stroke(255,255,255);
    strokeWeight(2);
    for (Bullet b:bullets) {
      line(b.go.x,-b.go.y,b.go.z,b.origin.x,-b.origin.y,b.origin.z);
    }
    noStroke();
  }
  
}

public class Bullet {
  boolean hit = false;
  Vector3f origin;
  Vector3f go;
  Vector3f speed;
  ZPerson shooter;
  int damage;
  
  public Bullet(ZPerson shooter,Vector3f origin, Vector3f speed, int damage) {
    this.origin = origin;
    this.go = new Vector3f(origin);
    this.speed = speed;
    this.shooter = shooter;
    this.damage = damage;
  }
  
  protected boolean moveAndCheck(float dt) {
    
    if (hit)
      return true;
      
    origin.set(go);
    go.set(speed);
    go.scale(dt);
    
    CollisionPersonPath rp = new CollisionPersonPath(origin,go,shooter);
    gameMap.collideRay(rp);
    
    go.scaleAdd(rp.hitFraction,go,origin);
    hit = rp.hit;
    
    if (rp.target != null)
      rp.target.health -= damage;
      
    return false;
  }
}
