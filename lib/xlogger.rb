#encoding:UTF-8
require 'logger'
require 'time'
require 'date'

class Logger
  class LogDevice
    def check_shift_log
      if @shift_age.is_a?(Integer)
        # Note: always returns false if '0'.
        if @filename && (@shift_age > 0) && (@dev.stat.size > @shift_size)
          lock_shift_log {shift_log_age}
        end
      else
        now = Time.now
        if now >= @next_rotate_time
          lock_shift_log {shift_log_period(previous_period_end(now, @shift_age))}
          @next_rotate_time = next_rotate_time(now, @shift_age)
        end
      end
    end
  end

  module Period
    alias_method :old_next_rotate_time, :next_rotate_time
    alias_method :old_previous_period_end, :previous_period_end

    def next_rotate_time(now, shift_age)
      case shift_age
        when 'hour'
          t = Time.mktime(now.year, now.month, now.mday, now.hour) + 60 * 60
        else
          t = self.old_next_rotate_time(now, shift_age)
      end
      return t
    end

    def previous_period_end(now, shift_age)
      case shift_age
        when 'hour'
          t = Time.mktime(now.year, now.month, now.mday, now.hour) - 1
        else
          t = self.old_previous_period_end(now, shift_age)
      end
      return t
    end
  end
end