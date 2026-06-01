function gw -d 'run ghciwatch with additional fields for my local workflow'
    services up
    make ghciwatch | tee .devel-logs/output.txt
end
