module Paraduct
  require "rsync"

  class SyncUtils
    # @param source_dir      [Pathname]
    # @param destination_dir [Pathname]
    def self.copy_recursive(source_dir, destination_dir)
      FileUtils.mkdir_p(destination_dir)

      rsync_options = %w(--recursive --delete)
      result = Rsync.run(source_dir.to_s + "/", destination_dir, rsync_options)
      raise result.error unless result.success?
      result
    end
  end
end
