require 'find'
require 'fileutils'

module SmallVictories
  class Deployer
    attr_accessor :config
    attr_accessor :folder

    def initialize attributes={}
      self.config = attributes[:config]
    end

    def copy folder=nil
      folder ||= config.deploy
      deploy_path = File.join(ROOT, folder)
      begin
        Find.find(config.full_destination_path) do |source|
          Find.prune if self.ignore_files.include?(File.basename(source))
          target = source.sub(/^#{config.full_destination_path}/, deploy_path)
          if File.directory? source
            FileUtils.mkdir target unless File.exists? target
          else
            FileUtils.copy(source, target)
          end
        end
      rescue => e
        SmallVictories.logger.error "Error deploying: #{e}"
      end
    end

    def ignore_files
      ['.git', config.source, CONFIG_FILE, GUARD_FILE]
    end
  end
end
