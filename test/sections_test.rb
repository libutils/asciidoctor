# encoding: UTF-8
require 'test_helper'

context 'Sections' do
  context 'Ids' do
    test 'synthetic id is generated by default' do
      sec = block_from_string('== Section One')
      assert_equal '_section_one', sec.id
    end

    test 'synthetic id replaces non-word characters with underscores' do
      sec = block_from_string("== We're back!")
      assert_equal '_we_re_back', sec.id
    end

    test 'synthetic id removes repeating underscores' do
      sec = block_from_string('== Section $ One')
      assert_equal '_section_one', sec.id
    end

    test 'synthetic id prefix can be customized' do
      sec = block_from_string(":idprefix: id_\n\n== Section One")
      assert_equal 'id_section_one', sec.id
    end

    test 'synthetic id prefix can be set to blank' do
      sec = block_from_string(":idprefix:\n\n== Section One")
      assert_equal 'section_one', sec.id
    end

    test 'synthetic id separator can be customized' do
      sec = block_from_string(":idseparator: -\n\n== Section One")
      assert_equal '_section-one', sec.id
    end

    test 'synthetic id separator can be set to blank' do
      sec = block_from_string(":idseparator:\n\n== Section One")
      assert_equal '_sectionone', sec.id
    end

    test 'synthetic ids can be disabled' do
      sec = block_from_string(":sectids!:\n\n== Section One\n")
      assert sec.id.nil?
    end

    test 'explicit id in anchor above section title overrides synthetic id' do
      sec = block_from_string("[[one]]\n== Section One")
      assert_equal 'one', sec.id
    end

    test 'explicit id can be defined using an inline anchor' do
      sec = block_from_string("== Section One [[one]] ==")
      assert_equal 'one', sec.id
      assert_equal 'Section One', sec.title
    end

    test 'title substitutions are applied before generating id' do
      sec = block_from_string("== Section{sp}One\n")
      assert_equal '_section_one', sec.id
    end

    test 'synthetic ids are unique' do
      input = <<-EOS
== Some section

text

== Some section

