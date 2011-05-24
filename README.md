# Railslog

API for working with Rails CHANGELOG files. It grabs Rails CHANGELOGs from teh githubs and parses it to give you a Changelog object which has many Releases, which have many Entries.

## Install

    gem install railslog

## Use

    require 'railslog'

    changelog = Railslog.fetch('activerecord') # => <Railslog::Changelog releases:77>

    release = changelog.releases[1] # => <Railslog::Release version:3.0.7 date:2011-04-18>
    release.date # => #<Date: 2011-04-18 (4911339/2,0,2299161)>

    entry = release.entries.first # => <Railslog::Entry author:Durran Jordan text:Destroying records via nes...>
    entry.author # => "Durran Jordan"
    entry.text # => "Destroying records via nested attributes works independent of reject_if LH #6006 [Durran Jordan]\n"

## License

Copyright © 2011 Maxim Chernyak

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

