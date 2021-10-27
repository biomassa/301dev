import("stdfaust.lib");

xytoms (x,y) = (x+y),(x-y);
ctrl (m,s) = (m*hslider("mAmt",1,0,1,0.01)), (s*hslider("sAmt",1,0,1,0.01));
mstoxy (m,s) = (m+s),(m-s);

// Name the ins and outs of the `process` function for use in the er-301 object
declare er301_in1 "InL";
declare er301_in2 "InR";
declare er301_out1 "OutL";
declare er301_out2 "OutR";

// main()
process = xytoms : ctrl : mstoxy;