text
      EOS
      doc = document_from_string input
      assert_equal '_some_section', doc.blocks[0].id
      assert_equal '_some_section_2', doc.blocks[1].id
    end
  end

  context "document title (level 0)" do
    test "document title with multiline syntax" do
      title = "My Title"
      chars = "=" * title.length
      assert_xpath "//h1[not(@id)][text() = 'My Title']", render_string(title + "\n" + chars)
      assert_xpath "//h1[not(@id)][text() = 'My Title']", render_string(title + "\n" + chars + "\n")
    end

    test "document title with multiline syntax, give a char" do
      title = "My Title"
      chars = "=" * (title.length + 1)
      assert_xpath "//h1[not(@id)][text() = 'My Title']", render_string(title + "\n" + chars)
      assert_xpath "//h1[not(@id)][text() = 'My Title']", render_string(title + "\n" + chars + "\n")
    end

    test "document title with multiline syntax, take a char" do
      title = "My Title"
      chars = "=" * (title.length - 1)
      assert_xpath "//h1[not(@id)][text() = 'My Title']", render_string(title + "\n" + chars)
      assert_xpath "//h1[not(@id)][text() = 'My Title']", render_string(title + "\n" + chars + "\n")
    end

    test "not enough chars for a multiline document title" do
      title = "My Title"
      chars = "=" * (title.length - 2)
      assert_xpath '//h1', render_string(title + "\n" + chars), 0
      assert_xpath '//h1', render_string(title + "\n" + chars + "\n"), 0
    end

    test "too many chars for a multiline document title" do
      title = "My Title"
      chars = "=" * (title.length + 2)
      assert_xpath '//h1', render_string(title + "\n" + chars), 0
      assert_xpath '//h1', render_string(title + "\n" + chars + "\n"), 0
    end

    test "document title with multiline syntax cannot begin with a dot" do
      title = ".My Title"
      chars = "=" * title.length
      assert_xpath '//h1', render_string(title + "\n" + chars), 0
    end

    test "document title with single-line syntax" do
      assert_xpath "//h1[not(@id)][text() = 'My Title']", render_string("= My Title")
    end

    test "document title with symmetric syntax" do
      assert_xpath "//h1[not(@id)][text() = 'My Title']", render_string("= My Title =")
    end
  end

  context "level 1" do 
    test "with multiline syntax" do
      assert_xpath "//h2[@id='_my_section'][text() = 'My Section']", render_string("My Section\n-----------")
    end

    test "heading title with multiline syntax cannot begin with a dot" do
      title = ".My Title"
      chars = "-" * title.length
      assert_xpath '//h2', render_string(title + "\n" + chars), 0
    end

    test "with single-line syntax" do
      assert_xpath "//h2[@id='_my_title'][text() = 'My Title']", render_string("== My Title")
    end

    test "with single-line symmetric syntax" do
      assert_xpath "//h2[@id='_my_title'][text() = 'My Title']", render_string("== My Title ==")
    end

    test "with single-line non-matching symmetric syntax" do
      assert_xpath "//h2[@id='_my_title'][text() = 'My Title ===']", render_string("== My Title ===")
    end

    test "with non-word character" do
      assert_xpath "//h2[@id='_where_s_the_love'][text() = \"Where#{[8217].pack('U*')}s the love?\"]", render_string("== Where's the love?")
    end

    test "with sequential non-word characters" do
      assert_xpath "//h2[@id='_what_the_is_this'][text() = 'What the \#@$ is this?']", render_string('== What the #@$ is this?')
    end

    test "with trailing whitespace" do
      assert_xpath "//h2[@id='_my_title'][text() = 'My Title']", render_string("== My Title ")
    end

    test "with custom blank idprefix" do
      assert_xpath "//h2[@id='my_title'][text() = 'My Title']", render_string(":idprefix:\n\n== My Title ")
    end

    test "with custom non-blank idprefix" do
      assert_xpath "//h2[@id='ref_my_title'][text() = 'My Title']", render_string(":idprefix: ref_\n\n== My Title ")
    end

    test 'with multibyte characters' do
      input = <<-EOS
== Asciidoctor in 中文
      EOS
      output = render_string input
      assert_xpath '//h2[@id="_asciidoctor_in"][text()="Asciidoctor in 中文"]', output
    end
  end

  context "level 2" do 
    test "with multiline syntax" do
      assert_xpath "//h3[@id='_my_section'][text() = 'My Section']", render_string(":fragment:\nMy Section\n~~~~~~~~~~~")
    end

    test "with single line syntax" do
      assert_xpath "//h3[@id='_my_title'][text() = 'My Title']", render_string(":fragment:\n=== My Title")
    end
  end  

  context "level 3" do 
    test "with multiline syntax" do
      assert_xpath "//h4[@id='_my_section'][text() = 'My Section']", render_string(":fragment:\nMy Section\n^^^^^^^^^^")
    end

    test "with single line syntax" do
      assert_xpath "//h4[@id='_my_title'][text() = 'My Title']", render_string(":fragment:\n==== My Title")
    end
  end

  context "level 4" do 
    test "with multiline syntax" do
      assert_xpath "//h5[@id='_my_section'][text() = 'My Section']", render_string(":fragment:\nMy Section\n++++++++++")
    end

    test "with single line syntax" do
      assert_xpath "//h5[@id='_my_title'][text() = 'My Title']", render_string(":fragment:\n===== My Title")
    end
  end

  context "level 5" do 
    test "with single line syntax" do
      assert_xpath "//h6[@id='_my_title'][text() = 'My Title']", render_string(":fragment:\n====== My Title")
    end
  end

  context 'Floating Title' do
    test 'should create floating title if style is float' do
      input = <<-EOS
[float]
= Plain Ol' Heading

not in section
      EOS

      output = render_embedded_string input
      assert_xpath '/h1[@id="_plain_ol_heading"]', output, 1
      assert_xpath '/h1[@class="float"]', output, 1
      assert_xpath %(/h1[@class="float"][text()="Plain Ol' Heading"]), output, 1
      assert_xpath '/h1/following-sibling::*[@class="paragraph"]', output, 1
      assert_xpath '/h1/following-sibling::*[@class="paragraph"]/p', output, 1
      assert_xpath '/h1/following-sibling::*[@class="paragraph"]/p[text()="not in section"]', output, 1
    end

    test 'should create floating title if style is discrete' do
      input = <<-EOS
