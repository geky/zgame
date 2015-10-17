
Vector3f to3f(PVector pv) {
  return new Vector3f(pv.x,-pv.y,pv.z);
}

void rotate(Quat4f source) {
    Matrix4f rot = new Matrix4f();
    rot.set(source);
    applyMatrix(rot.m00,rot.m01,rot.m02,rot.m03,
                rot.m10,rot.m11,rot.m12,rot.m13,
                rot.m20,rot.m21,rot.m22,rot.m23,
                rot.m30,rot.m31,rot.m32,rot.m33);
}

interface Loadable { 
  boolean load(PApplet main) throws Exception;
  boolean isLoaded();
}

float readFloat(InputStream s) throws IOException{
  int val = (s.read() << 24) 
	+ ((s.read() & 0xFF) << 16)
	+ ((s.read() & 0xFF) << 8)
	+ (s.read() & 0xFF);
  return Float.intBitsToFloat(val);
}

Quat4f[] getQuats(float[][] source) {
  Quat4f[] temp = new Quat4f[source.length];
  for (int t=0; t<source.length; t++) {
    temp[t] = new Quat4f(source[t][0],source[t][1],source[t][2],source[t][3]);
  }
  return temp;
}
