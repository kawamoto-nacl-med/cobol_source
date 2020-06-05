class CobolSource
  class Division
    attr_reader :source, :sections

    def initialize(source)
      @source = source

      analyze_section
    end

    def analyze_section
      @sections = {}
      section_names = @source.select { |sentence| sentence.code =~ /SECTION\s*./ }.map { |sentence| sentence.code.split.first }

      section_numbers = []
      section_names.each do |section_name|
        section_number = @source.index { |sentence| sentence.code =~ /\s*#{section_name}\s+SECTION\s*./ }
        section_numbers << { name: section_name, number: section_number }
      end

      section_numbers.each do |section_number|
        while @source[section_number[:number] - 1].comment?
          section_number[:number] -= 1
        end
      end

      section_numbers.each_with_index do |section_number, idx|
        if section_numbers[idx + 1]
          @sections[section_number[:name]] = Section.new(@source[section_number[:number]...section_numbers[idx + 1][:number]])
        else
          @sections[section_number[:name]] = Section.new(@source[section_number[:number]..-1])
        end
      end
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
      @sections.each do |section_name, section|
        collections = section.collect_phrase(phrase)
        phrases[section_name] = collections unless collections.empty?
      end

      phrases
    end

    # puts用
    def to_ary
      @source
    end
  end
end