[discrete]
=== Plain Ol' Heading

not in section
      EOS

      output = render_embedded_string input
      assert_xpath '/h3', output, 1
      assert_xpath '/h3[@id="_plain_ol_heading"]', output, 1
      assert_xpath '/h3[@class="discrete"]', output, 1
      assert_xpath %(/h3[@class="discrete"][text()="Plain Ol' Heading"]), output, 1
      assert_xpath '/h3/following-sibling::*[@class="paragraph"]', output, 1
      assert_xpath '/h3/following-sibling::*[@class="paragraph"]/p', output, 1
      assert_xpath '/h3/following-sibling::*[@class="paragraph"]/p[text()="not in section"]', output, 1
    end

    test 'floating title should be a block with context floating_title' do
      input = <<-EOS
[float]
=== Plain Ol' Heading

not in section
      EOS

      doc = document_from_string input
      floatingtitle = doc.blocks.first
      assert floatingtitle.is_a?(Asciidoctor::Block)
      assert !floatingtitle.is_a?(Asciidoctor::Section)
      assert_equal :floating_title, floatingtitle.context
      assert_equal '_plain_ol_heading', floatingtitle.id
      assert doc.references[:ids].has_key?('_plain_ol_heading')
    end

    test 'can assign explicit id to floating title' do
      input = <<-EOS
[[unchained]]
[float]
=== Plain Ol' Heading

not in section
      EOS

      doc = document_from_string input
      floating_title = doc.blocks.first
      assert_equal 'unchained', floating_title.id
      assert doc.references[:ids].has_key?('unchained')
    end

    test 'should not include floating title in toc' do
      input = <<-EOS
:toc:

== Section One

[float]
=== Miss Independent

