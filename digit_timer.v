module digit_timer(
  input                             clk,
  input                             reset,
  input                             enable,
  input                             step,
  input                             set,
  input  [ 3 : 0 ]                  set_value,
  input  [ 3 : 0 ]                  max_count,
  output reg                        carry,
  output                            done,
  output [ 3 : 0 ]                  count_out
);

  reg [ 3: 0 ] count = 'b0;
  reg triggered = 'b0;

  always@(posedge clk)
  begin
    if (reset)
      count = 0;
    else if (set)
    begin
      if (set_value > max_count)
        count = max_count;
      else
        count = set_value;
    end
    else if (enable)
    begin
      if (step & ~triggered)
      begin
        triggered = 'b1;
        if (done)
        begin
          count = max_count;
          carry = 1'b1;
        end
        else
        begin
          count <= count - 1'b1;
          carry = 1'b0;
        end
      end
      else if (~step & triggered)
        triggered = 'b0;
    end
  end

  assign count_out = count;
  assign done = count == 'b0;

endmodule
