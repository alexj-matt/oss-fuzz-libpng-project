#!/bin/bash

# Variables
ACTUAL_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR="$ACTUAL_DIR/PART4_POC"
CRASH="$ACTUAL_DIR/crash"

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
  # git checkout ea12796
  # buggy version of libpng for the POC.
  git checkout eddf902
  popd
}

# Add new Seeds
addNewSeeds() {
  echo -e "\nAdding new seeds..."
  cp -r "$ACTUAL_DIR/custom_seed" "$LIBPNG_DIR"
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
      --corpus-dir "$SEED_CORPUS"
}

reproduce() {
  echo -e "\n+++++++++++++++++++++++++++++++"
  echo "Reproducing the crash"
  echo "+++++++++++++++++++++++++++++++"
  python3 "$OSS_FUZZ_DIR/infra/helper.py" reproduce libpng libpng_read_fuzzer \
      "$CRASH"
}


main() {
  cloneRepositories
  addNewSeeds
  applyDiff
  initDirectories
  buildFuzzers
  #runFuzzers
  reproduce
}

main