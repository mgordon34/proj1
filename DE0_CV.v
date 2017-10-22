module DE0_CV (
  input CLOCK_50,
  input [9:0] SW,
  input [2:0] KEY,
  output [6:0] HEX0,
  output [6:0] HEX1,
  output [6:0] HEX2,
  output [6:0] HEX3,
  output [9:0] LEDR
);

// ==============================================
// Key Press 0
// ==============================================
key_press key0p(
	.clock				(CLOCK_50),
	.key					(KEY[0]),
	.key_press			(key0_press)
);

// ==============================================
// Key Press 1
// ==============================================
key_press key1p(
	.clock				(CLOCK_50),
	.key					(KEY[1]),
	.key_press			(key1_press)
);

// ==============================================
// Key Press 2
// ==============================================
key_press key2p(
	.clock				(CLOCK_50),
	.key					(KEY[2]),
	.key_press			(key2_press)
);

TimerController timer(
  .clk (CLOCK_50),
  .start_stop (key2_press),
  .set (key1_press),
  .reset (key0_press),
  .sw_tens (SW[7:4]),
  .sw_ones (SW[3:0]),
  .hex0 (HEX0),
  .hex1 (HEX1),
  .hex2 (HEX2),
  .hex3 (HEX3),
  .ledr (LEDR)
);

endmodule
