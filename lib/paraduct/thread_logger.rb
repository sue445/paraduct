module Paraduct
  class ThreadLogger < ::Logger
    def initialize(logdev = STDOUT)
      super(logdev)
      thread_id = Thread.current.object_id.to_s
      color = Paraduct::ThreadLogger.next_color
      @label = "[#{thread_id.colorize(color)}]"
      @formatter = ActiveSupport::Logger::SimpleFormatter.new
    end

    [:debug, :info, :warn, :error, :fatal].each do |severity|
      define_method "#{severity}_with_label" do |message|
        message.each_line do |line|
          send "#{severity}_without_label", "#{@label} #{line.strip}" unless line.blank?
        end
      end
      alias_method_chain severity, :label
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
      @@color_index ||= -1
      @@color_index = (@@color_index + 1) % COLORS.length
      COLORS[@@color_index]
    end
  end
end
