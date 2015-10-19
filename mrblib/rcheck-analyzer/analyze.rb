module RcheckAnalyzer
  RUN_FILENAME = File.expand_path(File.dirname(__FILE__))
  class Analyze
    def initialize argv
      @log = argv[1]
      @total_line = argv[2].to_i
      begin
        raise if @log.nil?
        raise if argv[2] != "0" and @total_line == 0
        @key1 = (argv[3].nil?) ? "keys" : argv[3].downcase
        @key2 = (argv[4].nil?) ? argv[4] : argv[4].downcase
        @type = (argv[5].nil?) ? argv[5] : argv[5].downcase
        if @type == "sum"
          if (@key2_ary = @key2.split(".")).size != 2
            @key2_ary = nil
          end
        end
        @multi_keys = (@key2.nil?) ? false : true
        @log = Data::STDIN_FD if @log == "stdin" or @log == "self"
      rescue => e
        raise ArgumentError, "invalid argument\n#{Error::USAGE}"
      end
    end

    def run
      result = {}
      Data.each_data_from_log @log, @key1, @total_line do |line|
        analyze_data_line line, result
      end
      Message.output_result result, @multi_keys
    end

    def analyze_data_line d, analyze
      create_analyze_data d, analyze
    end

    def analyze_data data
      analyze = {}
      data.each do |d|
        create_analyze_data d, analyze
      end
      analyze
    end

    def create_analyze_data d, analyze
      if @key2.nil?
        analyze[d[@key1]] = 0 if analyze[d[@key1]].nil?
        analyze[d[@key1]] += 1
      else
        analyze[d[@key1]] = {} if analyze[d[@key1]].nil?
        if @type == "sum"
          if @key2_ary.nil?
            analyze[d[@key1]][@key2] = 0 if analyze[d[@key1]][@key2].nil?
            analyze[d[@key1]][@key2] += d[@key2].to_f
          else
            analyze[d[@key1]][@key2_ary[1]] = 0 if analyze[d[@key1]][@key2_ary[1]].nil?
            analyze[d[@key1]][@key2_ary[1]] += d[@key2_ary[0]][@key2_ary[1]].to_f
          end
        else
          analyze[d[@key1]][d[@key2]] = 0 if analyze[d[@key1]][d[@key2]].nil?
          analyze[d[@key1]][d[@key2]] += 1
        end
      end
    end
  end
end
