# frozen_string_literal: true

module Eslint
  module Changes
    class Check
      def initialize(path, analysis, patch)
        @path = path
        @analysis = analysis
        @patch = patch
      end

      def offenses
        analysis.messages.select do |offense|
          line_numbers.include?(line(offense))
        end
      end

      attr_reader :path, :analysis, :patch

      private

      def line_numbers
        @line_numbers ||= lines_from_diff & lines_from_eslint
      end

      def lines_from_diff
        patch.changed_line_numbers
      end

      def lines_from_eslint
        analysis
          .messages
          .map(&method(:line)) # Change me
          .uniq
      end

      def line(offense)
        offense.line
      end
    end
  end
end
