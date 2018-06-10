using Hiccup
using Test

@tags br, link

# hiccup div conflicts with main div, so use this as compromise
ediv = Hiccup.div

@test occursin("class=\"class1 class2\"", sprint(Hiccup.render, Node(:img, "#id.class1.class2", Dict(:src=>"http://www.com"))))

classMatching = ((".section-title", "section-title"),
                 (".test", "test"),
                 (".test1.test2", "test1 test2"),
                 (".-test", "-test"),
                 (".-test1.-test2", "-test1 -test2"),
                 ("#.test", "test"),
                 ("#.test1-hyphen", "test1-hyphen"),
                 ("#.test1-hyphen.test2", "test1-hyphen test2"),
                 ("#id.test1.test2", "test1 test2"),
                 ("#id.test1.-test2", "test1 -test2"),
                 ("#id.test1.-test-2", "test1 -test-2"),
                 ("#id.test-hyphen", "test-hyphen"),
                 ("#id.-test", "-test"),
                 ("#id.-test.test2", "-test test2"),
                 ("#id.-test.-test2", "-test -test2"))
for (in, expected) in classMatching
  @test occursin(expected, sprint(Hiccup.render, Hiccup.div(in, "contents")))
end


# tests for void tags
@test string(br()) == "<br />"
@test string(img(".image-test", [])) == "<img class=\"image-test\" />"
@test occursin(
  "/>",
  string(link(Dict(:rel => "stylesheet", :href => "test.css"))))
@test_throws ArgumentError img(strong(".test", "test"))

# tests for normal tags
@test string(ediv(ediv(ediv()))) == "<div><div><div></div></div></div>"

# test escapes
@test string(Node(:pre, "<p>fish &amp; chips</p>")) ==
  "<pre>&lt;p&gt;fish &amp;amp; chips&lt;/p&gt;</pre>"

@test string(Node(:a, "link", href="http://example.com/test?a&b")) ==
  "<a href=\"http://example.com/test?a&amp;b\">link</a>"
