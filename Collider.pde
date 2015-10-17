final static float COLLISION_EPSILON = 0.005;

abstract class World {
  abstract void rayTest(CollisionPath cp);
  abstract void ellipseTest(CollisionPath cp);
  
  abstract void transform(Vector3f rads);
  abstract void reverseTransform(Vector3f rads);
}

class SphereWorld extends World {
  Vector3f[] world;
  
  public SphereWorld(Vector3f[] w) {
    world = w;
  }
  public SphereWorld(SphereWorld sw) {
  
    world = new Vector3f[sw.world.length];
    for (int t=0; t<sw.world.length; t++) {
      world[t] = new Vector3f(sw.world[t]);
    }
  }
  
  void rayTest(CollisionPath cp) {
    for (int t=0; t<world.length; t++) {
     Vector3f temp = new Vector3f();
     
     float a = cp.velocity.lengthSquared();
     
     //point a
     temp.sub(cp.pos,world[t]);
     
     float b = 2f*cp.velocity.dot(temp);
     
     temp.sub(world[t],cp.pos);
     
     float c = temp.lengthSquared() - 1f;
     
     float newT = getLowestRoot(a,b,c,cp.hitFraction);
     if (newT != -1f) {
       cp.hitFraction = newT;
       cp.hit = true;
       cp.intersectionPoint = new Vector3f(world[t]); 
     } 
    }
  }
  
  //takes locations of other spheres
  void ellipseTest(CollisionPath cp) {
    for (int t=0; t<world.length; t++) {
     Vector3f temp = new Vector3f();
     
     float a = cp.velocity.lengthSquared();
     
     //point a
     temp.sub(cp.pos,world[t]);
     
     float b = 2f*cp.velocity.dot(temp);
     
     temp.sub(world[t],cp.pos);
     
     float c = temp.lengthSquared() - 4f; //2 squared
     
     float newT = getLowestRoot(a,b,c,cp.hitFraction);
     if (newT != -1f) {
       cp.hitFraction = newT;
       cp.hit = true;
       cp.intersectionPoint = new Vector3f(world[t]); 
     } 
    }
  }
  
  void transform(Vector3f rads) {
    for (int t=0; t<world.length; t++) {
      transformSpace(world[t],rads);
    }
  }
  
  void reverseTransform(Vector3f rads) {
    for (int t=0; t<world.length; t++) {
      reverseTransSpace(world[t],rads);
    }
  }
  
}

class PlaneWorld extends World {
  Plane[] world;
  
  public PlaneWorld(Plane[] w) {
    world = w;
  }
  
  public PlaneWorld(PlaneWorld pw) {
    world = new Plane[pw.world.length];
    for (int t=0; t<pw.world.length; t++) {
      world[t] = new Plane(pw.world[t]);
    }
  }
  
  void rayTest(CollisionPath cp) {
    for (Plane triangle:world) {
      
      if (!triangle.isFacingTo(cp.velocity_normal))
        continue;
      
      float t;
      
      float dis = triangle.signedDisTo(cp.pos);
      float normalDotVelocity = triangle.normal.dot(cp.velocity);
      
      //if travelling parrelel
      if (normalDotVelocity == 0f)// no collision possible
          continue;
          
      t = -dis/normalDotVelocity;
        
      if (t > 1f || t < 0f) { //no collision possible
        continue;
      }
      
      //ray now collides at t
      
      Vector3f planeIntersectPoint = new Vector3f();
      planeIntersectPoint.sub(cp.pos,triangle.normal);
      planeIntersectPoint.scaleAdd(t,cp.velocity,planeIntersectPoint);
      
      if (triangle.checkPointInTriangle(planeIntersectPoint) && t < cp.hitFraction) {
        cp.hit = true;
        cp.hitFraction = t;
        cp.intersectionPoint = planeIntersectPoint;
      }
    }
  }
  
  
  
