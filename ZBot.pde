 public class BotWorld {
  LinkedList<ZBot> bots;
  
  public BotWorld() {
    bots = new LinkedList<ZBot>();
  }
  
  int size() {
    return bots.size();
  }
  
  void add(ZBot b) {
    bots.add(b);
  }
  
  void update(float dt) {
    Iterator<ZBot> i = bots.iterator();
    while (i.hasNext()) {
      ZBot b = i.next();
      b.update(dt);
      if (b.getHealth() <= 0)
        i.remove();
    }
  }
  
  void draw() {
    for (ZBot b:bots) {
      b.draw(140);
    }
  }
}

public class ZBot extends ZPerson {
  
  public ZBot(Vector3f v) {
    super(v);
  }
  
  void update(float dt) {
    
    setLookAt(player.getLoc());
    Vector3f temp = new Vector3f(getLookAt());
    temp.sub(getLoc());
    CollisionPersonPath rp = new CollisionPersonPath(new Vector3f(getLoc()),temp,this);
    gameMap.collideRay(rp);
    weapon.shooting = go && rp.target == player;
    super.update(dt);
  }
}
