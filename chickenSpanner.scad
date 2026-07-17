$fn = 100;

hex_nut_tolerance = 0.1; // [0.0:0.05:1.0] Flat-to-flat tolerance for printer hole expansion

// Exact nominal flat-to-flat sizes of the nuts
HexFlat9mm = 9.0;
HexFlatM6 = 10.2;  // Derived from old 11.9 corner-to-corner (10.3 flat-to-flat minus 0.1 tolerance)
HexFlatM8 = 12.1;  // Derived from old 14.1 corner-to-corner
HexFlatM10 = 14.1; // Derived from old 16.4 corner-to-corner
HexFlatM12 = 15.05; // Derived from old 17.5 corner-to-corner

// Convert nominal flat-to-flat (+ tolerance) into the corner-to-corner multiplier for the base 12mm cylinder
factor9mm = ((HexFlat9mm + hex_nut_tolerance) / cos(30)) / 12;
factorM6  = ((HexFlatM6 + hex_nut_tolerance) / cos(30)) / 12;
factorM8  = ((HexFlatM8 + hex_nut_tolerance) / cos(30)) / 12;
factorM10 = ((HexFlatM10 + hex_nut_tolerance) / cos(30)) / 12;
factorM12 = ((HexFlatM12 + hex_nut_tolerance) / cos(30)) / 12;

handle_style = "Chicken Foot"; // ["Chicken Foot", "Simple Knob", "Hex Rod Adapter"]
handle_diameter = 14; // [10:1:30] Absolute diameter for Simple Knob and Hex Rod
hex_adapter_height = 10; // [5:1:50]
hex_rod_flat_width = 4.0; // [3.5:0.05:5.0]
tool_to_render = "Spanner M6"; // ["All", "9mm Hex", "M6 Hex", "M8 Hex", "M10 Hex", "M12 Hex", "Spanner M6", "Spanner M12", "Standing"]

module knurled_cylinder(h, d, ridges = 12, ridge_d = 2) {
  ridge_center = (d - ridge_d) / 2;
  // increase the core diameter to fill the valleys more, making ridges less exaggerated
  core_d = d - (ridge_d * 0.5);
  union() {
    cylinder(h=h, d=core_d, center=true, $fn=50);
    for (i = [0:ridges - 1]) {
      rotate([0, 0, i * 360 / ridges])
        translate([ridge_center, 0, 0])
          cylinder(h=h, d=ridge_d, center=true, $fn=20);
    }
  }
}

module teardrop_hole(h, d) {
  rotate([90, 0, 0]) rotate([0, 0, 180]) linear_extrude(height=h, center=true) {
        circle(d=d, $fn=30);
        // Add a triangular roof to prevent overhang droop during 3D printing
        // Mathematically perfect 45-degree tangent roof
        polygon(points=[[-d * 0.3535, d * 0.3535], [d * 0.3535, d * 0.3535], [0, d * 0.7071]]);
      }
}

module tool_handle(scale_vec, is_long = false, base_r = 7.5, factor = 1) {
  if (handle_style == "Chicken Foot") {
    if (is_long) {
      scale(scale_vec) translate([-20, -1, 5]) rotate([0, 80, 0]) translate([-4.7, 18, -7.5]) rotate([98, 8, 0]) import("Ceker_smooth.stl", convexity=3);
    } else {
      scale(scale_vec) rotate([0, 0, 0]) translate([-4.7, 18, -7.5]) rotate([98, 8, 0]) import("Ceker_smooth.stl", convexity=3);
    }
    translate([0, 0, 4 - 1.2]) cylinder(h=8, r1=base_r, r2=4, center=true);
  } else if (handle_style == "Simple Knob") {
    // Inverse scale the knob so it remains absolute size regardless of the tool's factor
    scale([1/factor, 1/factor, 1/factor]) difference() {
      union() {
        // Calculate transition cylinder to bridge the absolute knob to the scaled shaft
        trans_h = 6.8 + 1.2 * factor;
        trans_z = 3.4 - 0.6 * factor;
        translate([0, 0, trans_z]) cylinder(h=trans_h, r1=base_r * factor, r2=handle_diameter/2, center=true);
        // true ribbed knurled knob for excellent grip
        translate([0, 0, 8.8]) knurled_cylinder(h=18, d=handle_diameter, ridges=round(handle_diameter), ridge_d=2);
      }
      // horizontal hole for threading a string (teardrop shape for printability)
      translate([0, 0, 13]) teardrop_hole(h=20, d=3.5);
    }
  } else if (handle_style == "Hex Rod Adapter") {
    // Inverse scale the adapter so it remains absolute size regardless of the tool's factor
    scale([1/factor, 1/factor, 1/factor]) difference() {
      union() {
        // cone transition mathematically calculated to perfectly bridge the gap to the scaled shaft
        trans_h = 3.8 + 1.2 * factor;
        trans_z = 1.9 - 0.6 * factor;
        translate([0, 0, trans_z]) cylinder(h=trans_h, r1=base_r * factor, r2=handle_diameter/2, center=true);
        // thin extension with true ribbed grip
        translate([0, 0, 2.8 + hex_adapter_height / 2]) knurled_cylinder(h=hex_adapter_height, d=handle_diameter, ridges=round(handle_diameter), ridge_d=2);
      }
      // Hex rod cutout. Since the entire adapter is inverse-scaled, we just use absolute size!
      translate([0, 0, 2.8 + hex_adapter_height / 2]) cylinder(h=hex_adapter_height + 15, d=hex_rod_flat_width / cos(30), center=true, $fn=6);
    }
  }
}

