# frozen_string_literal: true

module Eslint
  module Changes
    class Shell
      def self.run(command)
        `#{command}`.strip
      end
    end
  end
end
