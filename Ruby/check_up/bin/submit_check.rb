#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'checkup/job'

job = Checkup::Job.new('http://mschenck.com')
job_id = job.submit
puts "Running job id: #{job_id}"

result = false

while not result
  sleep 5
  result = job.fetch job_id
end

