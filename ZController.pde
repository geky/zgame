 
//public class ControllerMode

public class ControllerMap {
  Map<Integer,Control> map = new HashMap<Integer,Control>();
  Map<String,Control> list = new TreeMap<String,Control>();
  
  void add(Control c) {
    list.put(c.name,c);
  }
  
  void load(String filename) {
    map.clear();
    Scanner s = new Scanner(createInput(filename+".con"));
    while(s.hasNext()) {
      Control temp = list.get(s.next());
      if (temp != null)
        map.put(s.nextInt(),temp);
      else
        s.next();
    }
  }
  
  void press(int code) {
    Control temp = map.get(code);
    if (temp != null)
      temp.press();
  }
  
  void release(int code) {
    Control temp = map.get(code);
    if (temp != null)
      temp.release();
  }
}

abstract class Control {
  
  String name; 
  
  Control(String s) {
    name = s;
  }
  
  void press() {}
  void release() {}
}
  
