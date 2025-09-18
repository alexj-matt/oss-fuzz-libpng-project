# SoftSec Fuzzing Repository

## Important Remark

The scripts must be executed in their current location (they use the diff files and possibly others, depending on the part).

The steps are :

1. Go to the location of the script.
2. Run the script.  
3. Wait 4 hours.  
4. Press the keyboard interrupt `Ctrl+C` (after 4 hours) and wait for the report to be generated.

*Remark : For part4, after the crash the script quit automatically.*

After step (4) a new directory is generated in the following way (PARTX_) :

### Part 1 :

```
/part1
├── run.w_corpus.sh
├── run.w_o_corpus.sh
├── ...
├── PART1_RESULT_W_CORPUS (after run.w_corpus.sh)
    ├── coverageReport
    └── oss-fuzz
└── PART1_RESULT_W_O_CORPUS (after run.w_o_corpus.sh)
    ├── coverageReport
    └── oss-fuzz
```

### Part 3 :

```
/part3
├── coverage_noimprove
├── improve1
    ├── coverage_improve1
    ├── run.improve1.sh
    ├── ...
    └── PART3_IMPROVE1 (after run.improve1.sh)
        ├── coverageReport
        └── oss-fuzz
└── improve2
    ├── coverage_improve2
    ├── run.improve2.sh
    ├── ...
    └── PART3_IMPROVE2 (after run.improve2.sh)
        ├── coverageReport
        └── oss-fuzz
```

### Part 4 :

```
/part4
├── run.poc.sh
├── ...
└── PART4_POC (after run.poc.sh)
    └── oss-fuzz
```
