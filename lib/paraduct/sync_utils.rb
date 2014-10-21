module Paraduct
  class SyncUtils
    # @param source_dir      [Pathname]
    # @param destination_dir [Pathname]
    def self.copy_recursive(source_dir, destination_dir)
      FileUtils.mkdir_p(destination_dir)
      source_dir.children.each do |source_child_dir|
        begin
          FileUtils.cp_r(source_child_dir, destination_dir)
        rescue ArgumentError => e
          # TODO: refactoring
          raise unless e.message =~ /^cannot copy directory .+ to itself /
        end
      end
    end

  end
end
