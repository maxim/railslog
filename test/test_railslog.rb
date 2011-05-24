require 'test_helper'


module Railslog

  class TestChangelog < Test::Unit::TestCase
    def setup
      @changelog = Changelog.new <<-TEXT
*1.3.2* (February 5th, 2007)

* Deprecate server_settings renaming it to smtp_settings,  add sendmail_settings to allow you to override the arguments to and location of the sendmail executable. [Michael Koziarski]


*1.3.1* (January 16th, 2007)

* Depend on Action Pack 1.13.1


*1.3.0* (January 16th, 2007)

* Make mime version default to 1.0. closes #2323 [ror@andreas-s.net]

* Make sure quoted-printable text is decoded correctly when only portions of the text are encoded. closes #3154. [jon@siliconcircus.com]

* Make sure DOS newlines in quoted-printable text are normalized to unix newlines before unquoting. closes #4166 and #4452. [Jamis Buck]

    foo bar baz
    testing multiline entry

* Fixed that iconv decoding should catch InvalidEncoding #3153 [jon@siliconcircus.com]
      TEXT
    end

    def test_parses_releases
      assert_equal 3, @changelog.releases.size
      assert_equal 1, @changelog.releases[0].entries.size
      assert_equal 1, @changelog.releases[1].entries.size
      assert_equal 4, @changelog.releases[2].entries.size
    end

    def test_returns_pretty_to_s
      assert_equal '<Railslog::Changelog releases:3>', @changelog.to_s
    end
  end

  class TestRelease < Test::Unit::TestCase
    def setup
      @release = Release.new('*Rails 3.0.4 (February 8, 2011)*')
    end

    def test_normalizes_release_title
      assert_equal 'Rails 3.0.4 (February 8, 2011)', @release.title
    end

    def test_parses_version_from_release_title
      assert_equal '3.0.4', @release.version
    end

    def test_parses_date_from_release_title
      assert_equal Date.parse('2011-02-08'), @release.date
    end

    def test_sets_date_to_nil_if_cant_parse
      assert_nil Release.new('*Rails 3.0.4*').date
    end

    def test_maintains_array_of_entries
      @release.add_entry(entry = Entry.new('foo'))
      assert_includes @release.entries, entry
    end

    def test_recognizes_a_release_line
      assert Release.recognize?('*Rails 3.0.4 (February 8, 2011)*')
      assert Release.recognize?('*1.3.1* (January 16th, 2007)')
    end

    def test_does_not_recognize_an_entry_line
      refute Release.recognize?('* Don\'t allow i18n to change the minor version, version now set to ~> 0.5.0 [Santiago Pastorino]')
      refute Release.recognize?('* Don\'t allow i18n to change the minor version, version now set to ~> 0.5.0')
    end

    def test_returns_pretty_to_s
      assert_equal '<Railslog::Release version:3.0.4 date:2011-02-08>', @release.to_s
    end
  end

  class TestEntry < Test::Unit::TestCase
    def setup
      @entry = Entry.new('* Don\'t allow i18n to change the minor version, version now set to ~> 0.5.0 [Santiago Pastorino]')
    end

    def test_normalizes_entry_text
      assert_equal 'Don\'t allow i18n to change the minor version, version now set to ~> 0.5.0 [Santiago Pastorino]', @entry.text
    end

    def test_parses_entry_author
      assert_equal 'Santiago Pastorino', @entry.author
    end

    def test_parses_entry_author_in_another_line
      @entry.add_line('[foo bar]')
      assert_equal 'foo bar', @entry.author
    end

    def test_sets_author_to_nil_if_missing
      entry = Entry.new('* Don\'t allow i18n to change the minor version, version now set to ~> 0.5.0 ')
      assert_nil entry.author
    end

    def test_recognizes_an_entry_start_line
      assert Entry.recognize?('* foobar')
    end

    def test_does_not_recognize_a_release_line
      refute Entry.recognize?('*1.3.1* (January 16th, 2007)')
    end

    def test_does_not_recognize_an_entry_body_line
      refute Entry.recognize?('    def iso_charset(recipient')
    end

    def test_adds_line_to_entry
      @entry.add_line('foobar')
      assert_equal <<-TEXT.strip, @entry.text
Don\'t allow i18n to change the minor version, version now set to ~> 0.5.0 [Santiago Pastorino]
foobar
      TEXT
    end

    def test_returns_pretty_to_s
      assert_equal '<Railslog::Entry author:Santiago Pastorino text:Don\'t allow i18n to change...>', @entry.to_s
    end

    def test_normalizes_multiline_entry_text
      @entry = Entry.new <<-TEXT
* Added support for charsets for both subject and body. The default charset is now UTF-8 #673 [Jamis Buck]. Examples:

    def iso_charset(recipient)
      @recipients = recipient
      @subject    = "testing iso charsets"
      @from       = "system@loudthinking.com"
      @body       = "Nothing to see here."
      @charset    = "iso-8859-1"
    end

    def unencoded_subject(recipient)
      @recipients = recipient
      @subject    = "testing unencoded subject"
      @from       = "system@loudthinking.com"
      @body       = "Nothing to see here."
      @encode_subject = false
      @charset    = "iso-8859-1"
    end
      TEXT

      assert_equal <<-TEXT.strip, @entry.text
Added support for charsets for both subject and body. The default charset is now UTF-8 #673 [Jamis Buck]. Examples:

    def iso_charset(recipient)
      @recipients = recipient
      @subject    = "testing iso charsets"
      @from       = "system@loudthinking.com"
      @body       = "Nothing to see here."
      @charset    = "iso-8859-1"
    end

    def unencoded_subject(recipient)
      @recipients = recipient
      @subject    = "testing unencoded subject"
      @from       = "system@loudthinking.com"
      @body       = "Nothing to see here."
      @encode_subject = false
      @charset    = "iso-8859-1"
    end
      TEXT
    end

    def test_parses_multiline_entry_author
      @entry = Entry.new <<-TEXT
* Added support for charsets for both subject and body. The default charset is now UTF-8 #673 [Jamis Buck]. Examples:

    def iso_charset(recipient)
      @recipients = recipient
      @subject    = "testing iso charsets"
      @from       = "system@loudthinking.com"
      @body       = "Nothing to see here."
      @charset    = "iso-8859-1"
    end

    def unencoded_subject(recipient)
      @recipients = recipient
      @subject    = "testing unencoded subject"
      @from       = "system@loudthinking.com"
      @body       = "Nothing to see here."
      @encode_subject = false
      @charset    = "iso-8859-1"
    end
      TEXT

      assert_equal 'Jamis Buck', @entry.author
    end
  end
end