if (tool_to_render == "All") {
  color("yellow") translate([120, 60, 0]) natural_9mm();
  color("hotpink") translate([60, 0, 0]) natural_M6();
  color("DimGray") natural_M8();
  translate([-60, 0, 0]) natural_M10();
  color("indigo") translate([-120, 0, 0]) natural_M12();
  color("orange") translate([120, 0, 0]) natural_spanner(nut_outer_d=8.2, thread_d=5.8, prong_w=1.2, nut_depth=3, factor=factorM8, label="Spanner M6");
  color("cyan") translate([-180, 0, 0]) natural_spanner(nut_outer_d=17, thread_d=12.5, prong_w=2, nut_depth=4, factor=factorM12, label="Spanner M12");
} else if (tool_to_render == "9mm Hex") {
  natural_9mm();
} else if (tool_to_render == "M6 Hex") {
  natural_M6();
} else if (tool_to_render == "M8 Hex") {
  natural_M8();
} else if (tool_to_render == "M10 Hex") {
  natural_M10();
} else if (tool_to_render == "M12 Hex") {
  natural_M12();
} else if (tool_to_render == "Spanner M6") {
  natural_spanner(nut_outer_d=8.2, thread_d=5.8, prong_w=1.2, nut_depth=3, factor=factorM8, label="Spanner M6");
} else if (tool_to_render == "Spanner M12") {
  natural_spanner(nut_outer_d=17, thread_d=12.5, prong_w=2, nut_depth=4, factor=factorM12, label="Spanner M12");
} else if (tool_to_render == "Standing") {
  difference() {
    standing();
    translate([0, 0, -6]) cylinder(h=12, d=5.1, center=true, $fn=30);
  }
}

//psychobilly_mid();

module psychobilly_mid() {
  scale([factorM8, factorM8, factorM8 / 1]) difference() {
      union() {
        scale([0.8, 0.8, 0.75]) rotate([0, 0, 0]) translate([-2, 0, 2]) import("psychobilly_poisson.stl", convexity=3);
        translate([0, 0, 4 - 1.2]) cylinder(h=8, r1=7.5, r2=4, center=true);
        minkowski() {
          translate([0, 0, -6.2]) cylinder(h=10, r=6.8, center=true);
          sphere(1.2);
        }
      }
      translate([0, 0, -6]) cylinder(h=12, d=12, center=true, $fn=6);
      translate([0, 0, -12.22]) cylinder(h=0.46, d1=12.4, d2=12, center=true, $fn=6);
      translate([0, 0, 2.99]) cylinder(h=6, d1=12, d2=0, center=true, $fn=6);
      //translate([0,0,-2]) rotate([90,0,180]) linear_extrude(3) scale([0.5,0.5,0.5]) text("16");
      translate([0, 0, -8]) writing_custom("Ceker M 8");
    }
}

module writing_custom(text_str = "Ceker M 8") {
  scale([0.13, 0.13, 0.13]) {
    difference() {
      rotate([0, 0, -$t * 360]) {

        for (ltl = [0]) {
          lArr = [text_str][ltl];
          cCirc = 2 * PI * 30;
          for (lp = [0:(len(lArr) - 1)]) {
            rotate((lp * 16) / cCirc * 360 + (ltl * 28)) translate([60, 0, -ltl * 20]) rotate([90, 0, 90])
                  linear_extrude(height=30, center=true) {
                    text(lArr[lp], size=32, font="Linux Biolinum");
                  }
          }
        }
      }
      color("green") cylinder(r=56, h=98, $fn=200, center=true);
    }
  }
}



