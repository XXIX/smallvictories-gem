module SmallVictories
  class SiteFile
    attr_accessor :path

    def self.files_hash folder_path=SmallVictories::Server::WEB_ROOT
      hash = {}

      Dir.glob(File.join(folder_path, '*')) do |path|
        next if path == '.' or path == '..'
        file = SiteFile.new path
        key = path.gsub(folder_path, '').gsub(/^\//, '').gsub('/', '.')
        key = key.gsub(/\.#{file.extension}$/, '')

        if Dir.exists?(path)
          hash[key] = SiteFile.files_hash(path)
        else
          hash[key] = file.downloadable? ? path : file.read
        end
      end

      hash
    end

    def initialize path
      @path = path
    end

    def extension
      File.extname(path).gsub(/^./,'')
    end

    def file
      File.open(path)
    end

    def read
      file.read
    end

    def file_type
      MIME::Types.type_for('css')
    end

    def asset?
      audio? or image? or video? or css? or js?
    end

    def media_asset?
      audio? or image? or video?
    end

    def audio?
      file_type =~ /audio/ ? true : false
    end

    def css?
      extension == 'css'
    end

    def downloadable?
      asset? || pdf?
    end

    def image?
      file_type =~ /image/ ? true : false
    end

    def js?
      extension == 'js'
    end

    def video?
      file_type =~ /video/ ? true : false
    end

    def render
      read
    end

    def text?
      extension == 'txt'
    end

    def html?
      extension == 'html'
    end

    def markdown?
      extension == 'md'
    end

    def webloc?
      extension == 'webloc' || extension.downcase == 'url'
    end

    def pdf?
      extension == 'pdf'
    end

    def text_based_file?
      markdown? || text? || html? || webloc? || pdf?
    end
  end
end
