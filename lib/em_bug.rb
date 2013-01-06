require 'eventmachine'
require 'amqp'
require 'thread'

module EMBug
  include EventMachine
  extend self

  COMMAND_EXCHANGE = 'amqp.command.test'


  def run_em_test(options = {}, &block)
    @qt = Thread::Queue.new
    @qc = 0

    options[:concurrency] ||= 1
    options[:task_latency_min] ||= 1
    options[:task_latency_max] ||= 1
    options[:events_per_sec] ||= 10

    EM::threadpool_size = options[:concurrency]
    latency = (rand(options[:task_latency_max]) + options[:task_latency_min]).to_f / 1000
    evp_wait = 1.0 / options[:events_per_sec]

    EM.run do
      printer

      EM.add_periodic_timer(evp_wait) do

        EM.defer do
          @qt << 0
          @qc += 1
          yield @qt
          sleep latency
          @qt.pop
        end

      end
    end
  end

  def printer
    EM.add_periodic_timer(1) do
      @lcount ||= 0
      @ltime ||= Time.now.to_i - 10

      @count = @qc
      tdiff = Time.now.to_i - @ltime.to_i
      qdiff = @count - @lcount
      msgs_ps = (qdiff / tdiff).to_i


      print "\e[2J\e[f"
      puts "Threads: #{@qt.length}"
      puts "Count: #@qc"
      puts "Msg/s: #{msgs_ps}"
      @lcount = @count
      @ltime = Time.now.to_f
    end
  end

  def run_amqp_test(options = {}, &block)
    @qt = Thread::Queue.new
    @qc = 0

    options[:concurrency] ||= 1
    options[:task_latency_min] ||= 1
    options[:task_latency_max] ||= 1

    EM::threadpool_size = options[:concurrency]
    latency = (rand(options[:task_latency_max]) + options[:task_latency_min]).to_f / 1000
    begin
    EM.run do
      printer

      @connection = AMQP.connect(:host => options[:node])
      routing_key = "#"

      @command_listen_channel ||= AMQP::Channel.new(@connection)
      @command_listen_channel.prefetch(options[:concurrency])
      @command_exchange = AMQP::Exchange.new(
          @command_listen_channel,
          :topic,
          COMMAND_EXCHANGE,
          :durable => true
      )
      queue = @command_listen_channel.queue("test.commands", :durable => true)
      queue.bind(@command_exchange, :routing_key => routing_key)
      queue.subscribe(:ack => true) do
      |metadata, payload|


          EM.defer do
            @qt << 0
            @qc += 1
            yield @qt
            sleep latency
            metadata.ack
            @qt.pop
          end



      end
    end
    rescue Java::JavaLang::NullPointerException => e
      puts e.class.name
      raise e
    end



  end

  def command_stage(options = {})
    options[:count] ||= 10


    EventMachine.run do
      connection = AMQP.connect(:host => options[:node])
      channel = AMQP::Channel.new(connection)
      exchange = AMQP::Exchange.new(
          channel,
          :topic,
          COMMAND_EXCHANGE,
          :durable => true
      )
      x = 0
      options[:count].times do

        exchange.publish("message body", :routing_key => 'command') do
          print '.'
          x = x + 1

          if x >= options[:count]
            connection.close {
              EventMachine.stop {
                puts "\n"
                exit
              }
            }
          end

        end

      end
    end
  end

  def kill_test
    EM.stop_event_loop
  end


end