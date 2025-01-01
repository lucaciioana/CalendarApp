# frozen_string_literal: true
module CalendarHelper
  def calendar(options = {}, &block)
    raise "calendar requires a block" unless block
    render Calendar::Base.new(self, options), &block
  end

  def month_calendar(options = {}, &block)
    raise "month_calendar requires a block" unless block
    render Calendar::Month.new(self, options), &block
  end

  def week_calendar(options = {}, &block)
    raise "week_calendar requires a block" unless block
    render Calendar::Week.new(self, options), &block
  end

end
