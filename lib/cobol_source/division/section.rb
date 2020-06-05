class CobolSource
  class Division
    class Section
      attr_reader :source

      def initialize(source)
        @source = source
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
        phrases = []
        @source.select { |sentence| sentence.no_sign? }.each do |sentence|
          sentence.code.match(/^\s*#{phrase}\s+"?([\w.-]+)"?/i) do |md|
            phrases << md[1]
          end
        end

        phrases
      end

      # puts用
      def to_ary
        @source
      end
    end
  end
end
