module LightService; module Organizer
  class WithReducer
    attr_reader :context

    def with(data = {})
      @context = LightService::Context.make(data)
      self
    end

    def reduce(*actions)
      raise "No action(s) were provided" if actions.empty?
      actions.flatten!

      actions.reduce(context) do |context, action|
        begin
          result = action.execute(context)

          yield(context, action) if block_given?
        rescue FailWithRollbackError
          result = reduce_rollback(actions)
        end

        result
      end
    end

    def reduce_rollback(actions)
      actions.reverse.reduce(context) do |context, action|
        if action.respond_to?(:rollback)
          action.rollback(context)
        else
          context
        end
      end
    end
  end
end; end
