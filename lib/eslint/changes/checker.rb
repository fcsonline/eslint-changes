# frozen_string_literal: true

require 'git_diff_parser'
require 'json'
require 'colorize'

require 'eslint/changes/check'
require 'eslint/changes/shell'

module Eslint
  module Changes
    class UnknownForkPointError < StandardError; end

    class Checker
      def initialize(report:, quiet:, commit:, base_branch:)
        @report = report
        @quiet = quiet
        @commit = commit
        @base_branch = base_branch
      end

      def run
        raise UnknownForkPointError if fork_point.empty?

        print_offenses! unless quiet

        total_offenses
      end

      private

      attr_reader :report, :format, :quiet, :commit

      def fork_point
        @fork_point ||= Shell.run(command)
      end

      def command
        return "git merge-base HEAD origin/#{@base_branch}" unless commit

        "git log -n 1 --pretty=format:\"%h\" #{commit}"
      end

      def diff
        Shell.run("git diff #{fork_point}")
      end

      def patches
        @patches ||= GitDiffParser.parse(diff)
      end

      def changed_files
        patches.map(&:file)
      end

      def eslint_json
        @eslint_json ||= JSON.parse(File.read(report), object_class: OpenStruct)
      end

      def checks
        @checks ||= changed_files.map do |file|
          analysis = eslint_json.find { |item| item.filePath.end_with?(file) }
          patch = patches.find { |item| item.file == file }

          next unless analysis

          Check.new(analysis.filePath, analysis, patch)
        end.compact
      end

      def total_offenses
        total_error_offenses
      end

      def total_error_offenses
        checks.map do |check|
          check.offenses.filter do |offense|
            offense.severity == 2
          end.size
        end.inject(0, :+)
      end

      def total_warn_offenses
        checks.map do |check|
          check.offenses.filter do |offense|
            offense.severity == 1
          end.size
        end.inject(0, :+)
      end

      def print_offenses!
        msg ""

        checks.each do |check|
          print_offenses_for_check(check)
        end

        msg ""
        msg "✖ #{total_error_offenses + total_warn_offenses} problems (#{total_error_offenses} error, #{total_warn_offenses} warnings)".red.bold
      end

      def print_offenses_for_check(check)
        return unless check.offenses.length > 0

        msg "#{check.path.underline}"
        check.offenses.map do |offense|
          place = "#{offense.line}:#{offense.column}".light_black
          msg "  #{place}  #{severity(offense.severity)}  #{offense.message} #{offense.ruleId.light_black}"
        end
      end

      def severity(value)
        return 'error'.red if value == 2
        return 'warn'.yellow if value == 1

        'off'
      end

      def msg(message)
        return if ENV['RACK_ENV'] == 'test'

        puts message
      end
    end
  end
end
