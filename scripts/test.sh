#!/usr/bin/env bash
set -eu

for test in tests/*; do
  ./$test
done