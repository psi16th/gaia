/* --------------------------------------------------------------------------
 * SimpleOpenNI User3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */
 
import SimpleOpenNI.*;

float x, y, angle, c;
float x_sub, y_sub, angle_sub, c_sub;
variateur v1,v2;
PVector lastRH;
float lastDistLE;
PVector velRH = new PVector(0,0,0);
boolean flag = false;
boolean flip = false;
int step = 0;


SimpleOpenNI context;
float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
                                   // the data from openni comes upside down
float        rotY = radians(0);
boolean      autoCalib=true;

PVector      bodyCenter = new PVector();
PVector      bodyDir = new PVector();
PVector      com = new PVector();                                   
PVector      com2d = new PVector();                                   
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };

void setup()
{
  background(0,0,0);
  size(1024,768,P3D);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  x = width/2;y = height/2;
  angle = random(TWO_PI);
  x_sub = width/2;y_sub = height/2;
  angle_sub = -angle; smooth(); 
  noFill();stroke(0,51);
  colorMode(HSB);c=random(255);
  c_sub=random(255);
  background(0);  v1=new variateur(1,6, 79); v2=new variateur(1,6, 79);

  // disable mirror
  context.setMirror(false);

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();

//  stroke(255,255,255);
  smooth();  
  perspective(radians(45),
              float(width)/float(height),
              10,150000);
 }

void draw()
{
  // update the cam
  context.update();
  
  
  
  
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  
  for(int i=0;i<userList.length;i++)
  {
    //println(userList.length);
    if(context.isTrackingSkeleton(userList[i])){
      
      //print("tracking");
      PVector posRH = new PVector();
      PVector posLH = new PVector();
      PVector posLE = new PVector();
      //PVector velRH = new PVector();
      context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, posRH);
      context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_HAND, posLH);
      context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_ELBOW, posLE);
      
      if(posRH.dist(posLH) < 80){
        background(0,0,0);
      }
      
      if( lastDistLE >= 150 && posLE.dist(posRH) < 150){
        flip = true;
        print("touched!!");
      }
      lastDistLE = posLE.dist(posRH);
      //println("x = " + hoge.x);
      //println("y = " + hoge.y);
      //println("z = " + hoge.z);
      //println(posRH);
      
      if(step == 2000){
        step = 0;
      } else {
        step += 1;
      }
      
      
      if(!flag){
        velRH.x = 0;
        velRH.y = 0;
        velRH.z = 0;
        flag = true;
        //print("initial");
      } else {
        velRH.x = posRH.x - lastRH.x;
        velRH.y = posRH.y - lastRH.y;
        velRH.z = posRH.z - lastRH.z;
        //print("update");
      }
      lastRH = posRH;
      //drawLine(velRH.mag());
      
    }
  }
  drawLine(velRH.mag(), step, flip);
  if(flip){
    flip = false;
  }
    
  // set the scene pos
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);
  
  int[]   depthMap = context.depthMap();
  int[]   userMap = context.userMap();
  int     steps   = 3;  // to speed up the drawing, draw every third point
  int     index;
  PVector realWorldPoint;
 
  translate(0,0,-1000);  // set the rotation center of the scene 1000 infront of the camera

//SimpleOpenNI.SKEL_HEAD
//SimpleOpenNI.SKEL_NECK
//SimpleOpenNI.SKEL_LEFT_SHOULDER
//SimpleOpenNI.SKEL_LEFT_ELBOW
//SimpleOpenNI.SKEL_LEFT_HAND
//SimpleOpenNI.SKEL_RIGHT_SHOULDER
//SimpleOpenNI.SKEL_RIGHT_ELBOW
//SimpleOpenNI.SKEL_RIGHT_HAND
//SimpleOpenNI.SKEL_TORSO
//SimpleOpenNI.SKEL_LEFT_HIP
//SimpleOpenNI.SKEL_LEFT_KNEE
//SimpleOpenNI.SKEL_LEFT_FOOT
//SimpleOpenNI.SKEL_RIGHT_HIP
//SimpleOpenNI.SKEL_RIGHT_KNEE
//SimpleOpenNI.SKEL_RIGHT_FOOT  

}




// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(SimpleOpenNI curContext,int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  context.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext,int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext,int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


// -----------------------------------------------------------------



void drawLine(float velocity, int step, boolean flip){ 
  c+=random(0.1,0.5) * 0.5;
  c_sub+=random(0.1,0.5) * 0.5;
  
  if(c>255){c-=255;}
  if(c_sub>255){c_sub-=255;}
  
  if(flip){
    c = 255 - c;
    c_sub = 255 - c_sub;
  }
  
  if(step <= 1600){
    stroke(c,200,255, 51);
  } else {
    stroke(c,200,50, 51);
  }
  strokeWeight(3);
  angle+=random(-0.1,0.1) * 2;
  angle_sub+=random(-0.1,0.1) * 2;  
  
  x=constrain(x+cos(angle) * 0.8 + cos(angle)*0.02*(velocity), 0, width);
  y=constrain(y+sin(angle) * 0.8 + sin(angle)*0.02*(velocity), 0, height);
  x_sub=constrain(x_sub+cos(angle_sub) * 0.8 + cos(angle_sub)*0.02*(velocity), 0, width);
  y_sub=constrain(y_sub+sin(angle_sub) * 0.8 + sin(angle_sub)*0.02*(velocity), 0, height);
  if((random(100)<2)||x==0||y==0||x==width||y==height){
    angle+=random(-1,1);
  }
  if((random(100)<2)||x_sub==0||y_sub==0||x_sub==width||y_sub==height){
    angle_sub+=random(-1,1);
  }
  
  
  if(step == 0 || step == 1600){
    x = width/2;y = height/2;
    x_sub = width/2;y_sub = height/2;
    angle = random(TWO_PI);
    angle_sub = -angle;
  }
  
  
  float t1 = v1.avance();
  float t2 = v2.avance();
  float an = atan2(y-height/2, x-width/2);
  float an_sub = atan2(y_sub-height/2, x_sub-width/2);
  float p1x=width/2+(x-width/2)*0.3, p1y=height/2+(y-height/2)*0.3,p2x=width/2+(x-width/2)*0.6 , p2y=height/2+(y-height/2)*0.6;
  float p1x_sub=width/2+(x_sub-width/2)*0.3, p1y_sub=height/2+(y_sub-height/2)*0.3,p2x_sub=width/2+(x_sub-width/2)*0.6 , p2y_sub=height/2+(y_sub-height/2)*0.6;
  beginShape();
  curveVertex(width/2, height/2);
  curveVertex(width/2, height/2);
  curveVertex(p1x+cos(an+PI/2)*t1,p1y+sin(an+PI/2)*t1);
  curveVertex(p2x+cos(an-PI/2)*t2,p2y+sin(an-PI/2)*t2);
  curveVertex(x, y);
  curveVertex(x, y);
  endShape();
  
  if(step <= 1600){
    stroke(c_sub,200,255, 51);
  } else {
    stroke(c_sub,200,50, 51);
  }
  
  beginShape();
  curveVertex(width/2, height/2);
  curveVertex(width/2, height/2);
  curveVertex(p1x_sub+cos(an_sub+PI/2)*t1,p1y_sub+sin(an_sub+PI/2)*t1);
  curveVertex(p2x_sub+cos(an_sub-PI/2)*t2,p2y_sub+sin(an_sub-PI/2)*t2);
  curveVertex(x_sub, y_sub);
  curveVertex(x_sub, y_sub);
  endShape();
}

class variateur{
  float etat, mini, maxi, pas, ecart,v;
  variateur(float _min, float _max, float _pas){
    ecart=(_max-_min)/2;
    mini=_min+ecart;
    etat = random(-1,1);
    v=random(0.01,0.02);
  }
  float avance(){
    etat+=v;
    return (mini+cos(etat)*ecart);
  }
}