  void ellipseTest(CollisionPath cp) {
    for (Plane triangle:world) {
      if (!triangle.isFacingTo(cp.velocity_normal))
        continue;
      
      float t0,t1;
      boolean embedded = false;
      
       
      float dis = triangle.signedDisTo(cp.pos);
      float normalDotVelocity = triangle.normal.dot(cp.velocity);
      
      //if travelling parrelel
      if (normalDotVelocity == 0f) {
        if (abs(dis) >= 1f) { // no collision possible
          continue;
        } else {
          embedded = true;
          t0 = 0f;
          t1 = 1f;
        } 
      } else {
        t0 = (-1.0-dis)/normalDotVelocity;
        t1 = ( 1.0-dis)/normalDotVelocity;
        
        if (t0 > t1) {
          float t = t0;
          t0 = t1;
          t1 = t;
        }
        
        if (t0 > 1f || t1 < 0f) //no collision possible
          continue; 
          
        //clamping to [0,1]
        if (t0 < 0f) t0 = 0f;
        if (t1 < 0f) t1 = 0f;
        if (t0 > 1f) t0 = 1f;
        if (t1 > 1f) t1 = 1f;
      }
      
      //sphere now collides between intervals t0 and t1
      
      if (!embedded) {
        Vector3f planeIntersectPoint = new Vector3f();
        planeIntersectPoint.sub(cp.pos,triangle.normal);
        planeIntersectPoint.scaleAdd(t0,cp.velocity,planeIntersectPoint);
        
        if (triangle.checkPointInTriangle(planeIntersectPoint)) {
          if (t0 < cp.hitFraction) {
            cp.hit = true;
            cp.hitFraction = t0;
            cp.intersectionPoint = planeIntersectPoint;
          }
          continue;
        }
      }
      
      //now be must sweep test for edges and points
       Vector3f temp = new Vector3f();
       float vsl = cp.velocity.lengthSquared();
       float a,b,c;
       float newT;
       
       //first points
       a = vsl;
       
       //point a
       temp.sub(cp.pos,triangle.pa);
       b = 2f*cp.velocity.dot(temp);
       temp.sub(triangle.pa,cp.pos);
       c = temp.lengthSquared() - 1f;
       newT = getLowestRoot(a,b,c,cp.hitFraction);
       if (newT != -1f) {
         cp.hitFraction = newT;
         cp.hit = true;
         cp.intersectionPoint = new Vector3f(triangle.pa); 
       }
         
       //point b
       temp.sub(cp.pos,triangle.pb);
       b = 2f*cp.velocity.dot(temp);
       temp.sub(triangle.pb,cp.pos);
       c = temp.lengthSquared() - 1f;
       newT = getLowestRoot(a,b,c,cp.hitFraction);
       if (newT != -1f) {
         cp.hitFraction = newT;
         cp.hit = true;
         cp.intersectionPoint = new Vector3f(triangle.pb); 
       }
         
       //point c
       temp.sub(cp.pos,triangle.pc);
       b = 2f*cp.velocity.dot(temp);
       temp.sub(triangle.pc,cp.pos);
       c = temp.lengthSquared() - 1f;
       newT = getLowestRoot(a,b,c,cp.hitFraction);
       if (newT != -1f) {
         cp.hitFraction = newT;
         cp.hit = true;
         cp.intersectionPoint = new Vector3f(triangle.pc); 
       }
       
       //now edges 
       
       Vector3f edge = new Vector3f();
       
       //edge b -> a
       
       edge.sub(triangle.pb,triangle.pa);
       temp.sub(triangle.pa,cp.pos);
       float esl = edge.lengthSquared(); //edge square length
       float edv = edge.dot(cp.velocity); //edge dot velocity
       float edp = edge.dot(temp); //edge dot base to vertex
       
       a = esl*-vsl + edv*edv;
       b = esl*(2f*cp.velocity.dot(temp)) - 2f*edv*edp;
       c = esl*(1f-temp.lengthSquared()) + edp*edp;
       
       newT = getLowestRoot(a,b,c,cp.hitFraction);
       if (newT != -1f) {
         float f = (edv*newT - edp)/esl;
         if (f >= 0f && f <= 1f) {
           cp.hitFraction =  newT;
           cp.hit = true;
           cp.intersectionPoint = new Vector3f();
           cp.intersectionPoint.scaleAdd(f,edge,triangle.pa);
         }
       }
       
       //edge c -> b
       
       edge.sub(triangle.pc,triangle.pb);
       temp.sub(triangle.pb,cp.pos);
       esl = edge.lengthSquared(); //edge square length
       edv = edge.dot(cp.velocity); //edge dot velocity
       edp = edge.dot(temp); //edge dot base to vertex
        
       a = esl*-vsl + edv*edv;
       b = esl*(2f*cp.velocity.dot(temp)) - 2f*edv*edp;
       c = esl*(1f-temp.lengthSquared()) + edp*edp;
            
       newT = getLowestRoot(a,b,c,cp.hitFraction);
       if (newT != -1f) {
         float f = (edv*newT - edp)/esl;
         if (f >= 0f && f <= 1f) {
           cp.hitFraction =  newT;
           cp.hit = true;
           cp.intersectionPoint = new Vector3f();
           cp.intersectionPoint.scaleAdd(f,edge,triangle.pb);
         }
       }
       
       //edge a -> c
       
       edge.sub(triangle.pa,triangle.pc);
       temp.sub(triangle.pc,cp.pos);
       esl = edge.lengthSquared(); //edge square length
       edv = edge.dot(cp.velocity); //edge dot velocity
       edp = edge.dot(temp); //edge dot base to vertex
        
       a = esl*-vsl + edv*edv;
       b = esl*(2f*cp.velocity.dot(temp)) - 2f*edv*edp;
       c = esl*(1f-temp.lengthSquared()) + edp*edp;
       
       newT = getLowestRoot(a,b,c,cp.hitFraction);
       if (newT != -1f) {
         float f = (edv*newT - edp)/esl;
         if (f >= 0f && f <= 1f) {
           cp.hitFraction =  newT;
           cp.hit = true;
           cp.intersectionPoint = new Vector3f();
           cp.intersectionPoint.scaleAdd(f,edge,triangle.pc);
         }
       }
    }
  }
  
