module TimerController (
  input clk,
  input start_stop,
  input set,
  input reset,
  input [7:4] sw_tens,
  input [3:0] sw_ones,
  output [6:0] hex0,
  output [6:0] hex1,
  output [6:0] hex2,
  output [6:0] hex3,
  output [9:0] ledr
);

// ==============================================
// CLOCK
// ==============================================
wire clk_1Hz;
clk_divider clk_div(clk, clk_1Hz);
// ==============================================
//

// ==============================================
// STATE MACHINE
// ==============================================
parameter 	IDLE 		= 3'b000,
		SET_SECONDS 		= 3'b001,
		SET_MINUTES 		= 3'b010,
		STOP         		= 3'b011,
    START           = 3'b100,
    DONE            = 3'b101;
reg [2:0] state;
reg [2:0] 		next_state;
wire done;
// ==============================================


always @(posedge clk)
begin
	if (reset) begin
		state <= IDLE;
	end
	else
		state <= next_state;
end

always @(*)
begin
	next_state = state;
	case(state)
    IDLE: begin
      if (set) begin
        next_state = SET_SECONDS;
      end
		end
    SET_SECONDS: begin
      if (set) begin

        next_state = SET_MINUTES;
      end
		end
    SET_MINUTES: begin
      if (set) begin
        next_state = STOP;
      end
		end
    STOP: begin
      if (start_stop) begin
        next_state = START;
      end
		end
    START: begin
      if (start_stop) begin
        next_state = STOP;
      end
      else if (done) begin
        next_state = DONE;
      end
		end
    DONE: begin
    end
		default: next_state = IDLE;
	endcase
end
// ==============================================


// ==============================================
// Count Down
// ==============================================
localparam COUNTER_WIDTH = 4;
wire [ COUNTER_WIDTH -1 : 0 ] sec_ones_count;
wire sec_ones_done;
wire sec_ones_carry;

wire [ COUNTER_WIDTH -1 : 0 ] sec_tens_count;
wire sec_tens_done;
wire sec_tens_carry;

wire [ COUNTER_WIDTH -1 : 0 ] min_ones_count;
wire min_ones_done;
wire min_ones_carry;

wire [ COUNTER_WIDTH -1 : 0 ] min_tens_count;
wire min_tens_done;
wire min_tens_carry;

wire [ COUNTER_WIDTH -1 : 0 ] ones_set;
wire [ COUNTER_WIDTH -1 : 0 ] tens_set;

digit_timer counter_sec_ones (
  .clk            ( clk       ),
  .reset          ( reset         ),
  .enable         ( state == START),
  .step           ( clk_1Hz       ),
  .set            ( state == SET_SECONDS),
  .set_value      ( sw_ones       ),
  .max_count      ( 4'd9          ),
  .carry          ( sec_ones_carry),
  .done           ( sec_ones_done ),
  .count_out      ( sec_ones_count)
);

digit_timer counter_sec_tens (
  .clk            ( clk       ),
  .reset          ( reset        ),
  .enable         ( state == START),
  .step           ( sec_ones_carry       ),
  .set            ( state == SET_SECONDS),
  .set_value      ( sw_tens       ),
  .max_count      ( 4'd5          ),
  .carry          ( sec_tens_carry),
  .done           ( sec_tens_done ),
  .count_out      ( sec_tens_count)
);

digit_timer counter_min_ones (
  .clk            ( clk       ),
  .reset          ( reset       ),
  .enable         ( state == START),
  .step           ( sec_tens_carry),
  .set            ( state == SET_MINUTES),
  .set_value      ( sw_ones       ),
  .max_count      ( 4'd9          ),
  .carry          ( min_ones_carry),
  .done           ( min_ones_done ),
  .count_out      ( min_ones_count)
);

digit_timer counter_min_tens (
  .clk            ( clk       ),
  .reset          ( reset       ),
  .enable         ( state == START),
  .step           ( min_ones_carry),
  .set            ( state == SET_MINUTES),
  .set_value      ( sw_tens       ),
  .max_count      ( 4'd9          ),
  .carry          ( min_tens_carry),
  .done           ( min_tens_done ),
  .count_out      ( min_tens_count)
);

assign done = sec_ones_done
    && sec_tens_done
    && min_ones_done
    && min_tens_done;
// ==============================================


// ==============================================
// Display
// ==============================================
dec2_7seg disp3(min_tens_count[3:0], hex3);
dec2_7seg disp2(min_ones_count[3:0], hex2);
dec2_7seg disp1(sec_tens_count[3:0], hex1);
dec2_7seg disp(sec_ones_count[3:0], hex0);

assign ledr[9:0] = {10{state == DONE && clk_1Hz}};
// ==============================================

endmodule
