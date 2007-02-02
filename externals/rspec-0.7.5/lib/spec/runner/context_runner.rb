require File.dirname(__FILE__) + '/../../spec'

module Spec
  module Runner
    class ContextRunner
      
      def initialize(options)
        @contexts = []
        @options = options
      end
    
      def add_context(context)
        return if !@options.spec_name.nil? unless context.matches?(@options.spec_name)
        context.run_single_spec(@options.spec_name) if context.matches?(@options.spec_name)
        @contexts << context
      end
      
      # Runs all contexts and returns the number of failures.
      def run(exit_when_done)
        @options.reporter.start(number_of_specs)
        begin
          @contexts.each do |context|
            context.run(@options.reporter, @options.dry_run)
          end
        rescue Interrupt
        ensure
          @options.reporter.end
        end
        failure_count = @options.reporter.dump
        
        if(failure_count == 0 && !@options.heckle_runner.nil?)
          heckle_runner = @options.heckle_runner
          @options.heckle_runner = nil
          context_runner = self.class.new(@options)
          context_runner.instance_variable_set(:@contexts, @contexts)
          heckle_runner.heckle_with(context_runner)
        end
        
        if(exit_when_done)
          exit_code = (failure_count == 0) ? 0 : 1
          exit(exit_code)
        end
        failure_count
      end
    
      def number_of_specs
        @contexts.inject(0) {|sum, context| sum + context.number_of_specs}
      end
      
    end
  end
end