  void transform(Vector3f rads) {
    for (int t=0; t<world.length; t++) {
      Vector3f ta = world[t].pa;
      Vector3f tb = world[t].pb;
      Vector3f tc = world[t].pc;
      
      transformSpace(ta,rads);
      transformSpace(tb,rads);
      transformSpace(tc,rads);
      
      world[t] = new Plane(ta,tb,tc);
    }
  }
  
  void reverseTransform(Vector3f rads) {
    for (int t=0; t<world.length; t++) {
      Vector3f ta = world[t].pa;
      Vector3f tb = world[t].pb;
      Vector3f tc = world[t].pc;
      
      reverseTransSpace(ta,rads);
      reverseTransSpace(tb,rads);
      reverseTransSpace(tc,rads);
      
      world[t] = new Plane(ta,tb,tc);
    }
  }
}



//changes pos for you
//also screws with velocity

void collide(CollisionPath cp, World world) { 
  
  //print(cp.velocity.lengthSquared() + ">" + COLLISION_EPSILON*COLLISION_EPSILON + "   ");
   
  if (cp.velocity.lengthSquared() < COLLISION_EPSILON*COLLISION_EPSILON) {
    return;
  }
  
  world.ellipseTest(cp);
  
  if (!cp.hit) {
    cp.pos.add(cp.velocity);
    return;
  }
  
  Vector3f offset = new Vector3f(cp.velocity_normal);
  offset.scale(COLLISION_EPSILON);
  
  cp.pos.scaleAdd(cp.hitFraction,cp.velocity,cp.pos);
  cp.pos.sub(offset);
  
  cp.intersectionPoint.sub(offset);
  Vector3f planeNormal = new Vector3f(cp.pos);
  planeNormal.sub(cp.intersectionPoint);
  planeNormal.normalize();
  
  cp.velocity.scale(1f-cp.hitFraction);
  Vector3f temp = new Vector3f(cp.velocity); 
  temp.scale(temp.dot(planeNormal),planeNormal);
  cp.velocity.sub(temp);
  
  cp.velocity_normal.set(cp.velocity);
  cp.velocity_normal.normalize();
  
  cp.hit = false;
  cp.hitFraction = 1f;
  
  collide(cp,world);
  cp.hit = true;
}

//used for solving quadratic equasions
//returns if lowest root exists

