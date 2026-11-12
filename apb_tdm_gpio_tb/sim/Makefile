ifndef UVM_HOME
$(error UVM_HOME is not set. Run 'export UVM_HOME=/path/to/uvm' in your terminal)
endif

TEST = id_test

all: run

run:
	@echo "Translating and compiling with Verilator..."
	verilator --cc --exe --build -j 0 \
	          -Wno-fatal -Wno-lint \
	          --timescale 1ns/1ps \
	          +incdir+../tb \
	          -I$(UVM_HOME)/src \
	          --top-module tb_top \
	          -f files.f \
	          $(UVM_HOME)/src/uvm_pkg.sv \
	          tb_top.cpp
	@echo "Running simulation..."
	./obj_dir/Vtb_top +UVM_TESTNAME=$(TEST)

clean:
	rm -rf obj_dir