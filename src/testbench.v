module testbench();

reg clock;
reg enable;
reg reset;

integer data_fd;
integer ok;

reg [31:0] sample;
reg [15:0] threshold;
reg [15:0] cooldown;
reg [31:0] skip;

wire trigger;

powertrigger pt (
    .clock(clock),
    .enable(enable),
    .reset(reset),
    .sample(sample),
    .threshold(threshold),
    .cooldown(cooldown),
    .skip(skip),
    .trigger(trigger)
);

always begin
    #1
    clock = !clock;
end

initial begin
    data_fd = $fopen("samples.dat", "rb");
    if (data_fd == 0) begin
        $display("Failed to open test data file");
        $finish;
    end
    clock <= 0;
    reset <= 1;
    enable <= 0;

    // Threshold used for triggering initial packet detection sequence.
    threshold <= 100;

    // How long we should wait before lowering the trigger signal and look for
    // the next one.
    cooldown <= 80;

    // How many clock cycles to wait before starting to look for a trigger
    // signal. One clock cycle corresponds to one I/Q sample.
    skip <= 0;

    // Activate testbench at second clock cycle. This is important as the
    // modules run their individual setup during the first cycle.
    # 2
    reset <= 0;
    enable <= 1;
end

always @(posedge clock) begin

  ok = $fread(sample, data_fd);

  if (!$feof(data_fd)) begin
      $monitor(trigger);
  end
  else begin
      $display("All samples parsed");
      $finish;
  end
end

endmodule;
