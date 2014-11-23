require 'open3'

class ShellCommand < Struct.new(:command)
  attr_reader :stdout
  attr_reader :stderr
  attr_reader :exit_status

  def run
    _, out, err, wait_thr = Open3.popen3(command)
    @stdout = out.read.split("\n")
    @stderr = err.read.split("\n")
    @exit_status = wait_thr.value.exitstatus
  end
end