// natural chicken foot
module natural_M12() {
  scale([factorM12, factorM12, factorM12 / 1]) difference() {
      union() {
        tool_handle([1.1, 1.15, 0.93], factor=factorM12);
        minkowski() {
          translate([0, 0, -6.2]) cylinder(h=10, r=6.8, center=true);
          sphere(1.2);
        }
      }
      translate([0, 0, -6]) cylinder(h=12, d=12, center=true, $fn=6);
      translate([0, 0, -12.22]) cylinder(h=0.46, d1=12.4, d2=12, center=true, $fn=6);
      translate([0, 0, 2.99]) cylinder(h=6, d1=12, d2=0, center=true, $fn=6);
      //translate([0,0,-2]) rotate([90,0,180]) linear_extrude(3) scale([0.5,0.5,0.5]) text("16");
      translate([0, 0, -8]) writing_custom("Ceker M 12");
    }
}

module natural_M10() {
  scale([factorM10, factorM10, factorM10 / 1]) difference() {
      union() {
        tool_handle([1.08, 1.1, 0.96], factor=factorM10);
        minkowski() {
          translate([0, 0, -6.2]) cylinder(h=10, r=6.8, center=true);
          sphere(1.2);
        }
      }
      translate([0, 0, -6]) cylinder(h=12, d=12, center=true, $fn=6);
      translate([0, 0, -12.22]) cylinder(h=0.46, d1=12.4, d2=12, center=true, $fn=6);
      translate([0, 0, 2.99]) cylinder(h=6, d1=12, d2=0, center=true, $fn=6);
      //translate([0,0,-2]) rotate([90,0,180]) linear_extrude(3) scale([0.5,0.5,0.5]) text("16");
      translate([0, 0, -8]) writing_custom("Ceker M 10");
    }
}

module natural_M8() {
  scale([factorM8, factorM8, factorM8 / 1]) difference() {
      union() {
        tool_handle([1.06, 1.08, 1.01], factor=factorM8);
        minkowski() {
          translate([0, 0, -6.2]) cylinder(h=10, r=6.8, center=true);
          sphere(1.2);
        }
      }
      translate([0, 0, -6]) cylinder(h=12, d=12, center=true, $fn=6);
      translate([0, 0, -12.22]) cylinder(h=0.46, d1=12.4, d2=12, center=true, $fn=6);
      translate([0, 0, 2.99]) cylinder(h=6, d1=12, d2=0, center=true, $fn=6);
      //translate([0,0,-2]) rotate([90,0,180]) linear_extrude(3) scale([0.5,0.5,0.5]) text("16");
      translate([0, 0, -8]) writing_custom("Ceker M 8");
    }
}

module natural_9mm() {
  scale([factor9mm, factor9mm, factor9mm / 1]) difference() {
      union() {
        tool_handle([1.25, 1.25, 1.1], factor=factor9mm);
        minkowski() {
          translate([0, 0, -7.7]) cylinder(h=13, r=6.8, center=true);
          sphere(1.2);
        }
      }
      translate([0, 0, -8]) cylinder(h=16, d=12, center=true, $fn=6);
      translate([0, 0, -15.22]) cylinder(h=0.46, d1=12.4, d2=12, center=true, $fn=6);
      translate([0, 0, 2.99]) cylinder(h=6, d1=12, d2=0, center=true, $fn=6);
      //translate([0,0,-2]) rotate([90,0,180]) linear_extrude(3) scale([0.5,0.5,0.5]) text("16");
      translate([0, 0, -8]) writing_custom("Ceker 9mm");
    }
}

module natural_M6() {
  scale([factorM6, factorM6, factorM6 / 1]) difference() {
      union() {
        tool_handle([1.2, 1.2, 1.07], factor=factorM6);
        minkowski() {
          translate([0, 0, -7.7]) cylinder(h=13, r=6.8, center=true);
          sphere(1.2);
        }
      }
      translate([0, 0, -8]) cylinder(h=16, d=12, center=true, $fn=6);
      translate([0, 0, -15.22]) cylinder(h=0.46, d1=12.4, d2=12, center=true, $fn=6);
      translate([0, 0, 2.99]) cylinder(h=6, d1=12, d2=0, center=true, $fn=6);
      //translate([0,0,-2]) rotate([90,0,180]) linear_extrude(3) scale([0.5,0.5,0.5]) text("16");
      translate([0, 0, -8]) writing_custom("Ceker M 6");
    }
}

