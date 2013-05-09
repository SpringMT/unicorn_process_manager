# encoding: UTF-8

class UnicornProcessManager
  def initialize(rails_env, rails_home, timeout, port)
    @rails_env  = rails_env
    @rails_home = rails_home
    @timeout    = timeout  || 60
    @port       = port     || 3000

    @config_file = (@rails_env == 'production' || @rails_env == 'staging') ? "#{@rails_home}/current/config/unicorn.rb" : "#{@rails_home}/config/unicorn.rb"
    @pid_file    = (@rails_env == 'production' || @rails_env == 'staging') ? "#{@rails_home}/shared/pids/unicorn.pid" : "#{@rails_home}/tmp/pids/unicorn.pid"
    # BUNDLE_GEMFILEの設定
    # Capistrano によるデプロイ時に Unicorn の再起動に失敗することがある問題への対処 http://blog.twiwt.org/e/2e6270
    # CapistranoでUnicornの起動と停止と再起動 http://higelog.brassworks.jp/?p=1533
    @gemfile     = (@rails_env == 'production' || @rails_env == 'staging') ? "#{@rails_home}/current/Gemfile" : "#{@rails_home}/Gemfile"
  end

  def usage
    puts "----- default -----"
    puts "timeout    : #{@timeout}"
    puts "RAILS_ENV  : #{@rails_env}"
    puts "rails home : #{@rails_home}"
    puts "port       : #{@port}"
    puts "----- usage -----"
    puts "#{$0} {start|stop|restart|status|reopen_log} [-e RAILS_ENV] [-h RAILS_HOME] [-t timeout_sec] [-p port]"
    true
  end

  def start
    exit 0 if is_unicorn_running?

    cmd = "bundle exec unicorn -p #{@port} -c #{@config_file} -D"
    start_time = Time.now
    pid = spawn({'RAILS_ENV' => @rails_env, 'BUNDLE_GEMFILE' => @gemfile}, cmd)
    # 起動するまで待つ
    Process.waitpid pid

    if File.exists? @pid_file
      new_pid = open(@pid_file).read.to_i
    end

    unless new_pid
      puts "\e[31mFailure\e[0m"
      exit 1
    end

    # 正常に起動できているか確認
    begin
      res = Process.kill(0, new_pid)
    rescue => e
      p e.message
      puts "\e[31mFailure!\e[0m Check ps aux | grep unicorn"
      exit 1
    else
      # killはシグナル送信に成功した場合、指定した pid の数返す
      if res == 1
        puts "\e[32mSuccess\e[0m #{Time.now - start_time} s"
        exit 0
      else
        puts "\e[31mFailure\e[0m Somethig Wrong"
        exit 1
      end
    end
  end

  def stop
    exit 0 if is_unicorn_stop?

    pid = open(@pid_file).read.to_i
    puts "stop pid: #{pid}"
    Process.kill :QUIT, pid

    timeout_count = 0
    # 正常に終了しているか確認
    loop do
      exit 1 if is_timeout?(@timeout, timeout_count)

      if File.exists? @pid_file
        print '.'
        STDOUT.flush
      else
        begin
          res = Process.kill(0, pid)
        rescue => e
          # プロセスがなくなると、例外が発生する
          if e.message == 'No such process'
            puts "\e[32mSuccess\e[0m"
            exit 0
          end
        end
      end
      sleep 1
      timeout_count += 1
    end
  end

  def restart
    exit 0 if is_unicorn_stop?
    exit 0 if is_unicorn_restarting?

    old_pid      = open(@pid_file).read.to_i
    old_pid_file = "#{@pid_file}.oldbin"

    puts "Send Signal USR2 to the pid: #{old_pid}"
    start_time = Time.now
    Process.kill(:USR2, old_pid)

    # 再起動が成功しているか確認
    timeout_count = 0
    new_pid = nil
    loop do
      exit 1 if is_timeout?(@timeout, timeout_count)

      if new_pid
        if File.exist?(old_pid_file)
          print '.'
          STDOUT.flush
        else
          if open(@pid_file).read.to_i == old_pid
            puts "\e[31mFailure\e[0m"
            exit 1
          else
            puts "\e[32mSuccess\e[0m #{Time.now - start_time} s"
            exit 0
          end
        end
      else
        if File.exist? @pid_file
          new_pid = open(@pid_file).read.to_i
        end
      end
      sleep 1
      timeout_count += 1
    end
  end

  def status
    old_pid_file = "#{@pid_file}.oldbin"

    if File.exists? @pid_file
      pid = open(@pid_file).read.to_i
      if File.exists? old_pid_file
        puts 'Restarting'
      else
        begin
          res = Process.kill(0, pid)
        rescue => e
          if e.message == 'No such process'
            puts "No such process : #{pid}  ! check ps aux #{pid}"
          end
        else
          if res == 1
            puts "Aready running unicorn"
          else
            puts "\e[31mFailure\e[0m Somethig Wrong"
          end
        end
      end
    else
      if File.exists? old_pid_file
        puts "\e[31mWarning!\e[0m Aready Exist Old Pid. Please check ps aux | grep unicorn"
      else
        puts 'Not running unicorn.'
      end
    end
  end

  def reopen_log
    exit 0 if is_unicorn_stop?
    exit 0 if is_unicorn_restarting?

    running_pid = open(@pid_file).read.to_i
    puts "Send Signal USR1 to the pid: #{running_pid}"
    res = Process.kill(:USR1, running_pid)
    raise RuntimeError unless res == 1
  end

  def method_missing(action, *args)
    usage
  end

  private
  def is_unicorn_stop?
    if File.exists? @pid_file
      old_pid = open(@pid_file).read.to_i
      master_process = `ps aux | grep -e " #{old_pid} " | grep -v grep`
      if master_process.empty?
        puts 'Not running unicorn'
        return true
      end
    else
      puts 'No pid file. Start unicorn'
      return true
    end
    return false
  end

  def is_unicorn_running?
    if File.exists? @pid_file
      old_pid = open(@pid_file).read.to_i
      master_process = `ps aux | grep -e " #{old_pid} " | grep -v grep`
      unless master_process.empty?
        puts 'Aready running'
      else
        puts "A pid file exists HOWEVER Not Running Unicorn.\nPlease remove pid file : #{@pid_file} and start again."
      end
      return true
    end
    return false
  end

  def is_unicorn_restarting?
    if File.exists? "#{@pid_file}.oldbin"
      puts 'Still restarting'
      return true
    end
    return false
  end

  def is_timeout?(timeout, count)
    if count > timeout
      puts 'Timeout'
      return true
    end
    return false
  end
end


