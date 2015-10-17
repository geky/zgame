public class HUDEditorMode extends ZMode {
  final static int RADIUS = 2;
  ArrayList<HUDSquare> list = new ArrayList<HUDSquare>();
  
  public HUDEditorMode(String source) {   
    
    Scanner s = new Scanner(createInput(source+".hud"));
    float resX = s.nextInt();
    float resY = s.nextInt();
    resX = width / resX;
    resY = height / resY;
    
    while(s.hasNext()) {
      HUDSquare hp = new HUDSquare();
      hp.name = s.next();
      hp.x = (int)(s.nextInt() * resX);
      hp.y = (int)(s.nextInt() * resY);
      hp.width = (int)(s.nextInt() * resX);
      hp.height = (int)(s.nextInt() * resY);
      list.add(hp);
    }
  }
  
  void keyPressed() {
    if (keyCode == 192) {
      save("default");
      setMode(new MenuMode());
    }
  }
  
  void mouseDragged() {
    for (HUDSquare hp:list) {
      if ((pmouseX - hp.x) * (pmouseX - hp.x) + (pmouseY - hp.y) * (pmouseY - hp.y) < RADIUS*RADIUS) {
        hp.x = mouseX;
        hp.y = mouseY;
        break;
      }
      
      if ((pmouseX - (hp.x+hp.width)) * (pmouseX - (hp.x+hp.width)) + (pmouseY - (hp.y+hp.height)) * (pmouseY - (hp.y+hp.height)) < RADIUS*RADIUS) {
        hp.width = mouseX-hp.x;
        hp.height = mouseY-hp.y;
        break;
      }
    }
  }
  
  void draw2D() {
    stroke(200);
    noFill();
    for (HUDSquare hp:list) {
      rect(hp.x,hp.y,hp.width,hp.height);
    }
    fill(200);
    for (HUDSquare hp:list) {
      ellipse(hp.x,hp.y,RADIUS*2,RADIUS*2);
      ellipse(hp.x+hp.width,hp.y+hp.height,RADIUS*2,RADIUS*2);
      text(hp.name,hp.x+8,hp.y+12);
    }
    
    
  }
  
  void save(String filename) {
    PrintWriter o = createWriter("data/"+filename+".hud");
    o.println(width + " " + height);
    for (HUDSquare hp:list) {
      o.println(hp.name + " " + hp.x + " " + hp.y + " " + hp.width + " " + hp.height);
    }
    o.flush();
    o.close();
  }
  
  private class HUDSquare {
    int x,y,width,height;
    String name;
  }
}

//640×480 is standard vga ratio

public class HUD {
  TreeMap<String,HUDHolder> list = new TreeMap<String,HUDHolder>();
  ArrayList<HUDHolder> map = new ArrayList<HUDHolder>();
  
  void draw() {
    for (HUDHolder hp:map) {
        image(hp.source.drawHUD(),hp.x,hp.y,hp.width,hp.height);
    }
  }
  
  void add(HUDPanel hp) {
    list.put(hp.getHUDName(),new HUDHolder(hp));
  }
  
  void update(HUDPanel hp) {
    HUDHolder temp = list.get(hp.getHUDName());
    if (temp == null)
      add(hp);
    else
      temp.source = hp;
  }
  
  void load(String filename) {
    map.clear();    
    Scanner s = new Scanner(createInput(filename+".hud"));
    float resX = s.nextInt();
    float resY = s.nextInt();
    resX = width / resX;
    resY = height / resY;
    
    while(s.hasNext()) {
      HUDHolder hp = list.get(s.next());
      if (hp != null) {
        hp.x = (int)(s.nextInt() * resX);
        hp.y = (int)(s.nextInt() * resY);
        hp.width = (int)(s.nextInt() * resX);
        hp.height = (int)(s.nextInt() * resY);
        map.add(hp);
      } else {
        s.nextLine();
      }
    }
  }
  
  private class HUDHolder {
    int x,y,width,height;
    HUDPanel source; 
    
    HUDHolder(HUDPanel n) {
      source = n;
    }
  }
}



interface HUDPanel {  
  String getHUDName();
  PGraphics drawHUD();
}

