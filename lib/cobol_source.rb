require "cobol_source/version"
require "cobol_source/sentence"
require "cobol_source/division"
require "cobol_source/division/section"

class CobolSource
  class Error < StandardError; end

  attr_reader :copybooks, :source, :identification_division, :environment_division, :data_division, :procedure_division

  def initialize(filename)
    @source = File.readlines(filename, encoding: "euc-jp:utf-8").map { |line| Sentence.new(line) }

    analyze_division
  end

  def head(row_number = 0)
    # 引数が数値ではない場合、0に置き換える。
    row_number = 0 unless row_number.is_a?(Numeric)
    @source[0...row_number]
  end

  def tail(row_number = 0)
    # 引数が数値ではない場合、0に置き換える。
    row_number = 0 unless row_number.is_a?(Numeric)
    return [] if row_number == 0

    row_number.abs > @source.size ? @source : @source[-row_number.abs..-1]
  end

  def size
    @source.size
  end

  def analyze_division
    row_num = {}
    %w[IDENTIFICATION ENVIRONMENT DATA PROCEDURE].each do |div|
      row_num[div] = @source.index { |sentence| sentence.code =~ /\s*#{div}\s+DIVISION/ }
    end

    @identification_division = Division.new(@source[0...row_num["ENVIRONMENT"]])
    @environment_division = Division.new(@source[row_num["ENVIRONMENT"]...row_num["DATA"]])
    @data_division = Division.new(@source[row_num["DATA"]...row_num["PROCEDURE"]])
    @procedure_division = Division.new(@source[row_num["PROCEDURE"]..-1])
  end

  def divisions
    {
      "IDENRIFICATION DIVISION" => @identification_division,
      "ENVIRONMENT DIVISION" => @environment_division,
      "DATA DIVISION" => @data_division,
      "PROCEDURE DIVISION" => @procedure_division
    }
  end

  def collect_perform
    collect_phrase("PERFORM")
  end

  def collect_call
    collect_phrase("CALL")
  end

  def collect_copybook
    collect_phrase("COPY")
  end

  private

  def collect_phrase(phrase)
    phrases = {}
    divisions.each do |division_name, division|
      collections = division.collect_phrase(phrase)
      phrases[division_name] = collections unless collections.empty?
    end

    phrases
  end

  # puts用
  def to_ary
    @source
  end
end
