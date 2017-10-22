module digit_timer(
  input                             clk,
  input                             reset,
  input                             enable,
  input                             step,
  input                             set,
  input  [ 3 : 0 ]                  set_value,
  input  [ 3 : 0 ]                  max_count,
  output                            carry,
  output                            done,
  output [ 3 : 0 ]                  count_out
);

  reg [ 3: 0 ] count = 'b0;
  reg triggered = 'b0;

  always@(posedge clk)
  begin
    if (reset)
      count <= 0;
    if (set)
      count <= set_value;
    else if (enable)
    begin
      if (step & ~triggered)
      begin
        triggered = 'b1;
        if (done)
          count <= max_count;
        else
          count <= count - 1'b1;
      end
      else if (~step & triggered)
        triggered = 'b0;
    end
  end

  assign count_out = count;
  assign done = count == 'b0;
  assign carry = count == max_count;

endmodule
