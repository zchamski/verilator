// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed into the Public Domain, for any use,
// without warranty, 2015 by Johan Bjork.
// SPDX-License-Identifier: CC0-1.0

interface intf;
    logic logic_in_intf;
    modport source(output logic_in_intf);
    modport sink(input logic_in_intf);
endinterface

module modify_interface
(
input logic value,
intf.source intf_inst
);

    export "DPI-C" function set_value;
    function void set_value(int value_in);
        intf_inst.logic_in_intf = value_in[0];
    endfunction

assign intf_inst.logic_in_intf = value;
endmodule

function integer return_3();
    return 3;
endfunction

module t
#(
    parameter N = 6
)();
    intf ifs[N-1:0] ();
    logic [N-1:0] data;
    assign data = {1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1};

    export "DPI-C" function set_data;
    function void set_data(int data_in);
        data = data_in[N-1:0];
    endfunction

    export "DPI-C" function set_intf_data;
    function void set_intf_data(int data_in);
        ifs[0].logic_in_intf = data_in[0];
        ifs[1].logic_in_intf = data_in[1];
        ifs[2].logic_in_intf = data_in[2];
        ifs[3].logic_in_intf = data_in[3];
        ifs[4].logic_in_intf = data_in[4];
        ifs[5].logic_in_intf = data_in[5];
    endfunction

    generate
        genvar i;
        for (i = 0;i < 3; i++) begin
            assign ifs[i].logic_in_intf  = data[i];
        end
    endgenerate
    modify_interface m3 (
        .value(data[return_3()]),
        .intf_inst(ifs[return_3()]));

    modify_interface m4 (
    	.value(data[4]),
    	.intf_inst(ifs[4]));

    modify_interface m5 (
    	.value(~ifs[4].logic_in_intf),
    	.intf_inst(ifs[5]));

    generate
        genvar j;
        for (j = 0;j < N-1; j++) begin
            initial begin
               if (ifs[j].logic_in_intf != data[j])
                    $display("!!!ERROR!!! ifs[%0d].logic_in_intf (%0d) != data[%0d] (%0d)",
                       j, ifs[j].logic_in_intf, j, data[j]);
            end
        end
    endgenerate

    initial begin
       if (ifs[5].logic_in_intf != ~ifs[4].logic_in_intf) $display("BAD");
       $write("*-* All Finished *-*\n");
       $finish;
    end
endmodule