== Section Two
      EOS

      output = render_string input
      assert_xpath '//*[@id="toc"]', output, 1
      assert_xpath %(//*[@id="toc"]//a[contains(text(), " Section ")]), output, 2
      assert_xpath %(//*[@id="toc"]//a[text()="Miss Independent"]), output, 0
    end

    test 'should not set id on floating title if sectids attribute is unset' do
      input = <<-EOS
[float]
=== Plain Ol' Heading

not in section
      EOS

      output = render_embedded_string input, :attributes => {'sectids' => nil}
      assert_xpath '/h3', output, 1
      assert_xpath '/h3[@id="_plain_ol_heading"]', output, 0
      assert_xpath '/h3[@class="float"]', output, 1
    end

    test 'should use explicit id for floating title if specified' do
      input = <<-EOS
[[free]]
[float]
== Plain Ol' Heading

not in section
      EOS

      output = render_embedded_string input
      assert_xpath '/h2', output, 1
      assert_xpath '/h2[@id="free"]', output, 1
      assert_xpath '/h2[@class="float"]', output, 1
    end

    test 'should add role to class attribute on floating title' do
      input = <<-EOS
[float, role="isolated"]
== Plain Ol' Heading

not in section
      EOS

      output = render_embedded_string input
      assert_xpath '/h2', output, 1
      assert_xpath '/h2[@id="_plain_ol_heading"]', output, 1
      assert_xpath '/h2[@class="float isolated"]', output, 1
    end
  end

  context 'Level offset' do
    test 'should print error if standalone document is included without level offset' do
      input = <<-EOS
= Master Document
Doc Writer

text in master

// begin simulated include::[]
= Standalone Document
:author: Junior Writer

text in standalone

// end simulated include::[]
      EOS

      output, errors = nil
      redirect_streams do |stdout, stderr|
        output = render_string input
        errors = stdout.string
      end

      assert !errors.empty?
      assert_match(/only book doctypes can contain level 0 sections/, errors)
    end

    test 'should add level offset to section level' do
      input = <<-EOS
= Master Document
Doc Writer

Master document written by {author}.

:leveloffset: 1

// begin simulated include::[]
= Standalone Document
:author: Junior Writer

Standalone document written by {author}.

== Section in Standalone

Standalone section text.
// end simulated include::[]

:leveloffset!:

== Section in Master

Master section text.
      EOS

      output = nil
      errors = nil
      redirect_streams do |stdout, stderr|
        output = render_string input
        errors = stdout.string
      end

      assert errors.empty?
      assert_match(/Master document written by Doc Writer/, output) 
      assert_match(/Standalone document written by Junior Writer/, output) 
      assert_xpath '//*[@class="sect1"]/h2[text() = "Standalone Document"]', output, 1
      assert_xpath '//*[@class="sect2"]/h3[text() = "Section in Standalone"]', output, 1
      assert_xpath '//*[@class="sect1"]/h2[text() = "Section in Master"]', output, 1
    end

    test 'level offset should be added to floating title' do
      input = <<-EOS
= Master Document
Doc Writer

:leveloffset: 1

[float]
= Floating Title
      EOS

      output = render_string input
      assert_xpath '//h2[@class="float"][text() = "Floating Title"]', output, 1
    end

    test 'should be able to reset level offset' do
      input = <<-EOS
= Master Document
Doc Writer

Master preamble.

:leveloffset: 1

= Standalone Document

Standalone preamble.

:leveloffset!:

== Level 1 Section
      EOS

      output = render_string input
      assert_xpath '//*[@class = "sect1"]/h2[text() = "Standalone Document"]', output, 1
      assert_xpath '//*[@class = "sect1"]/h2[text() = "Level 1 Section"]', output, 1
    end
  end

  context 'Section Numbering' do
    test 'should create section number with one entry for level 1' do
      sect1 = Asciidoctor::Section.new(nil)
      sect1.level = 1
      assert_equal '1.', sect1.sectnum
    end

    test 'should create section number with two entries for level 2' do
      sect1 = Asciidoctor::Section.new(nil)
      sect1.level = 1
      sect1_1 = Asciidoctor::Section.new(sect1)
      sect1 << sect1_1
      assert_equal '1.1.', sect1_1.sectnum
    end

    test 'should create section number with three entries for level 3' do
      sect1 = Asciidoctor::Section.new(nil)
      sect1.level = 1
      sect1_1 = Asciidoctor::Section.new(sect1)
      sect1 << sect1_1
      sect1_1_1 = Asciidoctor::Section.new(sect1_1)
      sect1_1 << sect1_1_1
      assert_equal '1.1.1.', sect1_1_1.sectnum
    end

    test 'should create section number for second section in level' do
      sect1 = Asciidoctor::Section.new(nil)
      sect1.level = 1
      sect1_1 = Asciidoctor::Section.new(sect1)
      sect1 << sect1_1
      sect1_2 = Asciidoctor::Section.new(sect1)
      sect1 << sect1_2
      assert_equal '1.2.', sect1_2.sectnum
    end

    test 'sectnum should use specified delimiter and append string' do
      sect1 = Asciidoctor::Section.new(nil)
      sect1.level = 1
      sect1_1 = Asciidoctor::Section.new(sect1)
      sect1 << sect1_1
      sect1_1_1 = Asciidoctor::Section.new(sect1_1)
      sect1_1 << sect1_1_1
      assert_equal '1,1,1,', sect1_1_1.sectnum(',')
      assert_equal '1:1:1', sect1_1_1.sectnum(':', false)
    end

    test 'should render section numbers when numbered attribute is set' do
      input = <<-EOS
= Title
:numbered:

== Section_1 

text

=== Section_1_1

text

==== Section_1_1_1

text

== Section_2

text

=== Section_2_1

text

=== Section_2_2

text
      EOS
    
      output = render_string input
      assert_xpath '//h2[@id="_section_1"][starts-with(text(), "1. ")]', output, 1
      assert_xpath '//h3[@id="_section_1_1"][starts-with(text(), "1.1. ")]', output, 1
      assert_xpath '//h4[@id="_section_1_1_1"][starts-with(text(), "1.1.1. ")]', output, 1
      assert_xpath '//h2[@id="_section_2"][starts-with(text(), "2. ")]', output, 1
      assert_xpath '//h3[@id="_section_2_1"][starts-with(text(), "2.1. ")]', output, 1
      assert_xpath '//h3[@id="_section_2_2"][starts-with(text(), "2.2. ")]', output, 1
    end

    test 'blocks should have level' do
      input = <<-EOS
= Title

preamble

== Section 1

paragraph

=== Section 1.1

paragraph
      EOS
      doc = document_from_string input
      assert_equal 0, doc.blocks[0].level
      assert_equal 1, doc.blocks[1].level
      assert_equal 1, doc.blocks[1].blocks[0].level
      assert_equal 2, doc.blocks[1].blocks[1].level
      assert_equal 2, doc.blocks[1].blocks[1].blocks[0].level
    end
  end

  context 'Special sections' do
    test 'should assign sectname and caption to appendix section' do
      input = <<-EOS
[appendix]
== Attribute Options

Details
      EOS

      output = block_from_string input
      assert_equal 'appendix', output.sectname
      assert_equal 'Appendix A: ', output.caption
    end

    test 'should render appendix title prefixed with caption' do
      input = <<-EOS
[appendix]
== Attribute Options

Details
      EOS

      output = render_embedded_string input
      assert_xpath '//h2[text()="Appendix A: Attribute Options"]', output, 1
    end

    test 'should increment appendix number for each appendix section' do
      input = <<-EOS
[appendix]
== Attribute Options

Details

[appendix]
== Migration

Details
      EOS

      output = render_embedded_string input
      assert_xpath '(//h2)[1][text()="Appendix A: Attribute Options"]', output, 1
      assert_xpath '(//h2)[2][text()="Appendix B: Migration"]', output, 1
    end

    test 'should not number level 4 section' do
      input = <<-EOS
:numbered:

== Level_1

=== Level_2

==== Level_3

===== Level_4

text
      EOS
      output = render_embedded_string input
      assert_xpath '//h5', output, 1
      assert_xpath '//h5[text()="Level_4"]', output, 1
    end

    test 'should not number special sections or subsections' do
      input = <<-EOS
:numbered:

== Section One

[appendix]
== Attribute Options

Details

[appendix]
== Migration

Details

=== Gotchas

Details

[glossary]
== Glossary

Terms
      EOS

      output = render_embedded_string input
      assert_xpath '(//h2)[1][text()="1. Section One"]', output, 1
      assert_xpath '(//h2)[2][text()="Appendix A: Attribute Options"]', output, 1
      assert_xpath '(//h2)[3][text()="Appendix B: Migration"]', output, 1
      assert_xpath '(//h3)[1][text()="Gotchas"]', output, 1
      assert_xpath '(//h2)[4][text()="Glossary"]', output, 1
    end

    test 'should not number special sections or subsections in toc' do
      input = <<-EOS
:numbered:
:toc:

== Section One

[appendix]
== Attribute Options

Details

[appendix]
== Migration

Details

=== Gotchas

Details

[glossary]
== Glossary

Terms
      EOS

      output = render_string input
      assert_xpath '//*[@id="toc"]/ol//li/a[text()="1. Section One"]', output, 1
      assert_xpath '//*[@id="toc"]/ol//li/a[text()="Appendix A: Attribute Options"]', output, 1
      assert_xpath '//*[@id="toc"]/ol//li/a[text()="Appendix B: Migration"]', output, 1
      assert_xpath '//*[@id="toc"]/ol//li/a[text()="Gotchas"]', output, 1
      assert_xpath '//*[@id="toc"]/ol//li/a[text()="Glossary"]', output, 1
    end

    test 'level 0 special sections in multipart book should be rendered as level 1' do
      input = <<-EOS
= Multipart Book
Doc Writer
:doctype: book

[preface]
= Preface

Preface text

[appendix]
= Appendix

Appendix text
      EOS

      output = render_string input
      assert_xpath '//h2[@id = "_preface"]', output, 1
      assert_xpath '//h2[@id = "_appendix"]', output, 1
    end
  end

  context "heading patterns in blocks" do
    test "should not interpret a listing block as a heading" do
      input = <<-EOS
Section
-------

----
code
----

fin.
      EOS
      output = render_string input
      assert_xpath "//h2", output, 1
    end

    test "should not interpret an open block as a heading" do
      input = <<-EOS
Section
-------

--
ha
--

fin.
      EOS
      output = render_string input
      assert_xpath "//h2", output, 1
    end

    test "should not interpret an attribute list as a heading" do
      input = <<-EOS
Section
=======

preamble

[TIP]
====
This should be a tip, not a heading.
====
      EOS
      output = render_string input
      assert_xpath "//*[@class='admonitionblock tip']//p[text() = 'This should be a tip, not a heading.']", output, 1
    end

    test "should not match a heading in a labeled list" do
      input = <<-EOS
Section
-------

term1::
+
----
list = [1, 2, 3];
----
term2::
== not a heading
term3:: def

//

fin.
      EOS
      output = render_string input
      assert_xpath "//h2", output, 1
      assert_xpath "//dl", output, 1
    end

    test "should not match a heading in a bulleted list" do
      input = <<-EOS
Section
-------

* first
+
----
list = [1, 2, 3];
----
+
* second
== not a heading
* third

fin.
      EOS
      output = render_string input
      assert_xpath "//h2", output, 1
      assert_xpath "//ul", output, 1
    end

    test "should not match a heading in a block" do
      input = <<-EOS
====

== not a heading

====
      EOS
      output = render_string input
      assert_xpath "//h2", output, 0
      assert_xpath "//*[@class='exampleblock']//p[text() = '== not a heading']", output, 1
    end
  end

  context 'Table of Contents' do
    test 'should render table of contents in header if toc attribute is set' do
      input = <<-EOS
= Article
:toc:

== Section One

It was a dark and stormy night...

== Section Two

They couldn't believe their eyes when...

=== Interlude

While they were waiting...

== Section Three

That's all she wrote!
      EOS
      output = render_string input
      assert_xpath '//*[@id="header"]//*[@id="toc"][@class="toc"]', output, 1
      assert_xpath '//*[@id="header"]//*[@id="toc"]/*[@id="toctitle"][text()="Table of Contents"]', output, 1
      assert_xpath '//*[@id="header"]//*[@id="toc"]/ol', output, 1
      assert_xpath '//*[@id="header"]//*[@id="toc"]//ol', output, 2
      assert_xpath '//*[@id="header"]//*[@id="toc"]/ol/li', output, 4
      assert_xpath '//*[@id="header"]//*[@id="toc"]/ol/li[1]/a[@href="#_section_one"][text()="1. Section One"]', output, 1
      assert_xpath '//*[@id="header"]//*[@id="toc"]/ol/li/ol/li', output, 1
      assert_xpath '//*[@id="header"]//*[@id="toc"]/ol/li/ol/li/a[@href="#_interlude"][text()="2.1. Interlude"]', output, 1
    end

    test 'should render table of contents in header if toc2 attribute is set' do
      input = <<-EOS
= Article
:toc2:

== Section One

It was a dark and stormy night...

== Section Two

They couldn't believe their eyes when...
      EOS

      output = render_string input
      assert_xpath '//*[@id="header"]//*[@id="toc"][@class="toc2"]', output, 1
      assert_xpath '//*[@id="header"]//*[@id="toc"]/ol/li[1]/a[@href="#_section_one"][text()="1. Section One"]', output, 1
    end

    test 'should use document attributes toc-class, toc-title and toclevels to create toc' do
      input = <<-EOS
= Article
:toc:
:toc-title: Contents
:toc-class: toc2
:toclevels: 1

== Section 1

=== Section 1.1

==== Section 1.1.1

==== Section 1.1.2

=== Section 1.2

== Section 2

Fin.
      EOS
      output = render_string input
      assert_css '#header #toc', output, 1
      assert_css '#header #toc.toc2', output, 1
      assert_css '#header #toc li', output, 2
      assert_css '#header #toc #toctitle', output, 1
      assert_xpath '//*[@id="header"]//*[@id="toc"]/*[@id="toctitle"][text()="Contents"]', output, 1
    end

    test 'should render table of contents in preamble if toc-placement attribute value is preamble' do
      input = <<-EOS
= Article
:toc:
:toc-placement: preamble

Once upon a time...

== Section One

It was a dark and stormy night...

== Section Two

They couldn't believe their eyes when...
      EOS

      output = render_string input
      assert_xpath '//*[@id="preamble"]/*[@id="toc"]', output, 1
    end

    test 'should not render table of contents if toc-placement attribute is unset' do
      input = <<-EOS
= Article
:toc:
:toc-placement!:

== Section One

It was a dark and stormy night...

== Section Two

They couldn't believe their eyes when...
      EOS

      output = render_string input
      assert_xpath '//*[@id="toc"]', output, 0
    end

    test 'should render table of contents at location of toc macro' do
      input = <<-EOS
= Article
:toc:
:toc-placement!:

Once upon a time...

toc::[]

== Section One

It was a dark and stormy night...

== Section Two

They couldn't believe their eyes when...
      EOS

      output = render_string input
      assert_css '#preamble #toc', output, 1
      assert_css '#preamble .paragraph + #toc', output, 1
    end

    test 'should render table of contents at location of toc macro in embedded document' do
      input = <<-EOS
= Article
:toc:
:toc-placement!:

Once upon a time...

toc::[]

== Section One

It was a dark and stormy night...

== Section Two

They couldn't believe their eyes when...
      EOS

      output = render_string input, :header_footer => false
      assert_css '#preamble:root #toc', output, 1
      assert_css '#preamble:root .paragraph + #toc', output, 1
    end

    test 'should not assign toc id to more than one toc' do
      input = <<-EOS
= Article
:toc:

Once upon a time...

toc::[]

== Section One

It was a dark and stormy night...

== Section Two

They couldn't believe their eyes when...
      EOS

      output = render_string input

      assert_css '#toc', output, 1
      assert_css '#toctitle', output, 1
      assert_xpath '(//*[@class="toc"])[2][not(@id)]', output, 1
      assert_xpath '(//*[@class="toc"])[2]/*[@class="title"][not(@id)]', output, 1
    end

    test 'should use global attributes for toc-title, toc-class and toclevels for toc macro' do
      input = <<-EOS
= Article
:toc:
:toc-placement!:
:toc-title: Contents
:toc-class: contents
:toclevels: 1

Preamble.

toc::[]

== Section 1

=== Section 1.1

==== Section 1.1.1

==== Section 1.1.2

=== Section 1.2

== Section 2

Fin.
      EOS

      output = render_string input
      assert_css '#toc', output, 1
      assert_css '#toctitle', output, 1
      assert_css '#preamble #toc', output, 1
      assert_css '#preamble #toc.contents', output, 1
      assert_xpath '//*[@id="toc"]/*[@class="title"][text() = "Contents"]', output, 1
      assert_css '#toc li', output, 2
      assert_xpath '(//*[@id="toc"]//li)[1]/a[text() = "1. Section 1"]', output, 1
      assert_xpath '(//*[@id="toc"]//li)[2]/a[text() = "2. Section 2"]', output, 1
    end

    test 'should honor id, title, role and level attributes on toc macro' do
      input = <<-EOS
= Article
:toc:
:toc-placement!:
:toc-title: Ignored
:toc-class: ignored
:toclevels: 5
:tocdepth: 1

Preamble.

[[contents]]
[role="contents"]
.Contents
toc::[levels={tocdepth}]

== Section 1

=== Section 1.1

==== Section 1.1.1

==== Section 1.1.2

=== Section 1.2

== Section 2

Fin.
      EOS

      output = render_string input
      assert_css '#toc', output, 0
      assert_css '#toctitle', output, 0
      assert_css '#preamble #contents', output, 1
      assert_css '#preamble #contents.contents', output, 1
      assert_xpath '//*[@id="contents"]/*[@class="title"][text() = "Contents"]', output, 1
      assert_css '#contents li', output, 2
      assert_xpath '(//*[@id="contents"]//li)[1]/a[text() = "1. Section 1"]', output, 1
      assert_xpath '(//*[@id="contents"]//li)[2]/a[text() = "2. Section 2"]', output, 1
    end
  end

  context 'article doctype' do
    test 'should create sections only in docbook backend' do
      input = <<-EOS
= Article
Doc Writer

== Section 1

The adventure.

=== Subsection One

It was a dark and stormy night...

=== Subsection Two

They couldn't believe their eyes when...

== Section 2

The return.

=== Subsection Three

While they were returning...

=== Subsection Four

That's all she wrote!
      EOS

      output = render_string input, :backend => 'docbook'
      assert_xpath '//part', output, 0
      assert_xpath '//chapter', output, 0
      assert_xpath '/article/section', output, 2
      assert_xpath '/article/section[1]/title[text() = "Section 1"]', output, 1
      assert_xpath '/article/section[2]/title[text() = "Section 2"]', output, 1
      assert_xpath '/article/section/section', output, 4
      assert_xpath '/article/section[1]/section[1]/title[text() = "Subsection One"]', output, 1
      assert_xpath '/article/section[2]/section[1]/title[text() = "Subsection Three"]', output, 1
    end
  end

  context 'book doctype' do
    test 'document title with level 0 headings' do
      input = <<-EOS
= Book
Doc Writer
:doctype: book

= Chapter One

It was a dark and stormy night...

= Chapter Two

They couldn't believe their eyes when...

== Interlude

While they were waiting...

= Chapter Three

That's all she wrote!
      EOS

      output = render_string(input)
      assert_xpath '//h1', output, 4
      assert_xpath '//h2', output, 1
      assert_xpath '//h1[@id="_chapter_one"][text() = "Chapter One"]', output, 1
      assert_xpath '//h1[@id="_chapter_two"][text() = "Chapter Two"]', output, 1
      assert_xpath '//h1[@id="_chapter_three"][text() = "Chapter Three"]', output, 1
    end

    test 'should create parts and chapters in docbook backend' do
      input = <<-EOS
= Book
Doc Writer
:doctype: book

= Part 1

The adventure.

== Chapter One

It was a dark and stormy night...

== Chapter Two

They couldn't believe their eyes when...

= Part 2

The return.

== Chapter Three

While they were returning...

== Chapter Four

That's all she wrote!
      EOS

      output = render_string input, :backend => 'docbook'
      assert_xpath '//chapter/chapter', output, 0
      assert_xpath '/book/part', output, 2
      assert_xpath '/book/part[1]/title[text() = "Part 1"]', output, 1
      assert_xpath '/book/part[2]/title[text() = "Part 2"]', output, 1
      assert_xpath '/book/part/chapter', output, 4
      assert_xpath '/book/part[1]/chapter[1]/title[text() = "Chapter One"]', output, 1
      assert_xpath '/book/part[2]/chapter[1]/title[text() = "Chapter Three"]', output, 1
    end

    test 'subsections in preface and appendix should start at level 2' do
      input = <<-EOS
= Multipart Book
Doc Writer
:doctype: book

[preface]
= Preface

Preface content

=== Preface subsection

Preface subsection content

= Part 1

.Part intro title
[partintro]
Part intro content

[appendix]
= Appendix

Appendix content

=== Appendix subsection

Appendix subsection content
      EOS

      output = nil
      errors = nil
      redirect_streams do |stdout, stderr|
        output = render_string input, :backend => 'docbook'
        errors = stdout.string
      end
      assert errors.empty?
      assert_xpath '/book/preface', output, 1
      assert_xpath '/book/preface/section', output, 1
      assert_xpath '/book/part', output, 1
      assert_xpath '/book/part/partintro', output, 1
      assert_xpath '/book/part/partintro/title', output, 1
      assert_xpath '/book/part/partintro/simpara', output, 1
      assert_xpath '/book/appendix', output, 1
      assert_xpath '/book/appendix/section', output, 1
    end
  end
end
