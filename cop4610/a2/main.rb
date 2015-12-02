class Job
  attr_accessor :start_time, :duration, :cycles_remaining, :complete_time, :id

  def initialize(id, start_time, duration)
    @id = id
    @start_time = start_time
    @cycles_remaining = @duration = duration
    @complete_time = -1
  end

  def turnaround_time
    complete_time - start_time + 1 # offset for 0
  end
end

class Base
  attr_accessor :file_contents, :time_quantum, :total_cycles, :jobs, :current_time, :current_job_index

  def initialize(text, time_quantum)
    @file_contents = text.split("\n")
    @time_quantum = time_quantum
    @total_cycles = 0
    @jobs = []
    alphabet = (10...36).map { |i| i.to_s 36 }
    file_contents.each_with_index do |line, index|
      start_time = line.split(",")[0].to_i
      duration = line.split(",")[1].to_i

      @total_cycles += duration
      @jobs << Job.new(alphabet[index], start_time, duration)
    end
    @current_job_index = 0
    @current_time = 0
  end

  def current_job
    @jobs[@current_job_index]
  end

  def next_job
    @current_job_index += 1
    @current_job_index = 0 if @current_job_index == jobs.count
  end

  def prev_job
    @current_job_index -= 1
    @current_job_index = jobs.count - 1 if @current_job_index == -1
  end

  def to_s
    total_cycles.times do |i|
      run_steps(i)
    end
    print_table
    ""
  end

  def print_table
    puts type
    print "Job"
    jobs.each_with_index do |job, i|
      print " #{'%003d' % i}"
    end
    puts ""
    print "   "
    jobs.each_with_index do |job, i|
      print " #{'%003d' % job.turnaround_time}"
    end
    puts ""
    print "   "
    jobs.each_with_index do |job, i|
      print " #{'%003d' % job.start_time}"
    end
    puts ""
    print "   "
    jobs.each_with_index do |job, i|
      print " #{'%003d' % job.complete_time}"
    end

  end

  def avg
    jobs.map(&:turnaround_time).instance_eval { reduce(:+) / size.to_f }
  end

  def run_steps(i)
    raise "Implement method!"
  end
end

class FirstComeFirstServe < Base
  def type
    return"FCFS"
  end

  def run_steps(i)
    current_job.cycles_remaining -= 1
    if current_job.cycles_remaining == 0
      current_job.complete_time = i
      next_job
    end
  end
end

class ShortestJobNext < Base
  def type
    "SJN"
  end

  def run_steps(i)
    @sorted_jobs ||= jobs.sort { |job1, job2| job1.cycles_remaining <=> job2.cycles_remaining }
    sorted_jobs = @sorted_jobs

    @current_job_index ||= 0

    while sorted_jobs[@current_job_index].cycles_remaining == 0 || sorted_jobs[@current_job_index].start_time > i
      next_job()
    end

    sorted_jobs[@current_job_index].cycles_remaining -= 1

    if sorted_jobs[@current_job_index].cycles_remaining == 0
      sorted_jobs[@current_job_index].complete_time = i
      @current_job_index = nil
    end
  end
end

class ShortedRemainingTime < Base
  def type
    "SRT"
  end

  def run_steps(i)
    @sorted_jobs ||= jobs.sort { |job1, job2| job1.cycles_remaining <=> job2.cycles_remaining }
    sorted_jobs = @sorted_jobs

    @current_job_index = 0

    while sorted_jobs[@current_job_index].cycles_remaining == 0 || sorted_jobs[@current_job_index].start_time > i
      next_job
    end

    sorted_jobs[@current_job_index].cycles_remaining -= 1

    if sorted_jobs[@current_job_index].cycles_remaining == 0
      sorted_jobs[@current_job_index].complete_time = i
    end
  end
end

class RoundRobin < Base
  def type
    "RR"
  end

  def run_steps(i)

    # set time q
    # get current job
    # decrement job and tq
    # add job to run
    # check cycles_remaining == 0
    # check time_quantum == 0


    @jobs_to_run ||= []
    @remaining_time_quantum ||= time_quantum

    special_case ||= 0
    jobs.each do |job|
      if job.start_time == i && special_case == 0
        @jobs_to_run << job unless @jobs_to_run.map(&:id).include? job.id
      end
    end
    special_case = nil

    @current_job ||= @jobs_to_run.shift

    @current_job.cycles_remaining -= 1
    @remaining_time_quantum -= 1

    if @current_job.cycles_remaining == 0
      @current_job.complete_time = i
      @current_job = nil
      @remaining_time_quantum = time_quantum
    end

    if @remaining_time_quantum == 0
      jobs.each do |job|
        if job.start_time == i + 1
          @jobs_to_run << job
          special_case = 1
        end
      end
      @jobs_to_run << @current_job if @current_job && @current_job.cycles_remaining > 0
      @current_job = nil
      @remaining_time_quantum = nil
    end
  end
end

time_quantum = ARGV[1].to_i
input = File.open(ARGV[0], 'r').readlines.join("").to_s


fcfs = FirstComeFirstServe.new(input, time_quantum)
puts fcfs.to_s, ""
sjn = ShortestJobNext.new(input, time_quantum)
puts sjn.to_s, ""
srt = ShortedRemainingTime.new(input, time_quantum)
puts srt.to_s, ""
rr = RoundRobin.new(input, time_quantum)
puts rr.to_s, ""

min = [fcfs.avg, sjn.avg, srt.avg, rr.avg].min
puts "Averages:"
puts "fcfs: " + fcfs.avg.to_s + (fcfs.avg == min ? " <-- Best" : "")
puts "sjn: " + sjn.avg.to_s + (sjn.avg == min ? " <-- Best" : "")
puts "srt: " + srt.avg.to_s + (srt.avg == min ? " <-- Best" : "")
puts "rr: " + rr.avg.to_s + (rr.avg == min ? " <-- Best" : "")



