# Resque tasks
require 'resque/tasks'
require 'resque/scheduler/tasks'
require 'logger'

task "resque:setup" => :environment

namespace :resque do
  task :setup do
    require 'resque'
    require 'resque-scheduler'

    logger = Logger.new(STDOUT)
    logger.formatter = proc do |severity, datetime, progname, msg|
      formatted_datetime = datetime.strftime("%Y-%m-%d %H:%M:%S.") << datetime.usec.to_s[0..2].rjust(3)
      "#{formatted_datetime} [#{severity}] #{msg} (pid:#{$$})\n"
    end
    Resque.logger = logger
    Resque.logger.level = Logger::INFO
    #Resque.logger.level = Logger::DEBUG

    # you probably already have this somewhere
    Resque.redis = 'localhost:6379'

    # If you want to be able to dynamically change the schedule,
    # uncomment this line.  A dynamic schedule can be updated via the
    # Resque::Scheduler.set_schedule (and remove_schedule) methods.
    # When dynamic is set to true, the scheduler process looks for
    # schedule changes and applies them on the fly.
    # Note: This feature is only available in >=2.0.0.
    # Resque::Scheduler.dynamic = true

    # The schedule doesn't need to be stored in a YAML, it just needs to
    # be a hash.  YAML is usually the easiest.
    Resque.schedule = YAML.load_file('config/workers_schedule.yml')
  end
end
