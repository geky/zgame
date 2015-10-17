//class Debugger extends IDebugDraw {
//  
//  PApplet canvas;
//  int debugMode = 0;
//  
//  int w;
//  int h;
//  
//  Debugger(PApplet source) {
//    canvas = source;
//    
//  }
//  
//  void draw3dText(Vector3f location, String textString) {
//    PFont myFont = createFont("Courier", 32);
//    textFont(myFont);
//    text(textString,location.x,location.y,location.z);
//  }
//
//  void drawContactPoint(Vector3f PointOnB, Vector3f normalOnB, float distance, int lifeTime, Vector3f col) {}
//  
//  void drawShape(CollisionShape shape, Transform trans, Vector3f col) {
//    canvas.pushMatrix();
//      canvas.translate(trans.origin.x,-trans.origin.y,trans.origin.z);
//      //canvas.applyMatrix
//      //canvas.applyMatrix(trans.basis.getOpenGLMatrix());
//      //Matrix4f m = trans.getMatrix(new Matrix4f());
//      canvas.applyMatrix(
//         trans.basis.m00,-trans.basis.m01,-trans.basis.m02,0
//        ,-trans.basis.m10,trans.basis.m11,-trans.basis.m12,0
//        ,-trans.basis.m20,-trans.basis.m21,trans.basis.m22,0
//        ,0,0,0,1);
//        
//
////      Matrix4f m = trans.getMatrix(new Matrix4f());
////      m.invert();
////      m.mul(new Matrix4f(
////         -1,0,0,0
////        ,0,1,0,0
////        ,0,0,-1,0
////        ,0,0,0,1));
////      canvas.applyMatrix(
////         m.m00,m.m01,m.m02,m.m03
////        ,m.m10,m.m11,m.m12,m.m13
////        ,m.m20,m.m21,m.m22,m.m23
////        ,m.m30,m.m31,m.m32,m.m33);
//      
//      if (shape instanceof CompoundShape) {
//        CompoundShape compoundShape = (CompoundShape) shape;
//        Transform childTrans = new Transform();
//	for (int i = compoundShape.getNumChildShapes() - 1; i >= 0; i--) {
//	  compoundShape.getChildTransform(i, childTrans);
//	  CollisionShape colShape = compoundShape.getChildShape(i);
//	  drawShape(colShape,childTrans,col);
//	}
//      } else if (shape.isConvex()) {
//	    ConvexShape convexShape = (ConvexShape)shape;
//	    if (shape.getUserPointer() == null) {
//		// create a hull approximation
//		ShapeHull hull = new ShapeHull(convexShape);
//                
//                float margin = shape.getMargin();
//		hull.buildHull(margin);
//		convexShape.setUserPointer(hull);
//	    } 
//            
//            if (shape.getUserPointer() != null) {
//		ShapeHull hull = (ShapeHull)shape.getUserPointer();
//								
//		Vector3f tmp1 = new Vector3f();
//		Vector3f tmp2 = new Vector3f();
//
//		if (hull.numTriangles () > 0) {
//		  int index = 0;
//		  IntArrayList idx = hull.getIndexPointer();
//		  ObjectArrayList<Vector3f> vtx = hull.getVertexPointer();
//
//		  for (int i=0; i<hull.numTriangles (); i++) {
//		    int i1 = index++;
//		    int i2 = index++;
//		    int i3 = index++;
//		    assert(i1 < hull.numIndices () && i2 < hull.numIndices () && i3 < hull.numIndices ());
//
//		    int index1 = idx.get(i1);
//		    int index2 = idx.get(i2);
//		    int index3 = idx.get(i3);
//		    assert(index1 < hull.numVertices () && index2 < hull.numVertices () && index3 < hull.numVertices ());
//
//		    Vector3f v1 = vtx.getQuick(index1);
//  		    Vector3f v2 = vtx.getQuick(index2);
//		    Vector3f v3 = vtx.getQuick(index3);
//		    tmp1.sub(v3, v1);
//		    tmp2.sub(v2, v1);
//
//		    drawLine(v1,v2,col);
//                    drawLine(v2,v3,col);
//                    drawLine(v3,v1,col);
//
//
//		  }
//	        }
//              }
//            }   
//            
//    canvas.popMatrix();
//  }
//           
//  void  drawLine(Vector3f from, Vector3f to, Vector3f col) {
//    canvas.stroke(col.x*255,col.y*255,col.z*255);
//    canvas.line(from.x,-from.y,from.z,to.x,-to.y,to.z);
//  }
//                  
//  int getDebugMode() {
//    return debugMode;
//  }
//           
//  void reportErrorWarning(String warningString) {
//    System.err.println(warningString);
//  }
//           
//  void setDebugMode(int dM) {
//    debugMode = dM;
//  }
//}
//  
