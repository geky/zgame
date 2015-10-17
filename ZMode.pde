public abstract class ZMode {  
  
  public void draw2D() {
  }
  public void mouseDragged() {
    mouseMoved();
  }
  public void mouseMoved() {
  }
  public void keyPressed() {
  }
  public void keyReleased() {
  }
  public void mousePressed() {
  }
  public void mouseReleased() {
  }
  
  public InitMode getInit() {
    return new InitMode(0);
  }

  public void draw3D() {
    if (game != null)
      game.draw3D();
  }
}

public class InitMode extends ZMode {
  
  ZMode go;
  
  int totalTime;
  int startTime;
  
  public InitMode(int t) {
    totalTime = t;
    startTime = millis();
  }
  
 
  
  public void drawInit(float timeFracion) {}
  
  public void draw2D() {
    int t = millis()-startTime;
    drawInit(t/(float)totalTime);
    if (t > totalTime)
      setMode(go);
  }
  
   public void mouseReleased() {
    keyReleased();
  }
  
  public void keyReleased() {
    totalTime = 0;
  }
}

public class MenuMode extends ZMode {
  Button[] buttons;
  
  public MenuMode() {
    cursor();
    buttons = new Button[] { //big hack to just have colors cause the text wasnt working out
      new Button("green",620,120,160,20) {        
        void click() {
          setMode(new GameMode("Green"));
        }
        
        void draw() {
          if (over) 
            fill(0,250,0);
          else
            fill(0,150,0);
          rect(x,y,width,height);
        }
      },
      
      new Button("blue",570,170,160,20) {        
        void click() {
          setMode(new GameMode("Blue"));
        }
        
        void draw() {
          if (over) 
            fill(0,0,250);
          else
            fill(0,0,150);
          rect(x,y,width,height);
        }
      },
      
      new Button("red",520,220,160,20) {        
        void click() {
          setMode(new GameMode("Red"));
        }
        
        void draw() {
          if (over) 
            fill(250,0,0);
          else
            fill(150,0,0);
          rect(x,y,width,height);
        }
      }
    };
    
//    buttons = new Button[] {
//      new Button("hi",600,200,200,20) {        
//        void click() {
//          setMode(new GameMode());
//        }
//      },
//      
//      new Button("bye",500,240,200,20) {        
//        void click() {
//          if (game != null) {
//            noCursor();
//            setMode(game);
//          }
//        }
//      },
//      
//      new Button("hud",0,40,20,20) {        
//        void click() {
//          setMode(new HUDEditorMode("default"));
//        }
//      }
//    };

  }

  void draw2D() {
    noStroke();
    fill(129,139,149);
    quad(width*0.5,height,width*0.75,height,width*1.25,0,width,0);
    
    for (Button b : buttons) {
      b.draw();
    }
    
    fill(129,139,149);
    text("Choose a level",5,15);
  }
  
  void mouseMoved() {
    for (Button b:buttons) {
      b.check();
    }
  }
  
  void mousePressed() {
    for (Button b:buttons) {
      if (b.check())
        b.click();
    }
  }  
  
  InitMode getInit() {
    return new InitMode(1000) {
      public void drawInit(float dt) {
        noStroke();
        fill(129,139,149);
        int h = (int)(2*height*dt);
        quad(width-width*h/(2*height),h,width-width*h/(2*height)+0.25*width,h,width*1.25,0,width,0);
      }
    };
  }
}

abstract class Button {
  int x;
  int y;
  int width;
  int height;
  String name;
  
  boolean over = false;
  
  Button(String name, int x, int y, int width, int height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.name = name;
  }
  
  boolean check() {
    over = mouseX > x && mouseX < x+width && mouseY > y && mouseY < y+height;
    return over;
  }
  
  abstract void click();
  
  void draw() {
    if (over) 
      fill(192,202,212);
    else
      fill(156,166,176);
    rect(x,y,width,height);
    fill(0,0,0);
    text(name,x,y+height);
  }
}









public class WinMode extends ZMode {
  public WinMode() {
    cursor();
  }

  void draw2D() {
    fill(255,255,255);
    text("You Won!",width/2,height/2);
  }
}

public class LoseMode extends ZMode {
  public LoseMode() {
    cursor();
  }

  void draw2D() {
    fill(255,255,255);
    text("You Lost!",width/2,height/2);
  }
}



