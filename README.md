# APB / TDM Arbiter UVM Testbench

A standalone UVM verification environment for the `apb_tdm_gpio_soc` design under test (DUT): an APB slave with GPIO, a 4-client round-robin TDM arbiter, and system registers.

Written from scratch and simulated with **Verilator 5.054** on Linux. It includes APB and sideband agents, a cycle-accurate reference model, a scoreboard, functional coverage, and SystemVerilog Assertions (SVA).

---

## Environment Architecture

| Component | Role |
|---|---|
| **APB Agent** | Drives and monitors the APB register interface (`PSEL`, `PENABLE`, `PADDR`, `PWRITE`, `PWDATA`, `PRDATA`, `PREADY`, `PSLVERR`). |
| **Sideband Agent** | Drives physical inputs (`gpio_in`, `tdm_req`) and monitors physical outputs (`gpio_out`, `gpio_oe`, `tdm_grant`, `tdm_slot`). |
| **Reference Model** | Software clone of the DUT. Tracks internal state (`data_q`, `dir_q`, `slot`, `global_enable`) and predicts cycle-accurate TDM grants. |
| **Scoreboard** | Compares APB read data and sideband outputs against the reference model every clock cycle. |
| **Coverage** | Functional covergroups over register access and arbiter behavior. |
| **Assertions** | SVA checks bound to the DUT interface (see below). |

---

## Test Suite

| Test | What it checks |
|---|---|
| `id_test` | System ID register value and basic APB read functionality. |
| `reset_test` | Every register comes out of reset with its specified default. |
| `gpio_test` | GPIO writes, reads, set/clear operations, and global-enable gating. |
| `error_addr_test` | `PSLVERR` is asserted for invalid addresses. |
| `arb_test` | 4-client round-robin TDM arbitration running concurrently with APB configuration. |
| `random_test` | 50 random APB transactions to stress the reference model. |

---

## Regression Results

All tests pass with zero errors and zero fatals.

```text
========================================
         UVM REGRESSION RESULTS
========================================
id_test              : PASS  (Errors: 0, Fatals: 0)
reset_test           : PASS  (Errors: 0, Fatals: 0)
gpio_test            : PASS  (Errors: 0, Fatals: 0)
error_addr_test      : PASS  (Errors: 0, Fatals: 0)
arb_test             : PASS  (Errors: 0, Fatals: 0)
random_test          : PASS  (Errors: 0, Fatals: 0)
========================================
```

### Functional Coverage

17 of 20 covergroup bins hit (85%).

### SVA Assertions

Four protocol assertions are enforced at runtime:

1. `PREADY` is asserted only during the ACCESS phase.
2. `PSLVERR` is asserted only during the ACCESS phase.
3. `tdm_grant` is strictly one-hot or zero.
4. `tdm_grant` is asserted only when a request is active.

---

## Getting Started

### Prerequisites

- Verilator (developed on 5.054; 5.020 or newer should work)
- UVM 1800.2 library
- A C++ compiler (`g++`)

### Run

```bash
# 1. Point to your UVM library
export UVM_HOME=/path/to/uvm-1800.2-2020.3.1

# 2. Go to the simulation directory
cd sim

# 3. Run the full regression
make regress

# 4. View the summary
cat results_summary.txt
```

### Optional: HTML coverage report

```bash
verilator_coverage --annotate coverage_report coverage.dat
```

Open `coverage_report/` to browse line-by-line coverage.

---

## Known Gaps

- 3 of 20 functional coverage bins are not yet hit.
- Verification is simulation-only (no formal proofs).
