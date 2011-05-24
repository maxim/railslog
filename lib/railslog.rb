require 'date'
require 'open-uri'

module Railslog

  module_function

  def fetch(package)
    Changelog.new(open("https://github.com/rails/rails/raw/master/#{package}/CHANGELOG").read)
  end

  module Helper
    module_function

    def normalize(text)
      text.strip.gsub(/(?:^\s*\*|\s*\*$)/, '').strip
    end
  end

  class Changelog
    attr_reader :releases

    def initialize(text)
      @releases = []

      current_release = nil
      current_entry = nil

      text.each_line do |line|
        if Release.recognize?(line)
          current_release = Release.new(line)
          @releases << current_release
        elsif Entry.recognize?(line)
          current_entry = Entry.new(line)
          current_release ||= Release.new('Unreleased')
          current_release.add_entry(current_entry)
        elsif !current_entry.nil?
          current_entry.add_line(line)
        end
      end
    end

    def to_s
      "<#{self.class} releases:#{@releases.size}>"
    end
  end

  class Release
    attr_reader :title, :version, :date, :entries

    def self.recognize?(line)
      line =~ /^\*\S/
    end

    def initialize(release_title)
      @title = Helper.normalize(release_title)
      @version = @title[/\d+\.\d+(?:\.\d+)?/]
      @date = Date.parse(@title[/\(([^\)]+)\)/, 1]) rescue nil
    end

    def add_entry(entry)
      @entries ||= []
      @entries << entry
    end

    def to_s
      "<#{self.class} version:#{@version} date:#{@date}>"
    end
  end

  class Entry
    attr_reader :text, :author

    def self.recognize?(line)
      line =~ /^\*\s+/
    end

    def initialize(entry_text)
      @text = Helper.normalize(entry_text)
      @author = parse_author(entry_text)
    end

    def add_line(text)
      text.gsub!(/[\r\n]/, '')
      @text << "\n#{text}"
      @author = parse_author(text) || @author
    end

    def to_s
      "<#{self.class} author:#{@author} text:#{truncated_text}>"
    end

    private
    def parse_author(line)
      line[/\[([^#\:\?]+)\][^\]]*$/, 1].strip rescue nil
    end

    def truncated_text
      if @text.size > 30
        "#{@text[0, 26]}..."
      else
        @text
      end
    end
  end

end
