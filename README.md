# 🔒 Software Security Fuzzing Project

This project explores **fuzz testing** using [Google’s OSS-Fuzz](https://github.com/google/oss-fuzz) infrastructure.  
The goal was to analyze and improve existing fuzzing harnesses, increase code coverage and finally reproduce a crash as a Proof of Concept (PoC).  

---

## 🛠️ Project Overview

- **Part 1: Baseline fuzzing**  
  Compared fuzzing runs with and without an initial seed corpus, measuring the impact on coverage.  

- **Part 2: Harness analysis**  
  Investigated significant uncovered code regions in **libpng** using OSS-Fuzz Introspector.  
  Identified two critical functions that were not being fuzzed:  
  - `png_set_quantize`: complex function for color quantization, never executed due to missing harness calls and corpus seeds.  
  - `png_get_tRNS`: transparency handling function, uncovered because not reachable from the harness.  
  📑 See [`assignment_part2.pdf`](assignment_part2.pdf) for details.  

- **Part 3: Improving fuzzers**  
  Implemented modifications to the `libpng_read_fuzzer` harness:  
  - Added direct calls to `png_set_quantize` (with mock histograms and custom seeds) → raised coverage of `pngrtran.c` from **30.17% to 40.39%** and almost fully covered `png_set_quantize`.  
  - Added direct call to `png_get_tRNS` → increased coverage of `pngget.c` from **3.50% to 8.09%** and fully covered `png_get_tRNS`.  
  Overall libpng coverage rose from **41.83% to 44.06%**.  

- **Part 4: Crash reproduction**  
  Reproduced a known use-after-free vulnerability in `png_image_free` (CVE-2019-7317), confirmed its exploitability and verified that the official patch prevents it.  

---

## 📊 Results

- **Seed corpora matter:** Fuzzing without seeds reduced coverage by ~40%, highlighting their importance.  
- **Harness limitations:** Many functions (e.g., `png_set_quantize`, `png_handle_iCCP`) remained untouched due to missing calls or corpus inputs.  
- **Improvements worked:** Coverage increased in targeted regions, validating the effectiveness of harness updates.  
- **Crash triage:** Confirmed exploitability of a use-after-free bug and analyzed its severity.  

---

## 📂 Repository Structure

.
├── part1/ # Baseline fuzzing (with vs. without corpus)
│ ├── run.w_corpus.sh
│ ├── run.w_o_corpus.sh
│ └── PART1_RESULT_*/ # Generated results: oss-fuzz logs + coverage reports
│
├── part3/ # Fuzzer improvements
│ ├── improve1/
│ │ ├── run.improve1.sh
│ │ └── PART3_IMPROVE1/ # Results (oss-fuzz logs + coverage reports)
│ └── improve2/
│ ├── run.improve2.sh
│ └── PART3_IMPROVE2/
│
├── part4/ # Crash reproduction
│ ├── run.poc.sh
│ └── PART4_POC/ # PoC + oss-fuzz crash artifacts
│
├── assignment_part2.pdf # Harness analysis
├── CS412_fuzzinglab_assignment.pdf # Working instructions
└── README-original.md # Original student README with run instructions

---

## 🚀 How to Run

1. Navigate to the relevant part (e.g. `cd part1`)  
2. Run the provided script (`./run.w_corpus.sh`, `./run.improve1.sh`, etc.)  
3. Let the fuzzer run for ~4 hours (scripts follow the course assignment spec)  
4. Inspect results in the generated folders (`oss-fuzz/`, `coverageReport/`)  

*See [README-original.md](README-original.md) for detailed run instructions as submitted for grading.*  

---

## 🙌 Course

This project was completed as part of the **Software Security (SoftSec)** course at **EPFL**, focusing on:  
- Automated vulnerability discovery with fuzzing  
- Coverage-guided input generation  
- Improving fuzzing harnesses and reproducing crashes  

---

## 👥 Team

This project was a team effort by:  
 
- **Raphaël Küpfer**  
- **Simone Andreani**  
- **Samuel Tepoorten**
- **Alexander Odermatt**

---

✨ *Exploring fuzzing as a practical tool for software security testing and vulnerability discovery.*  
