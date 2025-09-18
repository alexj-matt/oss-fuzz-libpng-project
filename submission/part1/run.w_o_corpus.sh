#!/bin/bash

# Variables
ACTUAL_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR="$ACTUAL_DIR/PART1_RESULT_W_O_CORPUS"
COV_REPORT="$ROOT_DIR/coverageReport"

OSS_FUZZ_DIR="$ROOT_DIR/oss-fuzz"
LIBPNG_DIR="$OSS_FUZZ_DIR/projects/libpng/libpng_Custom_Repo"

SEED_CORPUS="$OSS_FUZZ_DIR/build/out/libpng/seedCorpus"

# Clone repositories
cloneRepositories() {
  echo "Cloning oss-fuzz..."
  if [ -d "$OSS_FUZZ_DIR" ]; then
    sudo rm -rf "$OSS_FUZZ_DIR"
  fi
  git clone https://github.com/google/oss-fuzz.git "$OSS_FUZZ_DIR"
  pushd "$OSS_FUZZ_DIR"
  git checkout cafd7a0
  popd

  echo -e "\nCloning libpng..."
  git clone https://github.com/pnggroup/libpng.git "$LIBPNG_DIR"
  pushd "$LIBPNG_DIR"
  git checkout ea12796
  popd
}

# Apply diff
applyDiff() {
  echo -e "\nApplying diff to oss-fuzz..."
  if [ -f $ACTUAL_DIR/oss-fuzz.diff ]; then
    pushd "$OSS_FUZZ_DIR"
    git apply "$ACTUAL_DIR/oss-fuzz.diff"
    popd
  fi

  echo -e "\nApplying diff to libpng..."
  if [ -f $ACTUAL_DIR/project.diff ]; then
    pushd "$LIBPNG_DIR"
    git apply "$ACTUAL_DIR/project.diff"
    popd
  fi
}

# Create directories
initDirectories() {
  echo "Initializing Directories..."
  if [ -d "$COV_REPORT" ]; then
      sudo rm -rf "$COV_REPORT"
  fi
  mkdir -p "$COV_REPORT"

  if [ -d "$SEED_CORPUS" ]; then
      sudo rm -rf "$SEED_CORPUS"
  fi
  mkdir -p "$SEED_CORPUS"
}

# Build fuzzers
buildFuzzers() {
  echo "Building fuzzers (this may take a while)..."
  python3 "$OSS_FUZZ_DIR/infra/helper.py" build_image libpng --pull
  python3 "$OSS_FUZZ_DIR/infra/helper.py" build_fuzzers libpng
}

# Run fuzzers
runFuzzers() {
  echo -e "\n+++++++++++++++++++++++++++++++"
  echo "Running fuzzers (ctr+c to stop)"
  echo "+++++++++++++++++++++++++++++++"
  python3 "$OSS_FUZZ_DIR/infra/helper.py" run_fuzzer libpng libpng_read_fuzzer \
      --corpus-dir "$SEED_CORPUS" &>/dev/null
}

# Create coverage report
createCoverageReport() {
  echo -e "\nFuzzing stopped !!!"
  echo "Creating coverage report (this may take a while)..."

  python3 "$OSS_FUZZ_DIR/infra/helper.py" build_fuzzers --sanitizer coverage libpng
  python3 "$OSS_FUZZ_DIR/infra/helper.py" coverage libpng --fuzz-target=libpng_read_fuzzer --corpus-dir="$SEED_CORPUS" --no-serve


  REPORT_PATH="$OSS_FUZZ_DIR/build/out/libpng/report_target/libpng_read_fuzzer"
  if [ -d "$REPORT_PATH" ]; then
    cp -r "$REPORT_PATH"/* "$COV_REPORT/"
  fi
}

main() {
  cloneRepositories
  applyDiff
  initDirectories
  buildFuzzers
  runFuzzers
  createCoverageReport
}

main