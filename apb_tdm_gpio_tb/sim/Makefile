ifndef UVM_HOME
$(error UVM_HOME is not set. Run 'export UVM_HOME=/path/to/uvm' in your terminal)
endif

TEST = id_test

VERILATOR_FLAGS = --cc --exe --build -j 8 \
                  -Wno-fatal -Wno-lint \
                  --timescale 1ns/1ps \
                  --timing \
				  --coverage \
                  --main \
                  +define+UVM_NO_DPI \
                  +incdir+../tb \
                  -I$(UVM_HOME)/src \
                  --top-module tb_top

all: run

run:
	@echo "Translating and compiling with Verilator..."
	ulimit -s unlimited; \
	verilator $(VERILATOR_FLAGS) \
	          $(UVM_HOME)/src/uvm_pkg.sv \
	          -f files.f
	@echo "Running simulation..."
	./obj_dir/Vtb_top +UVM_TESTNAME=$(TEST)

regress:
	@echo "Compiling Verilator Model..."
	ulimit -s unlimited; \
	verilator $(VERILATOR_FLAGS) \
	          $(UVM_HOME)/src/uvm_pkg.sv \
	          -f files.f
	
	@echo "Starting Regression..."
	@rm -f results_summary.txt
	@echo "========================================" > results_summary.txt
	@echo "         UVM REGRESSION RESULTS         " >> results_summary.txt
	@echo "========================================" >> results_summary.txt
	
	@for t in id_test reset_test gpio_test error_addr_test arb_test random_test; do \
		echo "Running $$t..."; \
		./obj_dir/Vtb_top +UVM_TESTNAME=$$t > "log_$$t.txt" 2>&1; \
		ERR=$$(grep "UVM_ERROR :" "log_$$t.txt" | awk '{print $$3}'); \
		FATAL=$$(grep "UVM_FATAL :" "log_$$t.txt" | awk '{print $$3}'); \
		if [ "$$ERR" = "0" ] && [ "$$FATAL" = "0" ]; then \
			STATUS="PASS"; \
		else \
			STATUS="FAIL"; \
		fi; \
		printf "%-20s : %-5s (Errors: %s, Fatals: %s)\n" "$$t" "$$STATUS" "$$ERR" "$$FATAL" | tee -a results_summary.txt; \
	done
	
	@echo "========================================" >> results_summary.txt
	@echo "Regression Complete. Summary saved to results_summary.txt"

clean:
	rm -rf obj_dir
	rm -f log_*.txt results_summary.txt