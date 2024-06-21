# OrangeCrab FPGA configuring in WSL

Download the necessary tool chain for synthesis, simulation , place and route etc.
It’s advised to use an automated build from the releases page in https://github.com/YosysHQ/oss-cad-suite-build

It is recommeneded to use comman lines for downloading and extracting the zip to ensure the complete functioning
Do not forget to add the path to the bin

For a better idea you can use the https://orangecrab-fpga.github.io/orangecrab-hardware/docs/getting-started/ for verilog examples

Make sure that you make the USB accessible to the linux by https://learn.microsoft.com/en-us/windows/wsl/connect-usb steps. The dfu-util functioning is ensured only if this is done. 

# Loading NEORV32

Download the prebuilt riscv toolchain https://github.com/stnolting/riscv-gcc-prebuilt and add it to the path
Recursively clone the https://github.com/stnolting/neorv32-setups repo. Ensure that all subfoleders are present

To make sure everything works fine, navigate to an example project in the NEORV32 example folder and execute the following command:

/neorv32-setups/neorv32/sw/example/demo_blink_led$ make check

This will test all the tools required for generating NEORV32 executables. Everything is working fine if Toolchain check OK appears at the end

Make sure to download a seperate gcc before running the above command in your WSL using $sudo apt install gcc

Now navigate to the osflow directory in the neorv32-setups 

All the necessary tools are already included in the oss-cad-suite toolkit downloaded
You would need to run the following command to overrun some WSL errors
$ sudo apt-get install zlib1g-dev

Now ideally run the following command in the osflow directory

$ make BOARD=OrangeCrab MinimalBoot

If you are encountering errors such as GHDL not found it would be nostly because yosys cannot find it in the GHDL plugin module. To overrun that use

$ GHDL_PLUGIN_MODULE=ghdl make BOARD=OrangeCrab MinimalBoot

Here ghdl is the one preinstalled using the toolkit

This will give you generated bitstream

Also if the density of your orangecrab is 85k do not forget to add it in the PnR _Bit.mk

To load the bitstream on the orangecrab use 
$dfu-util --alt 0 -D ./neorv32_OrangeCrab_r02-25F_MinimalBoot.bit
where neorv32_OrangeCrab_r02-25F_MinimalBoot.bit is your genertaed bitstream

Hurray! Now you have the Neorv32 processor on your orangecrab!

















