require 'resque'
require 'checkup'
require 'checkup/wheresit'
require 'checkup/persist'

module Checkup
  class Job < Base
    attr_accessor :uri

    def initialize uri
      super()
      @uri = uri
      @wheresitup = Checkup::Wheresit.new
    end

    def submit
      job_id = @wheresitup.submit_check @uri
      check_job = Checkup::CheckJob.create
      check_job.add job_id
      check_job.save
      debug "Running job id: #{job_id}"
      job_id
    end

    def fetch job_id
      result = @wheresitup.fetch_result job_id
      success, failed = 0
      failedcities = Hash.new
      resultset = Hash.new

      result['return']['summary'].each do |k,v|
        if v.http == "in progress" then
          return false
        end

        if v.http[0].responseCode == 200 then
          success.next
        else
          failed.next
          failedcities[k] = v
        end
      end

      resultset[] = success
      resultset[] = failed
      resultset[] = failedcities
      resultset
    end
  end
end

