df -Pa 2>/dev/null | grep -v ^$ | tail -n +2  | \
  jq -R -s '
    [
      split("\n") |
      .[] |
      if test("^[a-z/]") then
        gsub(" +"; " ") | split(" ") | {device: .[0], path: .[5], blocks: .[1], blocks_used: .[2], blocks_available: .[3], capacity: .[4]}
      else
        empty
      end
    ]'