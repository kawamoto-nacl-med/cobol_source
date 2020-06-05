class CobolSource
  class Sentence
    attr_reader :number, :sign, :code

    def initialize(str)
      analyze(str)
    end

    def analyze(str)
      @number = str.slice(0..5) || ""
      @sign = str.slice(6) || ""
      @code = str.slice(7..-1) || ""
    end

    def comment?
      @sign == "*"
    end

    def debug?
      @sign == "d" || @sign == "D"
    end

    def no_sign?
      !(comment? || debug?)
    end

    def to_s
      @number + @sign + @code
    end
  end
end
