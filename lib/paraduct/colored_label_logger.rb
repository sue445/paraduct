module Paraduct
  class ColoredLabelLogger < ::Logger
    def initialize(label_name, logdev = STDOUT)
      super(logdev)
      color = Paraduct::ColoredLabelLogger.next_color
      @formatter = Formatter.new(label_name, color)
    end

    COLORS = [
      :cyan,
      :yellow,
      :green,
      :magenta,
      :red,
      :blue,
      :light,
      :cyan,
      :light_yellow,
      :light_green,
      :light_magenta,
      :light_red,
      :light_blue,
    ]
    def self.next_color
      @color_index ||= -1
      @color_index = (@color_index + 1) % COLORS.length
      COLORS[@color_index]
    end

    class Formatter
      def initialize(label_name, color)
        @label = "[#{label_name.to_s.colorize(color)}]"
      end

      def call(severity, datetime, progname, message)
        return "" if message.blank?

        content = ""
        message.each_line do |line|
          content << "#{@label} #{datetime}: #{line.strip}\n"
        end
        content
      end
    end
  end
end