private float getLowestRoot(float a,float b,float c,float maxR) {// returns -1f if it doesnt exist
  float determinant = b*b - 4f*a*c;
  if (determinant < 0f) 
    return -1f;
    
  float sqrtD = sqrt(determinant);
  float r1 = (-b - sqrtD)/(2f*a);
  float r2 = (-b + sqrtD)/(2f*a);
  
  if (r1 > r2) {
    float temp = r2;
    r2 = r1;
    r1 = temp;
  }
  
  if (r1 > 0 && r1 < maxR)
    return r1;
  
  if (r2 > 0 && r2 < maxR)
    return r2;
    
  return -1f;
}

class Plane {
  Vector3f pa,pb,pc;
  Vector3f normal;
  float constant;
  
  public Plane(Vector3f pa, Vector3f pb, Vector3f pc) {
    this.pa = pa;
    this.pb = pb;
    this.pc = pc;
    
    Vector3f v0 = new Vector3f();
    v0.sub(pb,pa);
    Vector3f v1 = new Vector3f();
    v1.sub(pc,pa);
    
    normal = new Vector3f();
    normal.cross(v0,v1);
    //normal.negate();
    normal.normalize();
    
    constant = -normal.dot(pa);//(normal.x*pa.x+normal.y*pa.y+normal.z*pa.z);
  }
  
  public Plane(Plane p) {
    this.pa = new Vector3f(p.pa);
    this.pb = new Vector3f(p.pb);
    this.pc = new Vector3f(p.pc);
    this.normal = new Vector3f(p.normal);
    this.constant = p.constant;
  }
  
  boolean isFacingTo(Vector3f dir) {
    return normal.dot(dir) <= 0;
  }
  
  float signedDisTo(Vector3f p) {
    return p.dot(normal) + constant;
  }
  
  
  boolean checkPointInTriangle(Vector3f p) {
    Vector3f v0 = new Vector3f();
    Vector3f v1 = new Vector3f();
    Vector3f v2 = new Vector3f();
    
    v0.sub(pc,pa);
    v1.sub(pb,pa);
    v2.sub(p,pa);
    
    float dot00 = v0.dot(v0);
    float dot01 = v0.dot(v1);
    float dot02 = v0.dot(v2);
    float dot11 = v1.dot(v1);
    float dot12 = v1.dot(v2);
    
    float invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    return (u > 0) && (v > 0) && (u + v < 1);
  }
  
  void draw() {
    stroke(0,255,255);
    line(pa.x,-pa.y,pa.z,pb.x,-pb.y,pb.z);
    line(pb.x,-pb.y,pb.z,pc.x,-pc.y,pc.z);
    line(pc.x,-pc.y,pc.z,pa.x,-pa.y,pa.z);
    
    //normals
    stroke(255,255,0);
    line(pa.x,-pa.y,pa.z,pa.x+normal.x,-(pa.y+normal.y),pa.z+normal.z);
    line(pb.x,-pb.y,pb.z,pb.x+normal.x,-(pb.y+normal.y),pb.z+normal.z);
    line(pc.x,-pc.y,pc.z,pc.x+normal.x,-(pc.y+normal.y),pc.z+normal.z);
  }
}

class CollisionPath {
  Vector3f pos;
  Vector3f velocity;
  
  Vector3f velocity_normal;
  
  boolean hit = false;
  float hitFraction = 1f;
  Vector3f intersectionPoint;
  
  public CollisionPath(Vector3f pos,Vector3f velocity) {
    this.pos = pos;
    this.velocity = velocity;
    
    velocity_normal = new Vector3f(velocity);
    velocity_normal.normalize();
  }
  
  void transform(Vector3f rads) {    
    transformSpace(velocity,rads);
    transformSpace(pos,rads);
    
    velocity_normal = new Vector3f(velocity);
    velocity_normal.normalize();
  }
  
  void reverseTransform(Vector3f rads) {
    reverseTransSpace(velocity,rads);
    reverseTransSpace(pos,rads);
    
    velocity_normal = new Vector3f(velocity);
    velocity_normal.normalize();
  }
}

void transformSpace(Vector3f p,Vector3f rads) {
  p.set(p.x/rads.x,p.y/rads.y,p.z/rads.z);
}
  
void reverseTransSpace(Vector3f p,Vector3f rads) {
  p.set(p.x*rads.x,p.y*rads.y,p.z*rads.z);
}
