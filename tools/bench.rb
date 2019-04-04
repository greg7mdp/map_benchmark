#!/usr/bin/env ruby

require 'timeout'

cmd_prefix = "" # taskset -c 5,11"

timeout_sec = 15*60

benchs = ARGV
if benchs.empty?
    benchs = `./#{Dir["bench*"].first} l`.split("\n")
end
apps = Dir["bench*"].sort.uniq.shuffle

STDERR.puts "apps:\n\t#{apps.join("\n\t")}"
STDERR.puts "benchmarks:\n\t#{benchs.join("\n\t")}"

bad_commands = {}

10.times do |iter|
    benchs.each do |bench|
        STDERR.puts "iteration #{iter}"
        apps.each do |app|
            cmd = "#{cmd_prefix} ./#{app} #{bench}"
            if (bad_commands.key?(cmd))
                puts "SKIPPING #{app} #{bench}"
            else
                pid = Process.spawn(cmd)
                begin
                    Timeout.timeout(timeout_sec) do
                        Process.wait(pid)
                    end                
                    if ($?.exitstatus != 0)
                        puts "ERROR #{$?.exitstatus}: #{app} #{bench}"
                        bad_commands[cmd] = true
                    end
                rescue Timeout::Error
                    Process.kill('TERM', pid)
                    puts "TIMEOUT: #{app} #{bench}"
                    bad_commands[cmd] = true
                end
            end
        end
        puts
    end
end
