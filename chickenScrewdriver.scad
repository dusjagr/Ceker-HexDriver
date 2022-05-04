$fn=100;

HexSize = 11.9; //[10:24] 
// 17.5 for the aviator plug M12 WORKING
// scale([1,1.1,0.88])
// 11.9 for the poti M6 WORKING (changed dimenesions of outer diam and relation to ceker
// scale([1.2,1.2,1.1])
// longest distance from corner to corner

factor = HexSize / 12;

foot = 1; //[1,2]

if(foot==1){
natural();
}

if(foot==2){
standing();
}




// natural chicken foot

module natural(){
scale([factor,factor,factor/1]) difference(){
  union()  {
    scale([1.2,1.2,1.1]) rotate([0,0,0]) translate([-4.7,18,-7.5]) rotate([98,8,0]) import("Ceker_smooth.stl", convexity=3);
    translate([0,0,4-1.2]) cylinder(h=8, r1=7.5, r2=4, center=true);
    minkowski(){
        translate([0,0,-6.2]) cylinder(h=10, r=6.8, center=true);
        sphere(1.2);
    }
  }
  translate([0,0,-6]) cylinder(h=12, d=12,center=true, $fn=6);
  translate([0,0,-12.22]) cylinder(h=0.46, d1=12.4,d2=12,center=true, $fn=6);
  translate([0,0,2.99]) cylinder(h=6, d1=12,d2=0,center=true, $fn=6);
  //translate([0,0,-2]) rotate([90,0,180]) linear_extrude(3) scale([0.5,0.5,0.5]) text("16");
  translate([0,0,-8]) writing();
}
}

//long sleeve

module natural_long(){
scale([factor,factor,factor/1]) difference(){
  union()  {
    scale([1,1.1,0.88]) translate([-20,-1,5]) rotate([0,80,0]) translate([-4.7,18,-7.5]) rotate([98,8,0]) import("Ceker_smooth.stl", convexity=3);
    translate([0,0,4-1.2]) cylinder(h=8, r1=7.5, r2=4, center=true);
    minkowski(){
        translate([0,0,-16.2]) cylinder(h=30, r=6.3, center=true);
        sphere(1.2);
    }
  }
  translate([0,5,-16]) cylinder(h=32, d=12,center=true, $fn=6);
  translate([0,5,2.99]) cylinder(h=6, d1=12,d2=0,center=true, $fn=6);
  translate([0,5,-32.22]) cylinder(h=0.46, d1=12.4,d2=12,center=true, $fn=6);
  //translate([0,0,-2]) rotate([90,0,180]) linear_extrude(3) scale([0.5,0.5,0.5]) text("16");
  translate([0,0,-8]) writing();
}
}


// 3d chicken foot

module standing(){
difference(){
    scale([0.0002,0.0002,0.0002]) import("ChickenLeg.stl", convexity=3);
    translate([0,5,0]) cylinder(h= 2.1, r=40, center=true);
}

translate([0,3,26]) cylinder(h=8, r1=4, r2=7.5, center=false);


difference(){
minkowski(){
translate([0,3,34]) cylinder(h=8, r=6.5, center=false);
    sphere(1.2);
}

#translate([0,3,38]) cylinder(h=12, r=5,center=true, $fn=6);
 translate([-3.9,-3.8,36]) rotate([90,0,0]) linear_extrude(3) scale([0.5,0.5,0.5]) text("10");
}
}

module writing(){
scale([0.13,0.13,0.13]){
    difference(){
rotate([0,0,-$t * 360]){

     for(ltl = [0]){
       lArr = ["Ceker M 6"][ltl];
       cCirc = 2 * PI * 30;
      for(lp = [0:(len(lArr)-1)]){
        rotate((lp*16)/cCirc * 360+(ltl * 28)) translate([60,0,-ltl*20]) rotate([90,0,90])
            linear_extrude(height=30, center=true){
              text(lArr[lp], size=36, font = "Linux Biolinum");
        }
      }
    }
  
}
color("green") cylinder(r=56, h=98, $fn=200, center=true);
}
}
}