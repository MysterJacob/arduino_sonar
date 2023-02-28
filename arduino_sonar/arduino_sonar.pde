import processing.serial.*;

static float max_range_m = 0.5;
static float sweep = 1.4 ;

Serial connection;
byte[] read;
boolean serial_ready = false;

void setup(){
  size(1200,650);
  background(25);
  draw_radar_base();
  connection = new Serial(this,"COM7",115200);  
  connection.clear();
  //connection.bufferUntil(0xA);
  connection.buffer(8);
  connection.write('\n');
}
void draw_spacers(int count){
   noFill();
   stroke(71,255,37);
   strokeWeight(2);
   float base_size = width-50;
   for(int i=0;i<count;i++){
     float size = base_size * ((float)i/count);
     ellipse(width/2,height,size,size);
   }
   draw_ranges(count);
}
void draw_ranges(int count){
   stroke(203,10,37);
   strokeWeight(0.7);
   line(width/2,height,width/2,height-width/2+25);
   float base_size = width-50;
   strokeWeight(2);
   for(int i=1;i<=count;i++){
     float t = ((float)i/count);
     float y = height - base_size * t/2;
     line(width/2-20,y,width/2+20,y);
     fill(203,10,37);
     textSize(20);
     textAlign(LEFT,TOP);
     text(t*max_range_m + "m",width/2+5,y);
   }
}
void draw_radar_base(){
  fill(29,165,0);
  stroke(178,225,158);
  strokeWeight(3);
  ellipse(width/2,height,width-50,width-50);
  noStroke();
  fill(203,10,37);
  ellipse(width/2,height,15,15);
}
void draw_range(float range,float angle){
  angle += 180;
  float t = range / max_range_m;
  if(t>1)t=1;
  float size = t * (width-50);
  noStroke();
  
  color from = color(117,2,32);
  color to = color(1,95,25);
  fill(lerpColor(from,to,t));
  //tint(255, 127); 
  arc(
      width/2,height,
      size,size,
      radians(angle - sweep/2),
      radians(angle + sweep/2)
  );
  //tint(255, 255); 
}
float parseFromBytes(byte[] buffer){
  int result = 0;
  for(int i=0;i<4;i++){
    result |= (buffer[i] & 0xFF) << (i*8);
  }
  return (float)result/100.0;
}

byte[] slice(byte[] input, int start,int stop){
  int size = stop - start +1;
  byte[] output = new byte[size];
  for(int i=start;i<stop;i++){
      output[i-start] = input[i];
  }
  return output;
}
void draw(){

  if(!serial_ready || read.length <= 0){return;};
  println("UA:",read.length);
  serial_ready = false;
  int last = ((int)read[3])& 0xFF;
  if(last == 0xFE){
    background(25);
    draw_radar_base();
    return;
  }
  byte[] angle_buff = slice(read,0,4);
  byte[] range_buff = slice(read,4,8);
  
  float range = parseFromBytes(range_buff)/100;
  float angle = parseFromBytes(angle_buff);
  println("ANG:",angle);
  println("RNG:",range);
  draw_range(range,angle);
  draw_spacers(4);
}
void serialEvent(Serial p) {
  try{
    read = connection.readBytes(8);
    println();
    connection.clear();
    serial_ready = true;
  }catch(Exception e){
   print(e); 
  }
  
}
