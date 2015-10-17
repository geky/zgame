public class Gun {
  PImage pic;
  OBJModel model;
  
  BulletWorld bWorld;
  
  String name;
  float bulletTime;
  float reloadTime;
  int smallAmmo;
  int largeAmmo;
  int speed;
  int damage;
  
  public Gun(String filename,BulletWorld bw) {
    
    bWorld = bw;
    
    loadGun(new Scanner(createInput("guns/" + filename + "/" + filename +".gn")));
    
    pic = loadImage("guns/" + filename + "/" + filename+".gif");
    
    model = new OBJModel(main, "guns/" + filename + "/" + filename + ".obj", OBJModel.ABSOLUTE, TRIANGLES);
  }
    
  private void loadGun(Scanner s){
    s.next();
    name = s.next();
    s.next();
    bulletTime = s.nextFloat();
    s.next();
    reloadTime = s.nextFloat();
    s.next();
    smallAmmo = s.nextInt();
    s.next();
    largeAmmo = s.nextInt();
    s.next();
    speed = s.nextInt();
    s.next();
    damage = s.nextInt();
    
  }
}

public class GunUser implements HUDPanel{
  
  boolean shooting = false;
  ZPerson user = null;
  Gun weapon;
  int smallAmmo;
  int largeAmmo;
  float shootTime;
  
  PGraphics display;
  
  public GunUser(Gun weapon) {
    this.weapon = weapon;
    smallAmmo = weapon.smallAmmo;
    largeAmmo = weapon.largeAmmo;
    shootTime = 0;
    
    display = createGraphics(weapon.pic.width,weapon.pic.height,JAVA2D);
    hud.update(this);
  }
  
  public GunUser(Gun weapon,ZPerson user) {
    this(weapon);
    activate(user);
  }
  
  void deactivate() {
    user = null;
  }
  
  void activate(ZPerson user) {
    this.user = user;
  }
  
  void updateAction(float dt) { 
    shootTime += dt;
      if (shooting && shootTime > weapon.bulletTime && smallAmmo > 0) {
        Vector3f temp = new Vector3f(user.getLookAt());
        temp.sub(user.getLoc());
        
        Vector3f loc = new Vector3f();
        loc.cross(DOWN,temp);
        loc.normalize();
        loc.scale(PERSON_DIM.x*0.8f);
        loc.add(user.getLoc());
        
        temp.add(user.getLoc());
        temp.sub(loc);
        temp.normalize();
        temp.scale(weapon.speed);
        
        weapon.bWorld.add(new Bullet(user,loc,temp,weapon.damage));
        shootTime = 0;
        smallAmmo--;
     } else if (smallAmmo < 1 && shootTime > weapon.reloadTime) {
        shootTime = 0;
        smallAmmo = weapon.smallAmmo;
        //largeAmmo -= smallAmmo;
     }
  }
  
  void draw() {
    weapon.model.draw();    
  }
  
  PGraphics drawHUD() {
   
    display.beginDraw();
    display.background(weapon.pic);
    
    display.fill(200,0,0);
    display.noStroke();
    //display.rect(4,12,smallAmmo*6,3);
    //display.line(0,12,largeAmmo,12);
    display.endDraw();
    return display;
  }
  
  String getHUDName() {
    return "Weapon";
  }
}
    
    
    
