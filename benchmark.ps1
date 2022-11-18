$TEST = "benchmark"
$RUNS = 5

nim c -d:release --opt:speed tests/$TEST

$total_seconds = 0.0
foreach ($run_n in 1..$RUNS) {
  echo "Starting run $run_n"
  $result = measure-command { &"./tests/$TEST.exe" }
  $total_seconds += $result.TotalSeconds
  echo "Run $run_n completed in $($result.TotalSeconds) seconds"
}

echo "Test complete. average execution time: $($total_seconds / $RUNS) seconds"
