$fn=100;

HexSize = 14; //[10:24] 
// 17.5 for the aviator plug M12 WORKING
// scale([1,1.1,0.88])
// 11.9 for the poti M6 WORKING (changed dimenesions of outer diam and relation to ceker
// scale([1.2,1.2,1.1])
// longest distance from corner to corner

factor = HexSize / 12;

foot = 2; //[1,2]

if(foot==1){
natural();
}

if(foot==2){
psychobilly();
}




// natural chicken foot

module natural(){
scale([factor,factor,factor/1]) difference(){
  union()  {
    scale([1.2,1.2,1.1]) rotate([0,0,0]) translate([-4.7,18,-7.5]) rotate([98,8,0]) import("Ceker_smooth.stl", convexity=3);
    translate([0,0,4-1.2]) cylinder(h=8, r1=7.5, r2=4, center=true);
    minkowski(){
        translate([0,0,-2.2]) cylinder(h=2, r=6.3, center=true);
        sphere(1.2);
    }
  }

}
}

// Psychobilly

module psychobilly(){
scale([factor,factor,factor/1]) difference(){
  union()  {
    scale([0.8,0.8,0.75]) rotate([0,0,10]) translate([0,0,0]) import("psychobilly_poisson.stl", convexity=3);
    //translate([0,0,4-1.2]) cylinder(h=8, r1=5.5, r2=4, center=true);
    minkowski(){
        translate([0,0,-1]) scale([1,0.8,1]) cylinder(h=3, r1=8.8, r2=5.8, center=true);
        sphere(2);
    }
  }

}
}