//long sleeve

module natural_long(factor=1) {
  scale([factor, factor, factor / 1]) difference() {
      union() {
        tool_handle([1, 1.1, 0.88], is_long=true, factor=factor);
        minkowski() {
          translate([0, 0, -16.2]) cylinder(h=30, r=6.3, center=true);
          sphere(1.2);
        }
      }
      translate([0, 5, -16]) cylinder(h=32, d=12, center=true, $fn=6);
      translate([0, 5, 2.99]) cylinder(h=6, d1=12, d2=0, center=true, $fn=6);
      translate([0, 5, -32.22]) cylinder(h=0.46, d1=12.4, d2=12, center=true, $fn=6);
      //translate([0,0,-2]) rotate([90,0,180]) linear_extrude(3) scale([0.5,0.5,0.5]) text("16");
      translate([0, 0, -8]) writing_custom("Ceker Long");
    }
}

// 3d chicken foot

module standing() {

  difference() {
    if (handle_style == "Chicken Foot") {
      scale([1.06, 1.08, 1.01]) rotate([0, 0, 0]) translate([-4.7, 18, -7.5]) rotate([98, 8, 0]) import("Ceker_smooth.stl", convexity=3);
    } else {
      translate([0, 0, 8.8]) cylinder(h=18, d=24, center=true, $fn=12);
    }
  }

  difference() {
    minkowski() {
      translate([0, 0, 0]) rotate([180, 0, 0]) cylinder(h=4, r=7.5, center=false);
      sphere(1.2);
    }
  }
}

module natural_spanner(nut_outer_d = 10, thread_d = 6.5, prong_w = 1.5, nut_depth = 3, factor = 1, label = "", rim_depth = 1.5) {
  // Calculate inverse-scaled dimensions so absolute mm values are exact after the factor scaling
  inv_nut_d = nut_outer_d / factor;
  inv_thread_d = thread_d / factor;
  inv_prong_w = prong_w / factor;
  inv_nut_depth = nut_depth / factor;
  inv_rim = rim_depth / factor;

  // driver tip outer diameter is the nut cutout + 4mm (for 2mm walls)
  inv_driver_outer_d = inv_nut_d + 4;

  // Only use the sleek thin shaft for the Hex Rod Adapter. Use the classic fat cone for the others.
  use_thin_shaft = (handle_style == "Hex Rod Adapter");
  r1_val = (inv_driver_outer_d / 2) - 1.2;
  top_r = use_thin_shaft ? r1_val : 6.8;
  actual_base_r = use_thin_shaft ? (inv_driver_outer_d / 2) : 7.5;

  // Calculate the precise shaft radius at Z = -8 so the text perfectly embeds 0.5mm into it
  // The cylinder goes from Z = -14.2 to Z = -1.2 (length 13), so Z=-8 is 6.2mm up from the bottom
  shaft_r_at_text = r1_val + (6.2 / 13) * (top_r - r1_val) + 1.2;

  scale([factor, factor, factor / 1]) difference() {
      union() {
        // Pass the precise base radius so the handle seamlessly flows into the shaft
        tool_handle([1.2, 1.2, 1.07], base_r=actual_base_r, factor=factor);
        minkowski() {
          translate([0, 0, -7.7]) cylinder(h=13, r1=r1_val, r2=top_r, center=true);
          sphere(1.2);
        }
      }

      // Central hole for the threaded shaft
      translate([0, 0, -15]) cylinder(h=25, d=inv_thread_d, center=true, $fn=50);

      // Cutout for the nut body. We subtract this from the bottom of the driver.
      translate([0, 0, -15.4 + inv_nut_depth / 2 - 0.05])
        difference() {
          // Main cavity for the nut
          cylinder(h=inv_nut_depth + 0.1, d=inv_nut_d, center=true, $fn=50);
          // Leave material for the prongs, shifted up to create an empty alignment rim
          translate([0, 0, inv_rim + 0.05])
            cube([inv_nut_d + 2, inv_prong_w, inv_nut_depth + 1], center=true);
        }

      // Optional Label
      if (label != "") {
        // Scale the text ring so its inner face perfectly embeds 0.5mm into the shaft
        translate([0, 0, -8])
          scale([(shaft_r_at_text - 0.5) / 7.28, (shaft_r_at_text - 0.5) / 7.28, 1])
            writing_custom(label);
      }
    }
}
